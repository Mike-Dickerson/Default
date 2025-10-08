# 🧠 ClaudeBrain

**Persistent memory for Claude Code sessions**

ClaudeBrain solves the "goldfish memory" problem - every Claude Code session starts fresh with no memory of previous conversations. This PostgreSQL-based system gives Claude persistent memory across sessions, dramatically improving productivity.

## 🎯 What Problem Does This Solve?

**Before ClaudeBrain:**
- Every session, you explain the same context again
- Claude forgets decisions made yesterday
- Solutions to past problems are lost
- No learning from previous mistakes
- You repeat yourself constantly

**After ClaudeBrain:**
- "Claude, search for 'dashboard filter'" → instant context
- Decisions, gotchas, and patterns are remembered
- Build a knowledge base of your codebase over time
- Claude can look up past solutions instantly
- Never explain the same thing twice

## 🚀 Quick Start

### 1. Start the Database

```bash
cd /c/ClaudeBrain
docker-compose up -d
```

This starts PostgreSQL on port `5433` (won't conflict with other databases).

### 2. Verify It's Running

```bash
docker ps | grep claude-memory
```

You should see the container running.

### 3. Install Python CLI Dependencies

```bash
cd cli
pip install -r requirements.txt
```

### 4. Test the Connection

```bash
python brain.py stats
```

Should show database statistics.

## 📚 Usage

### Starting a Session

```bash
python brain.py start "Fix recruiter dashboard filter bug"
# ✅ Session started: #42
# 📝 Goal: Fix recruiter dashboard filter bug
# 📁 Project: myresumechat
```

### Logging Decisions

```bash
python brain.py decision 42 "Use direct links for downloads instead of fetch/blob" "Blob conversion corrupts binary files"
# ✅ Decision logged: #15
# 📝 Use direct links for downloads instead of fetch/blob
# 💭 Reasoning: Blob conversion corrupts binary files
```

### Logging Gotchas (Problems + Solutions)

```bash
python brain.py gotcha 42 "Keyword filter not handling multi-user clusters" "Filter must rebuild dots from scratch, not just hide/show"
# ✅ Gotcha logged: #8
# ⚠️  Problem: Keyword filter not handling multi-user clusters
# ✨ Solution: Filter must rebuild dots from scratch, not just hide/show
```

### Logging File Changes

```bash
python brain.py file 42 "frontend/recruiter/dashboard.html" modified "Fixed keyword filter for clusters"
# ✅ File logged: #203
# 📄 frontend/recruiter/dashboard.html (modified)
```

### Searching for Context

```bash
python brain.py search "authentication"
# 🔍 Searching for: 'authentication'...
#
# ================================================================================
# #1 [DECISION] - Session #35 (2025-10-01)
# --------------------------------------------------------------------------------
# Use session token in URL query param for downloads
# Allows simple direct links without JavaScript fetch complications
```

### Viewing Recent Sessions

```bash
python brain.py recent 5
# 📅 Recent sessions:
#
# ================================================================================
# Session #42 - 2025-10-08
# Project: myresumechat
# Summary: Fixed keyword filter to handle multi-user clusters
# Activity: 3 files, 2 decisions, 1 gotchas
```

### Ending a Session

```bash
python brain.py end 42 "Fixed keyword filter to properly handle multi-user clusters. Filter now rebuilds dots from scratch." success
# ✅ Session #42 ended
# 📊 Outcome: success
# 📝 Summary: Fixed keyword filter to properly handle multi-user clusters...
#
# 📈 Session stats:
#    Files changed: 3
#    Decisions logged: 2
#    Gotchas logged: 1
```

## 🔍 Advanced Usage

### Direct SQL Queries

Connect to the database:

```bash
psql -h localhost -p 5433 -U claude -d claude_memory
# Password: dev_only_password
```

Or use Docker:

```bash
docker exec -it claude-memory psql -U claude -d claude_memory
```

### Useful Queries

See `queries/useful_queries.sql` for dozens of pre-written queries:

```sql
-- Find all decisions about authentication
SELECT * FROM search_context('authentication', 10);

-- Most frequently modified files
SELECT * FROM file_change_frequency LIMIT 20;

-- Files often changed together
SELECT * FROM files_changed_together;

-- Recent gotchas by severity
SELECT
    s.session_date,
    g.problem,
    g.solution,
    g.severity
FROM gotchas g
JOIN sessions s ON g.session_id = s.id
WHERE g.severity IN ('major', 'critical')
ORDER BY s.session_date DESC;
```

## 🗂️ Database Schema

### Core Tables

- **sessions** - Coding session metadata
- **files_modified** - File change tracking
- **decisions** - Important architectural/design decisions
- **gotchas** - Problems encountered and solutions
- **code_patterns** - Reusable patterns and best practices
- **rules** - Project-specific rules (from CLAUDE.md)
- **conversation_log** - Full conversation history (optional)

### Helper Views

- **recent_sessions** - Quick session overview with stats
- **file_change_frequency** - Most frequently modified files
- **files_changed_together** - File relationship patterns

### Helper Functions

- **start_session(goal, project)** - Start new session
- **end_session(id, summary, outcome)** - End session
- **search_context(term, limit)** - Full-text search across all content

## 🎓 Best Practices

### 1. Start Every Session

```bash
python brain.py start "Today's goal"
```

This creates context for all your work.

### 2. Log As You Go

Don't wait until the end! Log decisions and gotchas in real-time:

```bash
# Just made a decision?
python brain.py decision 42 "decision" "reasoning"

# Hit a gotcha?
python brain.py gotcha 42 "problem" "solution"
```

### 3. Search Before Asking

Before explaining context to Claude:

```bash
python brain.py search "dashboard filter"
```

Copy relevant results into your message.

### 4. End Sessions with Good Summaries

```bash
python brain.py end 42 "Detailed summary of what was accomplished" success
```

Good summaries make searching easier later.

### 5. Use Tags

When logging directly via SQL:

```sql
INSERT INTO decisions (session_id, decision, reasoning, tags)
VALUES (42, 'Use Redis for caching', 'Faster than DB queries',
        ARRAY['performance', 'caching', 'redis']);
```

## 🔧 Configuration

### Database Connection

Edit `cli/brain.py` to change connection settings:

```python
DB_CONFIG = {
    'host': 'localhost',
    'port': 5433,
    'database': 'claude_memory',
    'user': 'claude',
    'password': 'dev_only_password'
}
```

### Docker Compose

Edit `docker-compose.yml` to change port, password, etc.

## 📊 Monitoring

### Check Database Size

```bash
docker exec -it claude-memory psql -U claude -d claude_memory -c "SELECT pg_size_pretty(pg_database_size('claude_memory'));"
```

### View Logs

```bash
docker logs claude-memory
```

### Backup Database

```bash
docker exec claude-memory pg_dump -U claude claude_memory > backup_$(date +%Y%m%d).sql
```

### Restore Database

```bash
cat backup_20251008.sql | docker exec -i claude-memory psql -U claude -d claude_memory
```

## 🚀 Integration with Claude Code

### Start of Session

**You say:**
```
Working on recruiter dashboard filters
```

**Claude runs:**
```bash
python brain.py search "recruiter dashboard filter"
```

**Result:** Claude has instant context from past sessions without you explaining anything!

### During Session

Claude logs important decisions and gotchas automatically:

```bash
# Claude discovers something
python brain.py gotcha 42 "Blob conversion corrupts PDFs" "Use direct links instead"
```

### End of Session

Claude summarizes and ends the session:

```bash
python brain.py end 42 "Fixed filter to handle clusters properly" success
```

## 🎯 Example Workflow

```bash
# Monday morning
python brain.py start "Build email notification system"
# Work work work...
python brain.py decision 1 "Use SendGrid" "Better deliverability than SMTP"
python brain.py file 1 "backend/email_service.py" created
python brain.py end 1 "Email service basic implementation complete" success

# Tuesday morning
python brain.py start "Add email templates"
python brain.py search "email"
# Gets context from yesterday's session!
python brain.py gotcha 2 "SendGrid API rate limit" "Added exponential backoff retry"
python brain.py end 2 "Email templates working with retry logic" success

# Wednesday - different feature
python brain.py start "Dashboard performance optimization"
python brain.py search "dashboard"
# Gets ALL past dashboard work instantly!
```

## 🐛 Troubleshooting

### Container won't start

```bash
# Check if port 5433 is available
netstat -an | grep 5433

# Check Docker logs
docker logs claude-memory
```

### Can't connect

```bash
# Test connection
docker exec -it claude-memory psql -U claude -d claude_memory -c "SELECT 1;"
```

### Database is empty

```bash
# Reinitialize
docker-compose down -v
docker-compose up -d
```

## 📝 TODO / Future Enhancements

- [ ] Auto-log file changes via git hooks
- [ ] Web UI for browsing memory
- [ ] Embeddings + vector search for semantic search
- [ ] Auto-summarization of long sessions
- [ ] Integration with Claude Code startup
- [ ] Export memory to markdown reports
- [ ] Multi-project support with better isolation
- [ ] API endpoint for programmatic access

## 🤝 Contributing

This is a personal tool, but ideas welcome! Feel free to modify the schema and CLI for your needs.

## 📄 License

Use however you want. MIT License (or public domain, whatever).

## 🎉 Success Metrics

**After 1 week:**
- You'll stop explaining the same context repeatedly
- Claude will remember your past decisions
- Faster onboarding to any part of your codebase

**After 1 month:**
- Complete searchable history of your project's evolution
- Pattern recognition across sessions
- Dramatically reduced "wait, how did we solve this before?" moments

**After 6 months:**
- A complete knowledge graph of your codebase
- Instant context for any feature or bug
- **10x more productive sessions**

---

**Remember:** The value grows over time. The more you use it, the smarter Claude becomes about your project!
