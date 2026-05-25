---
description: Discover and configure Notion workspace databases for PARA operations. Run this once to connect your Notion workspace, or re-run to refresh after schema changes. Use when the user says "setup", "configure notion", "discover databases", or when .state/databases.json is missing.
---

# Notion Workspace Setup

Discover the user's Notion databases and match them to PARA entities (Tasks, Notes, Tags, Projects).

## Prerequisites

- `NOTION_API_KEY` environment variable must be set
- Notion MCP server must be connected (this plugin ships .mcp.json for it)

## Process

### Step 1: List all databases

Call `mcp__notion__API-post-search` with:
```json
{
  "filter": { "property": "object", "value": "database" },
  "page_size": 100
}
```

### Step 2: Inspect each database

For each database returned, call `mcp__notion__API-retrieve-a-database` with its ID to get the full property schema.

### Step 3: Match against PARA signatures

Read the schema signature files from the `schemas/` directory in this plugin. Match databases by checking:

1. **Required properties** — DB must have these property names with matching types
2. **Optional properties** — presence increases confidence
3. **Confidence scoring** — high/medium/low based on match rules in schema file

For Tasks, the signature is:
- REQUIRED: `Status` (type: status) + `Due` (type: date)
- OPTIONAL: `Energy`, `My Day`, `Location`, `Importance`, `P-I`, `Tags`
- High confidence = required + 2 optional matches

### Step 4: Present findings to user

Show the user what you discovered:
```
Found databases:
  ✓ Tasks  → "Tasks" (id: abc-123)  [high confidence]
  ? Notes  → "Notes" (id: def-456)  [medium confidence]
  ✗ Tags   → not found
  ✗ Projects → not found
```

Ask user to confirm matches before saving. If ambiguous (multiple candidates), ask user to pick.

### Step 5: Save state

Write confirmed matches to `.state/databases.json` at the plugin root directory. Structure:

```json
{
  "discovered_at": "<ISO timestamp>",
  "databases": {
    "tasks": {
      "id": "<database-id>",
      "title": "<database title as shown in Notion>",
      "properties": {
        "<property_name>": {
          "id": "<property_id>",
          "type": "<property_type>",
          "options": ["<if select/multi_select, list options>"]
        }
      }
    }
  }
}
```

Include ALL properties from the database (not just matched ones) — skills need the full schema to build queries.

### Step 6: Confirm completion

Tell user:
- Which databases were mapped
- What skills are now available (`/n2c:list-tasks`, `/n2c:get-task`)
- How to re-run setup if workspace changes

## Error handling

- If no databases found: check that NOTION_API_KEY has correct permissions (needs "Read content" on relevant databases)
- If MCP not connected: tell user to check that the Notion MCP server is running (`/mcp` to check status)
- If .state/ directory doesn't exist: create it
