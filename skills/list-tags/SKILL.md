---
description: List and filter tags from Notion. Use for "my tags", "show tags", "what areas do I have", "list resources", "find tag X", or to resolve a tag name to an ID when tagging a task or note.
---

# List Tags

Read `.state/databases.json` for the Tags `id` (a data source ID). If missing, say to run `/agentic-mind-palace:setup`.

This is the lookup used by create-task, create-note, update-task, and update-note to resolve a tag name to its page ID.

## Query

Call `mcp__notion__API-query-data-source` with the Tags data source ID. Pass `filter` and `sorts` at the **top level** (not nested under a `query` key).

Default: exclude archived (`Archive` checkbox = false), sort by `Name` ascending, limit 20. Tags are a reference catalog — alphabetical is the useful order.

### Filters

| Intent | Filter |
|--------|--------|
| areas | `Type` status equals "Area" |
| resources | `Type` status equals "Resource" |
| entities | `Type` status equals "Entity" |
| favorites | `Favorite` checkbox = true |
| named X | filter `Name` title contains "X" (for ID resolution) |

Combine with `{ "and": [...] }`. Always exclude archived unless the user asks to include archived.

```json
{
  "data_source_id": "<tags_data_source_id>",
  "filter": {
    "and": [
      { "property": "Archive", "checkbox": { "equals": false } }
    ]
  },
  "sorts": [
    { "property": "Name", "direction": "ascending" }
  ]
}
```

## Output

One line per tag (`# Notes` / `# Todo` are formula counts — show when present):
```
[Type]  Name          Notes: N  Todo: N  (id: first-8-chars)
```

Mark favorites with a leading `★`. If empty: "No tags found."

When resolving a name to an ID for another skill, return the matching tag's full ID — not just the 8-char prefix.
