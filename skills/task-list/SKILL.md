---
description: List and filter tasks from Notion. Use for "my tasks", "what's due", "show today", or any task listing request.
---

# List Tasks

## State

This skill needs the database IDs that `setup` discovered. Resolve the state file
the same way every skill does — via the shared resolver — then read from it:

```bash
STATE_FILE="$(bash "$CLAUDE_PLUGIN_ROOT/scripts/state-file.sh")"
[ -f "$STATE_FILE" ] || { echo "Not set up — run /agentic-mind-palace:setup"; exit 1; }
cat "$STATE_FILE"   # { "databases": { ... } }
```

`$CLAUDE_PLUGIN_ROOT` is the only anchor that is reliable inside a plugin
(`$CLAUDE_PROJECT_DIR` comes through empty here), and it is used only to *locate*
the resolver — the resolver itself stores the *data* outside the versioned plugin
directory so a version bump cannot orphan it. If the file is missing, tell the
user to run `/agentic-mind-palace:setup`. Then read the Tasks DB ID from it.

## Query

Call `mcp__notion__API-query-data-source` with the Tasks DB ID.

Default: exclude Archived, sort by Due ascending, limit 10.

### Filters

| Intent | Filter |
|--------|--------|
| my day | `My Day` checkbox = true |
| due today | `Due` date equals today |
| overdue | `Due` before today AND Status != Done |
| in progress | `Status` equals "Doing" |
| to do | `Status` equals "To Do" |
| high energy | `Energy` select equals "🪫 High" |

Combine with `{ "and": [...] }`. Always exclude Archived unless asked.

## Output

One line per task:
```
[Status]  Title          Due: YYYY-MM-DD  Energy: X  (id: first-8-chars)
```
