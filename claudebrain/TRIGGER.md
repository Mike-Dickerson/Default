# ClaudeBrain Session Trigger

## Usage

Start your message with `[brain]` (case insensitive) followed by search keywords:

```
[brain] dashboard filters
```

```
[BRAIN] recruiter map performance
```

```
[Brain] authentication system
```

## What Happens

When Claude sees `[brain]` at the start of your message, Claude will automatically:

1. **Search** ClaudeBrain for the keywords you provide
2. **Start** a new session with those keywords as the goal
3. **Log** decisions and gotchas as we work together
4. **End** the session with a summary when we're done

## Examples

```
[brain] dashboard filters
```
↓
Claude searches for "dashboard filters" and starts session

```
[BRAIN] email notifications sendgrid
```
↓
Claude searches for "email notifications sendgrid" and starts session

```
[Brain] database migration
```
↓
Claude searches for "database migration" and starts session

---

**Note:** You don't need to run any commands yourself. Claude handles everything automatically using the Bash tool during the session.
