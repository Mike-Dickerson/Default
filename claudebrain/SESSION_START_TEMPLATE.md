# 🧠 Session Start Template

Copy/paste this at the start of each Claude Code session:

---

**🧠 ClaudeBrain Session**

Working on: [brief description]

Search terms: [keywords to search - e.g., "dashboard filter", "authentication"]

---

## Examples:

### Example 1
```
🧠 ClaudeBrain Session
Working on: Recruiter dashboard filter bug
Search terms: dashboard filter, keyword filter, multi-user dots
```

### Example 2
```
🧠 ClaudeBrain Session
Working on: Email notification system
Search terms: email, sendgrid, notifications
```

### Example 3
```
🧠 ClaudeBrain Session
Working on: Performance optimization for map loading
Search terms: map performance, candidate loading, database query
```

---

When Claude sees "🧠 ClaudeBrain Session", Claude will:

1. Search for the keywords provided
2. Share relevant context from past sessions
3. Start a new session with: `python brain.py start "Working on: [your description]"`
4. Log decisions and gotchas as we work
5. End the session with a summary when done
