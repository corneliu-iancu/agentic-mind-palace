---
description: List and filter notes from Notion. Use for "my notes", "show notes", "find notes about X", "untriaged notes", "favorite notes", or any note listing request.
---

# List Notes

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
