-- ============================================
-- CLAUD BRAIN - USEFUL QUERIES
-- Copy/paste these into psql or adapt for your needs
-- ============================================

-- Connect to database:
-- psql -h localhost -p 5433 -U claude -d claude_memory

-- ============================================
-- SESSION QUERIES
-- ============================================

-- Get current/recent sessions
SELECT * FROM recent_sessions LIMIT 10;

-- Find sessions by project
SELECT * FROM sessions
WHERE project_name = 'myresumechat'
ORDER BY session_date DESC;

-- Sessions with most activity
SELECT
    s.id,
    s.session_date,
    s.summary,
    COUNT(DISTINCT f.id) as files_changed,
    COUNT(DISTINCT d.id) as decisions_made,
    COUNT(DISTINCT g.id) as gotchas_logged
FROM sessions s
LEFT JOIN files_modified f ON s.id = f.session_id
LEFT JOIN decisions d ON s.id = d.session_id
LEFT JOIN gotchas g ON s.id = g.session_id
GROUP BY s.id, s.session_date, s.summary
HAVING COUNT(DISTINCT f.id) > 3
ORDER BY files_changed DESC;

-- ============================================
-- FILE CHANGE QUERIES
-- ============================================

-- Most frequently modified files
SELECT * FROM file_change_frequency LIMIT 20;

-- Files changed together (patterns)
SELECT * FROM files_changed_together LIMIT 20;

-- Find what files were changed with a specific file
SELECT DISTINCT f2.file_path, COUNT(*) as times_together
FROM files_modified f1
JOIN files_modified f2 ON f1.session_id = f2.session_id
WHERE f1.file_path = 'frontend/recruiter/dashboard.html'
  AND f2.file_path != f1.file_path
GROUP BY f2.file_path
ORDER BY times_together DESC;

-- Recent changes to specific file
SELECT
    s.session_date,
    f.change_type,
    f.change_summary,
    f.lines_added,
    f.lines_removed
FROM files_modified f
JOIN sessions s ON f.session_id = s.id
WHERE f.file_path LIKE '%dashboard.html%'
ORDER BY s.session_date DESC;

-- ============================================
-- DECISION QUERIES
-- ============================================

-- Recent decisions
SELECT
    s.session_date,
    d.decision,
    d.reasoning,
    d.outcome
FROM decisions d
JOIN sessions s ON d.session_id = s.id
ORDER BY s.session_date DESC
LIMIT 20;

-- Find decisions about specific topic
SELECT
    s.session_date,
    d.decision,
    d.reasoning,
    d.outcome
FROM decisions d
JOIN sessions s ON d.session_id = s.id
WHERE d.decision ILIKE '%filter%'
   OR d.reasoning ILIKE '%filter%'
ORDER BY s.session_date DESC;

-- Decisions by outcome
SELECT
    outcome,
    COUNT(*) as count,
    ARRAY_AGG(decision ORDER BY id DESC) as recent_decisions
FROM decisions
WHERE outcome IS NOT NULL
GROUP BY outcome;

-- ============================================
-- GOTCHA QUERIES
-- ============================================

-- Recent gotchas
SELECT
    s.session_date,
    g.problem,
    g.solution,
    g.severity,
    g.time_wasted_minutes
FROM gotchas g
JOIN sessions s ON g.session_id = s.id
ORDER BY s.session_date DESC
LIMIT 20;

-- Find gotchas by severity
SELECT
    severity,
    COUNT(*) as count,
    SUM(time_wasted_minutes) as total_time_wasted
FROM gotchas
GROUP BY severity
ORDER BY count DESC;

-- Search gotchas for specific problem
SELECT
    s.session_date,
    g.problem,
    g.solution,
    g.file_path
FROM gotchas g
JOIN sessions s ON g.session_id = s.id
WHERE g.problem ILIKE '%blob%'
   OR g.solution ILIKE '%blob%'
ORDER BY s.session_date DESC;

-- Most time-wasting issues
SELECT
    problem,
    solution,
    time_wasted_minutes,
    file_path
FROM gotchas
WHERE time_wasted_minutes IS NOT NULL
ORDER BY time_wasted_minutes DESC
LIMIT 10;

-- ============================================
-- CODE PATTERN QUERIES
-- ============================================

-- All code patterns
SELECT
    pattern_name,
    description,
    times_used,
    last_used_session_id
FROM code_patterns
ORDER BY times_used DESC;

-- Find patterns used in specific files
SELECT
    pattern_name,
    description,
    files_used_in
FROM code_patterns
WHERE 'dashboard.html' = ANY(files_used_in);

-- ============================================
-- SEARCH QUERIES
-- ============================================

-- Full-text search across decisions and gotchas
SELECT * FROM search_context('authentication', 10);

-- Search for file path patterns
SELECT DISTINCT file_path
FROM files_modified
WHERE file_path ILIKE '%recruiter%'
ORDER BY file_path;

-- ============================================
-- ANALYTICS QUERIES
-- ============================================

-- Activity over time
SELECT
    DATE_TRUNC('week', session_date) as week,
    COUNT(*) as sessions,
    COUNT(DISTINCT project_name) as projects
FROM sessions
GROUP BY week
ORDER BY week DESC;

-- Most productive days (by decisions + gotchas logged)
SELECT
    s.session_date,
    COUNT(DISTINCT d.id) + COUNT(DISTINCT g.id) as productivity_score,
    COUNT(DISTINCT d.id) as decisions,
    COUNT(DISTINCT g.id) as gotchas
FROM sessions s
LEFT JOIN decisions d ON s.id = d.session_id
LEFT JOIN gotchas g ON s.id = g.session_id
GROUP BY s.session_date
HAVING COUNT(DISTINCT d.id) + COUNT(DISTINCT g.id) > 0
ORDER BY productivity_score DESC
LIMIT 10;

-- Problem areas (files with most gotchas)
SELECT
    g.file_path,
    COUNT(*) as gotcha_count,
    STRING_AGG(DISTINCT g.problem, '; ') as problems
FROM gotchas g
WHERE g.file_path IS NOT NULL
GROUP BY g.file_path
ORDER BY gotcha_count DESC
LIMIT 10;

-- ============================================
-- MAINTENANCE QUERIES
-- ============================================

-- Database size
SELECT
    pg_size_pretty(pg_database_size('claude_memory')) as db_size;

-- Table sizes
SELECT
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- Record counts
SELECT
    'sessions' as table_name, COUNT(*) as records FROM sessions
UNION ALL
SELECT 'files_modified', COUNT(*) FROM files_modified
UNION ALL
SELECT 'decisions', COUNT(*) FROM decisions
UNION ALL
SELECT 'gotchas', COUNT(*) FROM gotchas
UNION ALL
SELECT 'code_patterns', COUNT(*) FROM code_patterns
UNION ALL
SELECT 'rules', COUNT(*) FROM rules;
