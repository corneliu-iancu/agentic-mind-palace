---
description: Update any property of an existing task. Use when the user wants to change status, due date, energy, context, project, title, or My Day on a task. Triggers on "change", "set", "move", "reschedule", "bump", "push", "assign", "rename".
---

# Update Task

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

## Task Resolution

Same as task-complete — find by context > name > ID.

1. **From context** — match from recently listed tasks in conversation
2. **By name/fuzzy match** — search Tasks DB by title
3. **By ID** — explicit page ID

If ambiguous, show candidates and ask.

## Updatable Properties

| Property | API field | Values |
|----------|-----------|--------|
| Title | `Name` (title) | Any string |
| Status | `Status` (status) | To Do, Doing, Done, Archived |
| Due | `Due` (date) | YYYY-MM-DD, or null to clear |
| Energy | `Energy` (select) | ⚡ Low, 🔋 Normal, 🪫 High |
| Context | `Context` (select) | Focus, Maintenance, Hands, Outdoor, Phone, People, Explore, Review |
| My Day | `My Day` (checkbox) | true, false |
| Project | `Project` (relation) | Array of project page IDs |

Not updatable: Task ID, Created time, Last edited time (system fields).

## Parsing User Intent

Map natural language to property changes:

- "move to doing" / "start working on" → Status: Doing
- "push to Monday" / "reschedule to next week" → Due: parsed date
- "set energy high" / "this is deep work" → Energy: 🪫 High
- "needs focus" → Context: Focus, "it's an errand" → Context: Outdoor, "it's a call" → Context: Phone (see task-create for full Context signals)
- "add to my day" / "do today" → My Day: true
- "remove from my day" → My Day: false
- "clear the due date" / "no deadline" → Due: null
- "assign to project X" → Project: resolve project ID by name

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
To clear a relation: `"Project": { "relation": [] }`

## Output

```
Updated: <task title> (id: <first-8-chars>)
  <property>: <old value> → <new value>
```

Show what changed. If multiple properties updated at once, list each.
