# Project Development - Claude Context File

## ⚠️ READ THESE RULES FIRST - MANDATORY FOR ALL AI MODELS ⚠️

### 🚨 CRITICAL DEVELOPMENT RULES - NO EXCEPTIONS 🚨

#### **RULE #1: NO WORKAROUNDS OR QUICK FIXES**
- ❌ NEVER suggest "try this quick fix while you wait"
- ❌ NEVER suggest temporary patches or workarounds
- ✅ Fix the root cause in the code properly
- ✅ Do a proper reset/restart if needed
- **Example violation**: "Run this ALTER TABLE command quickly" - NO!
- **Correct approach**: Fix the schema properly and do a proper reset

#### **RULE #2: DO EXACTLY WHAT'S REQUESTED - NOTHING MORE**
- ✅ User asks for validation → Add ONLY validation
- ❌ User asks for validation → Add validation + error handling + logging + UI improvements
- **Before coding**: "You asked for X. I will implement ONLY X. No additional features. Correct?"
- **If you have ideas**: ASK FIRST, CODE LATER
- **Treat requirements like a legal contract** - if it's not explicitly requested, don't build it

#### **RULE #3: NEVER "CLEAN UP" OR REMOVE WORKING CODE**
- ❌ NEVER remove variables, functions, or classes unless explicitly asked
- ❌ NEVER "optimize" or "refactor" unless specifically requested
- ❌ NEVER assume something is "not needed anymore"
- ✅ Leave ALL working code untouched unless told otherwise
- **Example violation**: Removing a class because you added another - caused crashes!
- **Correct approach**: Add new code, leave existing code alone

#### **RULE #4: DISCUSS BEFORE IMPLEMENTING**
- **Always ask**: "Should I make it a separate file or add to existing?"
- **Always ask**: "How should this integrate with your current setup?"
- **Always ask**: "Do you want me to modify X or create new Y?"
- **Never assume** architectural decisions
- **Never implement** suggestions without explicit approval

#### **RULE #5: ALL CODEBASES ARE DEEP AND COMPLEX**
- Small changes can CASCADE into major breaks
- Files are interconnected in ways you can't see
- One missing import can crash entire systems
- Schema changes affect multiple components
- **Respect the complexity** - move carefully and deliberately

#### **RULE #6: NOTHING IS TRIVIAL IN SOFTWARE DEVELOPMENT**
- **EVERY decision matters** - token limits, timeouts, array sizes, defaults, rate limits
- **What seems trivial can cost hours** - a single arbitrary number (max_tokens: 2000) caused 6 hours of debugging
- **Think of it as walking through a minefield full of rabbit holes** - step carefully, ask before placing your foot down
- **Never assume a parameter value** - ask "What limit makes sense?" instead of picking arbitrary numbers
- **Every number that controls system behavior needs discussion** - timeout values, page sizes, batch limits, retry counts
- **Real example**: Setting max_tokens=2000 for AI generation:
  - Seemed trivial - just a parameter
  - Actually caused: AI cutting off mid-generation, ignoring rules, 6 hours of debugging wrong paths
  - Should have asked: "What token limit makes sense? Typical outputs need X tokens. What's your plan capacity?"
- **The lesson**: If you're about to write a number that affects system behavior, STOP and ASK FIRST
- **Software reality**: Every "it probably doesn't matter" decision... matters

#### **WHY THESE RULES MATTER**
- **Time Cost**: Breaking these rules wastes HOURS in debugging
- **Cascading Failures**: Small "improvements" can break entire systems
- **Trust**: Following rules maintains user confidence and collaboration
- **Production Ready**: Real projects have real consequences

#### **CONSEQUENCES OF RULE VIOLATIONS**
- System crashes (missing imports, removed classes)
- Data corruption (schema "improvements")
- Lost user time and frustration
- Broken production features
- Required rollbacks and debugging sessions

### **FOR NEW AI MODELS**:
Read this file completely before making ANY changes. When in doubt, ASK FIRST. The user will start each session with "Read the rules!" - take that seriously.

---

## Project-Specific Information

**Add your project details below this line. The rules above are universal and apply to ALL projects.**

### Project Overview
[Describe your project here - what it does, main technologies, architecture]

### Repository Management
- **Claude does NOT**: commit, push, or perform any git operations
- **Claude ONLY**: saves code changes to local project files
- **User handles**: ALL version control, commits, and repository updates

### Key Commands
[List important commands for this project]
- Example: `npm run dev` - Start development server
- Example: `docker-compose up` - Start containers

### Infrastructure & Deployment
[Document hosting, deployment process, environments]

### Architecture Notes
[Document important architectural patterns, design decisions, coding standards]

### Development Workflow
[Describe how development works for this project]

### Session History
[Track major changes and decisions across sessions]

#### Session 1 (YYYY-MM-DD)
- Initial setup and exploration
- [Add notes here as project evolves]

