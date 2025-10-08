-- ClaudeBrain Memory Database Schema
-- Provides persistent memory across Claude Code sessions

-- Enable full-text search
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- ============================================
-- CORE TABLES
-- ============================================

-- Sessions: One entry per coding session
CREATE TABLE sessions (
    id SERIAL PRIMARY KEY,
    session_date DATE NOT NULL DEFAULT CURRENT_DATE,
    start_time TIMESTAMP DEFAULT NOW(),
    end_time TIMESTAMP,
    summary TEXT,
    user_goal TEXT,
    project_name VARCHAR(255),
    outcome VARCHAR(50), -- 'success', 'in_progress', 'blocked'
    created_at TIMESTAMP DEFAULT NOW()
);

-- Files Modified: Track all file changes per session
CREATE TABLE files_modified (
    id SERIAL PRIMARY KEY,
    session_id INT REFERENCES sessions(id) ON DELETE CASCADE,
    file_path TEXT NOT NULL,
    change_type VARCHAR(50), -- 'created', 'modified', 'deleted'
    lines_added INT DEFAULT 0,
    lines_removed INT DEFAULT 0,
    change_summary TEXT,
    before_snippet TEXT,
    after_snippet TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Decisions: Important design/architectural decisions
CREATE TABLE decisions (
    id SERIAL PRIMARY KEY,
    session_id INT REFERENCES sessions(id) ON DELETE CASCADE,
    decision TEXT NOT NULL,
    reasoning TEXT,
    alternatives_considered TEXT,
    outcome VARCHAR(50), -- 'worked', 'failed', 'rolled_back', 'unknown'
    tags TEXT[], -- PostgreSQL array for categorization
    created_at TIMESTAMP DEFAULT NOW()
);

-- Gotchas: Problems encountered and solutions
CREATE TABLE gotchas (
    id SERIAL PRIMARY KEY,
    session_id INT REFERENCES sessions(id) ON DELETE CASCADE,
    problem TEXT NOT NULL,
    solution TEXT NOT NULL,
    file_path TEXT,
    error_message TEXT,
    time_wasted_minutes INT,
    severity VARCHAR(20), -- 'minor', 'moderate', 'major', 'critical'
    tags TEXT[],
    created_at TIMESTAMP DEFAULT NOW()
);

-- Code Patterns: Reusable patterns and best practices
CREATE TABLE code_patterns (
    id SERIAL PRIMARY KEY,
    pattern_name TEXT UNIQUE NOT NULL,
    description TEXT,
    code_example TEXT,
    when_to_use TEXT,
    files_used_in TEXT[],
    last_used_session_id INT REFERENCES sessions(id),
    times_used INT DEFAULT 1,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Conversation Log: Full conversation history (optional, for detailed analysis)
CREATE TABLE conversation_log (
    id SERIAL PRIMARY KEY,
    session_id INT REFERENCES sessions(id) ON DELETE CASCADE,
    timestamp TIMESTAMP DEFAULT NOW(),
    speaker VARCHAR(10), -- 'user' or 'claude'
    message TEXT,
    message_vector tsvector -- For full-text search
);

-- Rules: Project-specific rules and constraints (like CLAUDE.md content)
CREATE TABLE rules (
    id SERIAL PRIMARY KEY,
    project_name VARCHAR(255),
    rule_category VARCHAR(100), -- 'architecture', 'style', 'workflow', etc.
    rule_text TEXT NOT NULL,
    priority INT DEFAULT 5, -- 1=highest, 10=lowest
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- ============================================
-- INDEXES FOR PERFORMANCE
-- ============================================

CREATE INDEX idx_sessions_date ON sessions(session_date DESC);
CREATE INDEX idx_sessions_project ON sessions(project_name);
CREATE INDEX idx_files_path ON files_modified(file_path);
CREATE INDEX idx_files_session ON files_modified(session_id);
CREATE INDEX idx_decisions_tags ON decisions USING GIN(tags);
CREATE INDEX idx_gotchas_tags ON gotchas USING GIN(tags);
CREATE INDEX idx_gotchas_severity ON gotchas(severity);
CREATE INDEX idx_patterns_name ON code_patterns(pattern_name);

-- Full-text search index
CREATE INDEX conversation_search_idx ON conversation_log USING GIN(message_vector);

-- Trigram indexes for fuzzy text search
CREATE INDEX idx_decisions_text ON decisions USING GIN(decision gin_trgm_ops);
CREATE INDEX idx_gotchas_problem ON gotchas USING GIN(problem gin_trgm_ops);
CREATE INDEX idx_patterns_desc ON code_patterns USING GIN(description gin_trgm_ops);

-- ============================================
-- HELPER VIEWS
-- ============================================

-- Recent activity summary
CREATE VIEW recent_sessions AS
SELECT
    s.id,
    s.session_date,
    s.summary,
    s.project_name,
    COUNT(DISTINCT f.id) as files_changed,
    COUNT(DISTINCT d.id) as decisions_made,
    COUNT(DISTINCT g.id) as gotchas_encountered
FROM sessions s
LEFT JOIN files_modified f ON s.id = f.session_id
LEFT JOIN decisions d ON s.id = d.session_id
LEFT JOIN gotchas g ON s.id = g.session_id
GROUP BY s.id, s.session_date, s.summary, s.project_name
ORDER BY s.session_date DESC;

-- File change frequency
CREATE VIEW file_change_frequency AS
SELECT
    file_path,
    COUNT(*) as times_changed,
    MAX(created_at) as last_changed,
    STRING_AGG(DISTINCT change_type, ', ') as change_types
FROM files_modified
GROUP BY file_path
ORDER BY times_changed DESC;

-- Files often changed together
CREATE VIEW files_changed_together AS
SELECT
    f1.file_path as file1,
    f2.file_path as file2,
    COUNT(*) as times_together
FROM files_modified f1
JOIN files_modified f2 ON f1.session_id = f2.session_id
WHERE f1.file_path < f2.file_path
GROUP BY f1.file_path, f2.file_path
HAVING COUNT(*) > 1
ORDER BY times_together DESC;

-- ============================================
-- HELPER FUNCTIONS
-- ============================================

-- Function to start a new session
CREATE OR REPLACE FUNCTION start_session(
    p_user_goal TEXT,
    p_project_name VARCHAR(255) DEFAULT 'myresumechat'
)
RETURNS INT AS $$
DECLARE
    v_session_id INT;
BEGIN
    INSERT INTO sessions (user_goal, project_name, start_time)
    VALUES (p_user_goal, p_project_name, NOW())
    RETURNING id INTO v_session_id;

    RETURN v_session_id;
END;
$$ LANGUAGE plpgsql;

-- Function to end a session
CREATE OR REPLACE FUNCTION end_session(
    p_session_id INT,
    p_summary TEXT,
    p_outcome VARCHAR(50) DEFAULT 'success'
)
RETURNS VOID AS $$
BEGIN
    UPDATE sessions
    SET
        end_time = NOW(),
        summary = p_summary,
        outcome = p_outcome
    WHERE id = p_session_id;
END;
$$ LANGUAGE plpgsql;

-- Function to search relevant context
CREATE OR REPLACE FUNCTION search_context(
    p_search_term TEXT,
    p_limit INT DEFAULT 20
)
RETURNS TABLE (
    source VARCHAR(50),
    session_id INT,
    session_date DATE,
    content TEXT,
    relevance DOUBLE PRECISION
) AS $$
BEGIN
    RETURN QUERY
    -- Search decisions
    SELECT
        'decision'::VARCHAR(50) as source,
        d.session_id,
        s.session_date,
        d.decision || E'\n' || COALESCE(d.reasoning, '') as content,
        CAST(similarity(d.decision || ' ' || COALESCE(d.reasoning, ''), p_search_term) AS DOUBLE PRECISION) as relevance
    FROM decisions d
    JOIN sessions s ON d.session_id = s.id
    WHERE d.decision ILIKE '%' || p_search_term || '%'
       OR d.reasoning ILIKE '%' || p_search_term || '%'

    UNION ALL

    -- Search gotchas
    SELECT
        'gotcha'::VARCHAR(50) as source,
        g.session_id,
        s.session_date,
        g.problem || E'\n' || g.solution as content,
        CAST(similarity(g.problem || ' ' || g.solution, p_search_term) AS DOUBLE PRECISION) as relevance
    FROM gotchas g
    JOIN sessions s ON g.session_id = s.id
    WHERE g.problem ILIKE '%' || p_search_term || '%'
       OR g.solution ILIKE '%' || p_search_term || '%'

    UNION ALL

    -- Search patterns
    SELECT
        'pattern'::VARCHAR(50) as source,
        cp.last_used_session_id as session_id,
        s.session_date,
        cp.pattern_name || E'\n' || COALESCE(cp.description, '') as content,
        CAST(similarity(cp.pattern_name || ' ' || COALESCE(cp.description, ''), p_search_term) AS DOUBLE PRECISION) as relevance
    FROM code_patterns cp
    LEFT JOIN sessions s ON cp.last_used_session_id = s.id
    WHERE cp.pattern_name ILIKE '%' || p_search_term || '%'
       OR cp.description ILIKE '%' || p_search_term || '%'

    ORDER BY relevance DESC, session_date DESC NULLS LAST
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- SEED DATA (EXAMPLE)
-- ============================================

-- Insert a sample rule from CLAUDE.md
INSERT INTO rules (project_name, rule_category, rule_text, priority) VALUES
('myresumechat', 'workflow', 'DO EXACTLY WHAT''S REQUESTED - NOTHING MORE. Never add features not explicitly requested.', 1),
('myresumechat', 'workflow', 'DISCUSS BEFORE IMPLEMENTING. Always ask about design decisions before coding.', 1),
('myresumechat', 'architecture', 'Use table_prefix methodology for demo vs live data isolation.', 2),
('myresumechat', 'workflow', 'Claude does NOT commit, push, or perform git operations. User handles all version control.', 1);

-- Create an initial session as example
INSERT INTO sessions (summary, project_name, outcome) VALUES
('ClaudeBrain setup - Created memory database for persistent context across sessions', 'ClaudeBrain', 'success');

-- ============================================
-- COMPLETION MESSAGE
-- ============================================

DO $$
BEGIN
    RAISE NOTICE '✅ ClaudeBrain database initialized successfully!';
    RAISE NOTICE '📊 Tables created: sessions, files_modified, decisions, gotchas, code_patterns, conversation_log, rules';
    RAISE NOTICE '🔍 Helper views and functions ready';
    RAISE NOTICE '🧠 ClaudeBrain is ready to remember everything!';
END $$;
