---
description: Update any property of an existing task. Use when the user wants to change status, due date, energy, importance, location, tags, project, title, My Day, or P/I on a task. Triggers on "change", "set", "move", "reschedule", "bump", "push", "assign", "rename".
---

# Update Task

Read `.state/databases.json` for the Tasks DB ID. If missing, say to run `/agentic-mind-palace:setup`.

## Task Resolution

Same as complete-task — find by context > name > ID.

1. **From context** — match from recently listed tasks in conversation
2. **By name/fuzzy match** — search Tasks DB by title
3. **By ID** — explicit page ID

If ambiguous, show candidates and ask.

## Updatable Properties

| Property | API field | Values |
|----------|-----------|--------|
| Title | `Name` (title) | Any string |
| Status | `Status` (status) | To Do, Progress, Done, Archived |
| Due | `Due` (date) | YYYY-MM-DD, or null to clear |
| Energy | `Energy` (select) | Low, Normal, High |
| Location | `Location` (select) | Computer, Home, Errands, Office, Phone |
| Importance | `Importance` (select) | I, II, III |
| P/I | `P/I` (select) | Process, Immersive |
| My Day | `My day` (checkbox) | true, false |
| Tags | `Tags` (relation) | Array of tag page IDs |
| Project | `Project` (relation) | Array of project page IDs |

Not updatable: Task ID, Created time, Last edited time (system fields).

## Parsing User Intent

Map natural language to property changes:

- "move to progress" / "start working on" → Status: Progress
- "push to Monday" / "reschedule to next week" → Due: parsed date
- "set energy high" / "this is deep work" → Energy: High
- "add to my day" / "do today" → My Day: true
- "remove from my day" → My Day: false
- "clear the due date" / "no deadline" → Due: null
- "assign to project X" → Project: resolve project ID by name
- "tag with X" → Tags: resolve tag ID, append to existing

## API Call

Call `mcp__notion__API-patch-page` with:

```json
{
  "page_id": "<task_page_id>",
  "properties": {
    "<property>": <new_value>
  }
}
```

Only include properties being changed.

## Clearing a property

To clear a date: `"Due": { "date": null }`
To clear a select: `"Energy": { "select": null }`
To clear a relation: `"Tags": { "relation": [] }`

## Output

```
Updated: <task title> (id: <first-8-chars>)
  <property>: <old value> → <new value>
```

Show what changed. If multiple properties updated at once, list each.
