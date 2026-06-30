---
description: Discover Notion workspace databases for PARA operations. Run once to connect, or re-run after schema changes.
---

# Setup

Discover the user's Notion databases and match them to PARA entities, then persist
the result so every other skill can find it.

## Steps

1. Call `mcp__notion__API-post-search` with `{ "filter": { "property": "object", "value": "database" }, "page_size": 100 }`
2. For each DB, call `mcp__notion__API-retrieve-a-database` to get its properties
3. Match against the bundled schema. Reference it by plugin root, NOT a bare
   relative path (a bare path resolves against the current working directory and
   breaks when the session starts elsewhere):

   ```bash
   cat "$CLAUDE_PLUGIN_ROOT/schemas/tasks.json"
   ```

   The Tasks DB needs `Status` (type: status) + `Due` (type: date).
4. Show the user what was found and ask them to confirm.
5. Resolve the state path through the **shared resolver** — the same script every
   reader skill uses, so the writer and readers can never disagree — then write to it:

   ```bash
   STATE_FILE="$(bash "$CLAUDE_PLUGIN_ROOT/scripts/state-file.sh")"
   mkdir -p "$(dirname "$STATE_FILE")"
   cat > "$STATE_FILE" << 'JSON'
   {
     "discovered_at": "<ISO>",
     "databases": {
       "tasks":    { "id": "<data_source_id>", "title": "<name>", "properties": { ... } },
       "notes":    { "id": "<data_source_id>", "title": "<name>", "properties": { ... } },
       "projects": { "id": "<data_source_id>", "title": "<name>", "properties": { ... } },
       "tags":     { "id": "<data_source_id>", "title": "<name>", "properties": { ... } }
     }
   }
   JSON
   echo "Saved workspace config to: $STATE_FILE"
   ```

   Always echo the absolute path back so the user can see where it landed.

## Where the state lives, and why

The resolver (`scripts/state-file.sh`) picks the path in this order:

1. `$AGENTIC_MIND_PALACE_STATE` if set — explicit override.
2. An existing `.state/databases.json` found by walking up from the working
   directory — honors a project-local state you already have, nothing to migrate.
3. Otherwise a stable, version-independent user path:
   `${XDG_STATE_HOME:-$HOME/.local/state}/agentic-mind-palace/databases.json`.

The default deliberately does **not** live under `$CLAUDE_PLUGIN_ROOT`: that path
moves when the plugin version changes, which would orphan the config on every
upgrade. `$CLAUDE_PLUGIN_ROOT` is used only to *locate code* (this script, the
schemas) — never to *store data*. `$CLAUDE_PROJECT_DIR` is intentionally unused
because it comes through empty inside a plugin.

Because setup and every reader call the identical resolver, "run setup once" holds:
a later session re-resolves to the same file and skips discovery.

If MCP is not connected or no DBs are found, check `NOTION_API_KEY` permissions.
