# ClaudeBrain Memory System

You have access to a persistent memory system called **ClaudeBrain** that stores context about all projects and sessions.

## Location
- Database: PostgreSQL container at `localhost:5434`
- CLI Tool: `C:\claudebrain\cli\brain.py`

## Usage

### Triggering Brain Search
When the user starts a message with `[brain]` followed by keywords, you should:
1. Search ClaudeBrain for those keywords
2. Start a new session for the task
3. Log decisions and gotchas as you work
4. End the session with a summary when complete

Example:
```
User: [brain] dashboard filters
You: [Search for "dashboard filters", then start a session]
```

### Available Commands

Search for context:
```bash
cd /c/claudebrain/cli && python brain.py search "keyword"
```

Start a new session:
```bash
cd /c/claudebrain/cli && python brain.py start "goal description" "project_name"
```

Log a decision:
```bash
cd /c/claudebrain/cli && python brain.py decision <session_id> "decision made" "reasoning"
```

Log a gotcha/problem solved:
```bash
cd /c/claudebrain/cli && python brain.py gotcha <session_id> "problem description" "solution"
```

Log a file change:
```bash
cd /c/claudebrain/cli && python brain.py file <session_id> "file/path" "modified" "what changed"
```

End a session:
```bash
cd /c/claudebrain/cli && python brain.py end <session_id> "summary of what was accomplished" "success"
```

View recent sessions:
```bash
cd /c/claudebrain/cli && python brain.py recent 10
```

## When to Use

- **Always** search ClaudeBrain when you see `[brain]` keyword
- **Proactively** start sessions for non-trivial work
- **Log decisions** when you make architectural or implementation choices
- **Log gotchas** when you solve tricky problems or bugs
- **End sessions** with clear summaries when work is complete

This system helps maintain context across sessions and builds institutional knowledge about projects.
