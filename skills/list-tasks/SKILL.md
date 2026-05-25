---
description: List and filter tasks from Notion. Use when the user wants to see their tasks, check what's due, review My Day items, or filter tasks by status, energy, importance, or other properties. Also triggers for "what should I work on", "my tasks", "what's due", "show me today's tasks".
---

# List Tasks

Query the Tasks database and return results in a compact, scannable format.

## Prerequisites

Read `.state/databases.json` from this plugin's root directory to get:
- `databases.tasks.id` — the Tasks database ID
- `databases.tasks.properties` — available properties and their types/options

If `.state/databases.json` is missing, tell the user to run `/n2c:setup` first.

## Building the query

Call `mcp__notion__API-query-data-source` with the Tasks database ID.

### Default behavior (no filters specified)

```json
{
  "data_source_id": "<tasks_db_id>",
  "query": {
    "filter": {
      "property": "Status",
      "status": { "does_not_equal": "Archived" }
    },
    "sorts": [{ "property": "Due", "direction": "ascending" }],
    "page_size": 10
  }
}
```

### Filter mapping

Map user intent to Notion filters:

| User says | Filter |
|-----------|--------|
| "my day" / "today's tasks" | `{ "property": "My Day", "checkbox": { "equals": true } }` |
| "due this week" | `{ "property": "Due", "date": { "on_or_before": "<end of week ISO>" } }` |
| "due today" | `{ "property": "Due", "date": { "equals": "<today ISO>" } }` |
| "overdue" | `{ "property": "Due", "date": { "before": "<today ISO>" } }` AND Status != Done |
| "in progress" | `{ "property": "Status", "status": { "equals": "Progress" } }` |
| "to do" / "not started" | `{ "property": "Status", "status": { "equals": "To Do" } }` |
| "high energy" | `{ "property": "Energy", "select": { "equals": "High" } }` |
| "important" / "priority" | `{ "property": "Importance", "select": { "equals": "I" } }` |
| "at computer" / "computer tasks" | `{ "property": "Location", "select": { "equals": "Computer" } }` |

### Combining filters

When user specifies multiple criteria, wrap in `{ "and": [...filters] }`.

Always exclude Archived unless user explicitly asks for archived tasks.

## Output format

Present results as compact one-liners:

```
[Status]  Title                    Due: YYYY-MM-DD  Energy: X  Tags: #tag1 #tag2  (id: abc-123)
```

Example:
```
[To Do]   Review Q1 report         Due: 2026-05-28  Energy: High   #quarterly  (id: 1a2b-3c4d)
[Progress] Fix login bug           Due: —           Energy: Low    #backend    (id: 5e6f-7g8h)
[To Do]   Call dentist             Due: 2026-05-26  Energy: Low    #errands    (id: 9i0j-1k2l)
```

Rules:
- Show page ID at end (truncated to first 8 chars if full UUID)
- `Due: —` if no due date
- Only show properties that have values
- Sort: overdue first (red if terminal supports), then by due date ascending
- Show count: "Showing 3 of 12 tasks matching filters"

## Pagination

If more than 10 results, show first 10 and say "X more — ask to see next page or narrow filters."

Store the `next_cursor` from the response for follow-up requests if user asks for more.
