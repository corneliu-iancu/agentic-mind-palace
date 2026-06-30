---
description: View and manage My Day tasks. Use when the user says "my day", "today's tasks", "what's on my plate", "show my day", "add to my day", "remove from my day", or wants to plan their day.
---

# My Day

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

## View My Day

Query tasks where My Day checkbox is true and Status is not Done/Archived.

Call `mcp__notion__API-query-data-source` with:

```json
{
  "data_source_id": "<tasks_db_id>",
  "query": {
    "filter": {
      "and": [
        { "property": "My Day", "checkbox": { "equals": true } },
        { "property": "Status", "status": { "does_not_equal": "Done" } },
        { "property": "Status", "status": { "does_not_equal": "Archived" } }
      ]
    },
    "sorts": [
      { "property": "Due", "direction": "ascending" }
    ]
  }
}
```

## Output

```
My Day — <count> tasks

[Status]  Title              Due: YYYY-MM-DD  Energy: X  Context: X  (id: abc123)
[Status]  Title              Due: —           Energy: X  Context: X  (id: def456)
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
    "My Day": { "checkbox": true }
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
- Status: To Do, soonest due first
- Low energy tasks if it's late in the day
