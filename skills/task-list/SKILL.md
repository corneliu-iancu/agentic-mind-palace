---
description: List and filter tasks from Notion. Use for "my tasks", "what's due", "show today", or any task listing request.
---

# List Tasks

## State

Database IDs ship with the plugin. Read them from the bundled config:

```bash
cat "$CLAUDE_PLUGIN_ROOT/.state/databases.json"   # { "databases": { ... } }
```

Read the Tasks `id` (a **data source ID**) from it.

## Query

Call `mcp__notion__API-query-data-source` with the Tasks data source ID.

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
