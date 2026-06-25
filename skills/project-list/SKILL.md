---
description: List and filter projects from Notion. Use for "my projects", "show projects", "what am I working on", "active projects", or any project listing request.
---

# List Projects

Read `.state/databases.json` for the Projects `id` (a data source ID). If missing, say to run `/agentic-mind-palace:setup`.

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
