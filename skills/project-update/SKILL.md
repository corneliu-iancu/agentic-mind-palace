---
description: Update any property of an existing project. Use when the user wants to change a project's status, dates, title, favorite, or archive/cancel it. Triggers on "change", "set", "rename", "reschedule", "mark done", "cancel", "archive", "favorite".
---

# Update Project

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
user to run `/agentic-mind-palace:setup`. Then read the Projects `id` (a **data source ID**) from it.

## Project Resolution

Find the project using this priority:

1. **From context** — match from recently listed projects in conversation
2. **By name/fuzzy match** — search Projects DB by title
3. **By ID** — explicit page ID

If ambiguous, show candidates and ask.

## Updatable Properties

| Property | API field | Values |
|----------|-----------|--------|
| Title | `Project name` (title) | Any string |
| Status | `Status` (status) | Prototype, Doing, Done, Canceled, Archived |
| Dates | `Dates` (date) | start and/or end (YYYY-MM-DD), or null to clear |
| Favorite | `Favorite` (checkbox) | true, false |
| Archive | `Archive` (checkbox) | true, false |

Not updatable: the `Tasks`/`Notes` relations (back-references set from the task/note side) and all rollup/formula counts.

The title property is **`Project name`**, not `Name`.

## Parsing User Intent

- "start it" / "now working on" → Status: Doing
- "mark done" / "ship it" / "finished" → Status: Done
- "cancel it" → Status: Canceled
- "reschedule to X" / "due by X" → Dates: parsed start/end
- "favorite this" / "pin it" → Favorite: true
- "archive it" → Archive: true (or Status: Archived if the user means the lifecycle state)
- "rename to X" → Project name

`Done`, `Canceled`, and `Archived` are all `Status` values; the `Archive` checkbox is separate (hides from default views). If the user says "archive", confirm which they mean if unclear — default to the `Status: Archived` state.

## API Call

Call `mcp__notion__API-patch-page` with:

```json
{
  "page_id": "<project_page_id>",
  "properties": {
    "<property>": <new_value>
  }
}
```

Only include properties being changed.

## Clearing a property

To clear the dates: `"Dates": { "date": null }`

## Output

```
Updated project: <name> (id: <first-8-chars>)
  <property>: <old value> → <new value>
```

Show what changed. If multiple properties updated at once, list each.
