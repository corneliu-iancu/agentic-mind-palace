---
description: List and filter notes from Notion. Use for "my notes", "show notes", "find notes about X", "untriaged notes", "favorite notes", or any note listing request.
---

# List Notes

## State

Database IDs ship with the plugin. Read them from the bundled config:

```bash
cat "$CLAUDE_PLUGIN_ROOT/.state/databases.json"   # { "databases": { ... } }
```

Read the Notes `id` (a **data source ID**) from it.

## Query

Call `mcp__notion__API-query-data-source` with the Notes data source ID. Pass `filter` and `sorts` at the **top level** (not nested under a `query` key).

Default: exclude archived (`Archive` checkbox = false), sort by `Last edited time` descending, limit 10.

### Filters

| Intent | Filter |
|--------|--------|
| by type | `Type` multi_select contains "<Meeting\|Journal\|Record\|Procedure\|Reference\|Plan>" |
| untyped / untriaged | `Type` multi_select is empty |
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
