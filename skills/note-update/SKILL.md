---
description: Update any property of an existing note. Use when the user wants to change the type, tags, projects, URL, importance, title, favorite, or archive a note. Triggers on "change", "set", "retag", "rename", "favorite", "archive", "add to project".
---

# Update Note

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
user to run `/agentic-mind-palace:setup`. Then read the Notes `id` (a **data source ID**) from it.

## Note Resolution

Find the note using this priority:

1. **From context** — match from recently listed notes in conversation
2. **By name/fuzzy match** — search Notes DB by title
3. **By ID** — explicit page ID

If ambiguous, show candidates and ask.

## Updatable Properties

| Property | API field | Values |
|----------|-----------|--------|
| Title | `Name` (title) | Any string |
| Type | `Type` (multi_select) | Meeting, Journal, Record, Procedure, Reference, Plan |
| Tags | `Tags` (relation) | Array of tag page IDs |
| Projects | `Projects` (relation) | Array of project page IDs |
| URL | `URL` (url) | Any URL, or null to clear |
| Importance | `Importance` (select) | I, II, III |
| Favorite | `Favorite` (checkbox) | true, false |
| Archive | `Archive` (checkbox) | true, false |

Not updatable: ID, Created time, Last edited time (system fields).

## Parsing User Intent

- "make it a reference" / "tag as a meeting" → Type (multi-select — replace or append as the user means)
- "tag with X" → Tags: resolve tag ID, append to existing
- "add to project X" → Projects: resolve project ID by name
- "set the link to X" / "clear the URL" → URL: value or null
- "mark important" → Importance: I
- "favorite this" / "pin it" → Favorite: true
- "archive it" → Archive: true
- "rename to X" → Name

## API Call

Call `mcp__notion__API-patch-page` with:

```json
{
  "page_id": "<note_page_id>",
  "properties": {
    "<property>": <new_value>
  }
}
```

Only include properties being changed.

## Clearing a property

To clear the URL: `"URL": { "url": null }`
To clear importance: `"Importance": { "select": null }`
To clear tags: `"Tags": { "relation": [] }`
To clear types: `"Type": { "multi_select": [] }`

## Output

```
Updated note: <title> (id: <first-8-chars>)
  <property>: <old value> → <new value>
```

Show what changed. If multiple properties updated at once, list each.
