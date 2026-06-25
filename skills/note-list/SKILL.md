---
description: List and filter notes from Notion. Use for "my notes", "show notes", "find notes about X", "what's in my inbox", "favorite notes", or any note listing request.
---

# List Notes

Read `.state/databases.json` for the Notes `id` (a data source ID). If missing, say to run `/agentic-mind-palace:setup`.

## Query

Call `mcp__notion__API-query-data-source` with the Notes data source ID. Pass `filter` and `sorts` at the **top level** (not nested under a `query` key).

Default: exclude archived (`Archive` checkbox = false), sort by `Last edited time` descending, limit 10.

### Filters

| Intent | Filter |
|--------|--------|
| inbox / untriaged | `Type` multi_select contains "Inbox" |
| by type | `Type` multi_select contains "<Reference\|Insight\|Procedure\|Record\|Annotation\|Plan>" |
| favorites | `Favorite` checkbox = true |
| important | `Importance` select equals "I" |
| about X | search title — use `mcp__notion__API-post-search` or filter `Name` title contains "X" |

Combine with `{ "and": [...] }`. Always exclude archived unless the user asks to include archived.

```json
{
  "data_source_id": "<notes_data_source_id>",
  "filter": {
    "and": [
      { "property": "Archive", "checkbox": { "equals": false } }
    ]
  },
  "sorts": [
    { "property": "Last edited time", "direction": "descending" }
  ]
}
```

## Output

One line per note (`Type` is multi-select — join multiple with `·`):
```
[Type]  Title          Tags: #x #y  Importance: X  (id: first-8-chars)
```

Omit `Importance:` when unset. Mark favorites with a leading `★`. If empty: "No notes found."
