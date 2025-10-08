---
description: Access ClaudeBrain persistent memory system
---

# ClaudeBrain Command

**ClaudeBrain** is your persistent memory system across sessions and projects.

## Available Operations

The user will specify one of these operations after `/brain`:

- **search <keyword>** - Search for context from past sessions
- **start "<goal>" [project]** - Start a new session (returns session ID)
- **decision <session_id> "<what>" "<why>"** - Log a decision
- **gotcha <session_id> "<problem>" "<solution>"** - Log a problem/solution
- **file <session_id> "<path>" "<action>" "<changes>"** - Log file changes
- **end <session_id> "<summary>" <outcome>** - End session (outcome: success/partial/failed)
- **recent [limit]** - Show recent sessions (default: 10)
- **stats** - Show ClaudeBrain statistics

## Your Task

1. **Navigate to ClaudeBrain CLI**: `cd C:\default\claudebrain\cli`
2. **Execute the requested operation** using `python brain.py <operation> <args>`
3. **Display the results** clearly to the user
4. **If it's a search**: Summarize relevant findings
5. **If it's a session start**: Note the session ID for logging throughout the session

## Examples

```bash
# User: /brain search authentication
cd C:\default\claudebrain\cli && python brain.py search "authentication"

# User: /brain start "Add user login feature" myproject
cd C:\default\claudebrain\cli && python brain.py start "Add user login feature" "myproject"

# User: /brain recent 5
cd C:\default\claudebrain\cli && python brain.py recent 5
```

## Important Notes

- **Always log as you work**: When a session is active, proactively log decisions, gotchas, and file changes
- **Search first**: Before answering questions, check if ClaudeBrain has context
- **Session workflow**: search → start → work (log along the way) → end
- **Make it useful**: Good summaries and descriptions make future searches effective

Execute the user's requested ClaudeBrain operation now.
