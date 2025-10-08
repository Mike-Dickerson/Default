# 🧠 ClaudeBrain Quick Reference

## Installation (One-Time)
```bash
cd /c/ClaudeBrain
docker-compose up -d
cd cli
pip install -r requirements.txt
```

## Daily Workflow

### Start Your Day
```bash
python brain.py start "Today's goal or feature"
# Returns: Session #42
```

### As You Work
```bash
# Made an important decision?
python brain.py decision 42 "what you decided" "why"

# Hit a problem and solved it?
python brain.py gotcha 42 "the problem" "the solution"

# Changed a file?
python brain.py file 42 "path/to/file.html" modified "what changed"
```

### Need Context?
```bash
# Search for anything
python brain.py search "keyword"

# See recent work
python brain.py recent 5
```

### End Your Day
```bash
python brain.py end 42 "Summary of what you accomplished" success
```

## One-Liners

```bash
# Database stats
python brain.py stats

# View recent sessions
python brain.py recent

# Search for filter-related work
python brain.py search "filter"

# Direct SQL access
docker exec -it claude-memory psql -U claude -d claude_memory
# Password: dev_only_password

# Check if it's running
docker ps | grep claude-memory
```

## For Claude

**At session start, Claude should run:**
```bash
python brain.py search "<topic user mentioned>"
```

**During session, Claude logs:**
```bash
python brain.py decision <session_id> "decision" "reasoning"
python brain.py gotcha <session_id> "problem" "solution"
```

**At session end:**
```bash
python brain.py end <session_id> "summary" success
```

## Connection Info
- **Host:** localhost
- **Port:** 5433
- **Database:** claude_memory
- **User:** claude
- **Password:** dev_only_password
