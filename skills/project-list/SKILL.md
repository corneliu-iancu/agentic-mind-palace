---
description: List and filter projects from Notion. Use for "my projects", "show projects", "what am I working on", "active projects", or any project listing request.
---

# List Projects

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

## Query

Call `mcp__notion__API-query-data-source` with the Projects data source ID. Pass `filter` and `sorts` at the **top level** (not nested under a `query` key).

Default: exclude Done, Canceled, and Archived; sort by `Last edited time` descending; limit 10. The default view is what's live and in flight.

### Filters

| Intent | Filter |
|--------|--------|
| active / in flight | `Status` is "Prototype" or "Doing" (exclude Done/Canceled/Archived) |
| doing | `Status` status equals "Doing" |
| prototypes | `Status` status equals "Prototype" |
| done | `Status` status equals "Done" |
| favorites | `Favorite` checkbox = true |

Combine with `{ "and": [...] }` / `{ "or": [...] }`. To exclude the closed states, AND together `does_not_equal` "Done", "Canceled", "Archived".

```json
{
  "data_source_id": "<projects_data_source_id>",
  "filter": {
    "and": [
      { "property": "Status", "status": { "does_not_equal": "Done" } },
      { "property": "Status", "status": { "does_not_equal": "Canceled" } },
      { "property": "Status", "status": { "does_not_equal": "Archived" } }
    ]
  },
  "sorts": [
    { "property": "Last edited time", "direction": "descending" }
  ]
}
```

## Output

One line per project (`# Open` / `Overdue Tasks Count` come from rollup/formula props — show when present):
```
[Status]  Project name          Dates: YYYY-MM-DD → YYYY-MM-DD  Open: N  Overdue: N  (id: first-8-chars)
```

Use `Dates: —` when unset. Mark favorites with a leading `★`. If empty: "No projects found."
