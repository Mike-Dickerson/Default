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
