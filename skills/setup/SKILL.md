---
description: Discover Notion workspace databases for PARA operations. Run once to connect, or re-run after schema changes.
---

# Setup

Discover user's Notion databases and match to PARA entities.

## Steps

1. Call `mcp__notion__API-post-search` with `{ "filter": { "property": "object", "value": "database" }, "page_size": 100 }`
2. For each DB, call `mcp__notion__API-retrieve-a-database` to get properties
3. Match against `schemas/tasks.json` — Tasks DB needs Status (type: status) + Due (type: date)
4. Show user what was found, ask to confirm
5. Save to `.state/databases.json`:

```json
{
  "discovered_at": "<ISO>",
  "databases": {
    "tasks": { "id": "<id>", "title": "<name>", "properties": { ... } }
  }
}
```

If MCP not connected or no DBs found, check `NOTION_API_KEY` permissions.
