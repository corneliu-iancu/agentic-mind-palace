---
description: Update any property of an existing note. Use when the user wants to change the type, tags, projects, URL, importance, title, favorite, or archive a note. Triggers on "change", "set", "retag", "rename", "favorite", "archive", "add to project".
---

# Update Note

Read `.state/databases.json` for the Notes `id` (a data source ID). If missing, say to run `/agentic-mind-palace:setup`.

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
