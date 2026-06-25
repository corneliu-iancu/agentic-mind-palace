---
description: View and manage My Day tasks. Use when the user says "my day", "today's tasks", "what's on my plate", "show my day", "add to my day", "remove from my day", or wants to plan their day.
---

# My Day

Read `.state/databases.json` for the Tasks DB ID. If missing, say to run `/agentic-mind-palace:setup`.

## View My Day

Query tasks where My Day checkbox is true and Status is not Done/Archived.

Call `mcp__notion__API-query-data-source` with:

```json
{
  "data_source_id": "<tasks_db_id>",
  "query": {
    "filter": {
      "and": [
        { "property": "My day", "checkbox": { "equals": true } },
        { "property": "Status", "status": { "does_not_equal": "Done" } },
        { "property": "Status", "status": { "does_not_equal": "Archived" } }
      ]
    },
    "sorts": [
      { "property": "Importance", "direction": "ascending" },
      { "property": "Due", "direction": "ascending" }
    ]
  }
}
```

## Output

```
My Day — <count> tasks

[Status]  Title              Due: YYYY-MM-DD  Energy: X  Importance: X  (id: abc123)
[Status]  Title              Due: —           Energy: X  Importance: X  (id: def456)
```

If empty: "My Day is clear. Want to add tasks?"

## Add to My Day

When user says "add X to my day":

1. Resolve task (context > name > ID)
2. Call `mcp__notion__API-patch-page`:

```json
{
  "page_id": "<task_page_id>",
  "properties": {
    "My day": { "checkbox": true }
  }
}
```

3. Confirm: `Added to My Day: <title>`

## Remove from My Day

When user says "remove X from my day" or "done with X for today":

1. Resolve task
2. Set My Day → false
3. Confirm: `Removed from My Day: <title>`

## Suggestions

If user asks "what should I add?" or My Day is empty, suggest tasks based on:
- Overdue tasks (highest priority)
- Due today
- Status: To Do with Importance I
- Low energy tasks if it's late in the day