---

## ClaudeBrain - Persistent Memory System

This repository includes **ClaudeBrain**, a PostgreSQL-based persistent memory system that provides cross-session context for Claude Code.

### What ClaudeBrain Solves
- Eliminates repeating context every session
- Remembers decisions, gotchas, and patterns
- Searchable history of all work
- Builds institutional knowledge over time

### Database Connection
- **Host:** localhost
- **Port:** 5434
- **Database:** claude_memory
- **User:** claude
- **Password:** dev_only_password
- **Container:** claude-memory (Docker)

### ClaudeBrain Architecture

**Important:** ClaudeBrain uses a **shared database** with **per-repo CLI tools**:

- **Shared Container:** One `claude-memory` Docker container runs the PostgreSQL database
  - All repos connect to the same database instance
  - Container managed from: `C:\default\claudebrain\` (reference/master copy)
  - Database persists across all projects
  - Port 5434 accessible from anywhere

- **Local CLI Tools:** Each repo has its own `\claudebrain\` folder
  - Example: `C:\myproject\claudebrain\cli\brain.py`
  - Contains the same CLI tools as the master
  - **All commands run from the LOCAL repo's claudebrain folder**
  - Connects to the shared container on localhost:5434

### Core Commands

Start database (first time only - from master location):
```bash
cd C:\default\claudebrain
docker-compose up -d
pip install -r cli/requirements.txt
```

Search for context (from your current repo):
```bash
cd claudebrain/cli
python brain.py search "keyword"
```

Start new session:
```bash
python brain.py start "goal description" "project_name"
# Returns: Session #42
```

Log decisions as you work:
```bash
python brain.py decision 42 "what you decided" "why you decided it"
```

Log gotchas (problems + solutions):
```bash
python brain.py gotcha 42 "problem description" "solution"
```

Log file changes:
```bash
python brain.py file 42 "path/to/file" "modified" "what changed"
```

End session:
```bash
python brain.py end 42 "summary of what was accomplished" "success"
```

View recent sessions:
```bash
python brain.py recent 10
```

Show statistics:
```bash
python brain.py stats
```

### [brain] Keyword Trigger

When the user starts a message with `[brain] keyword`, Claude should:

1. **Search** for context: `python brain.py search "keyword"`
2. **Start** a new session: `python brain.py start "task goal"`
3. **Log** decisions and gotchas as you work
4. **End** session with summary when complete

Example:
```
User: [brain] dashboard filters
Claude: [Searches ClaudeBrain, starts session, provides context from past work]
```

### Session Workflow

```bash
# 1. User mentions [brain] or you start work (from local repo)
cd claudebrain/cli
python brain.py search "relevant keywords"

# 2. Start session for the work
python brain.py start "Task description" "project_name"
# Note the session_id returned (e.g., 42)

# 3. As you work, log important things
python brain.py decision 42 "Use approach X" "Because Y and Z"
python brain.py gotcha 42 "Problem A" "Solution B"
python brain.py file 42 "path/file.py" "modified" "Added feature C"

# 4. End session with summary
python brain.py end 42 "Completed task successfully" "success"
```

### Database Schema

**Core Tables:**
- `sessions` - Coding session metadata (goals, outcomes, timestamps)
- `files_modified` - File change tracking with diffs
- `decisions` - Architectural/design decisions with reasoning
- `gotchas` - Problems encountered and solutions (with severity)
- `code_patterns` - Reusable patterns and best practices
- `rules` - Project-specific rules (like this CLAUDE.md content)

**Helper Functions:**
- `start_session(goal, project)` - Creates new session
- `end_session(id, summary, outcome)` - Ends session
- `search_context(term, limit)` - Full-text search across all content

**Useful Views:**
- `recent_sessions` - Session overview with stats
- `file_change_frequency` - Most modified files
- `files_changed_together` - Co-change patterns

### Direct SQL Access

```bash
# Via Docker
docker exec -it claude-memory psql -U claude -d claude_memory

# Via psql
psql -h localhost -p 5434 -U claude -d claude_memory
# Password: dev_only_password
```

### Troubleshooting ClaudeBrain

Check if running:
```bash
docker ps | grep claude-memory
```

View logs:
```bash
docker logs claude-memory
```

Restart:
```bash
cd C:\default\claudebrain
docker-compose restart
```

Reset database (WARNING: destroys all data):
```bash
docker-compose down -v
docker-compose up -d
```

### Best Practices

1. **Search before explaining** - Check ClaudeBrain before asking user for context
2. **Start every non-trivial session** - Creates tracking context
3. **Log as you go** - Don't wait until the end
4. **Good summaries** - Make searching easier later
5. **End sessions** - Provides closure and statistics

### Documentation

- Full docs: `C:\default\claudebrain\README.md`
- Quick reference: `C:\default\claudebrain\QUICKSTART.md`
- Usage instructions: `C:\default\instructions.md`
