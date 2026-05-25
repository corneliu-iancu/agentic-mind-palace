---
description: List and filter tasks from Notion. Use for "my tasks", "what's due", "show today", or any task listing request.
---

# List Tasks

Read `.state/databases.json` for the Tasks DB ID. If missing, say to run `/n2c:setup`.

## Query

Call `mcp__notion__API-query-data-source` with the Tasks DB ID.

Default: exclude Archived, sort by Due ascending, limit 10.

### Filters

| Intent | Filter |
|--------|--------|
| my day | `My Day` checkbox = true |
| due today | `Due` date equals today |
| overdue | `Due` before today AND Status != Done |
| in progress | `Status` equals "Progress" |
| to do | `Status` equals "To Do" |
| high energy | `Energy` select equals "High" |

Combine with `{ "and": [...] }`. Always exclude Archived unless asked.

## Output

One line per task:
```
[Status]  Title          Due: YYYY-MM-DD  Energy: X  (id: first-8-chars)
```
