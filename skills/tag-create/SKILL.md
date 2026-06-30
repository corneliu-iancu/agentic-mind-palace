---
description: Create a new tag in Notion. Use when the user wants a new classification — says "create tag", "add tag", "new tag", "new area", "new resource", or names a category that doesn't exist yet when tagging a task or note.
---

# Create Tag

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
user to run `/agentic-mind-palace:setup`. Then read the Tags `id` (a **data source ID**) from it.

Tags are the classification layer — Areas, Resources, and Entities through which notes, tasks, and projects gain context. Before creating, check the tag doesn't already exist (use tag-list) to avoid duplicates.

## Process

1. Extract the tag name from user intent
2. Infer `Type` and other properties from context (see inference rules)
3. Create page via `mcp__notion__API-post-page`
4. State what was created and what was inferred

## Inference Rules

| Property | Default | Override signal |
|----------|---------|----------------|
| Type | Area | Ongoing responsibility/domain/life area ("Health", "Work") → Area · reusable material/topic/reference ("Python", "Recipes") → Resource · a specific person, place, org, or thing ("John Doe", "Acme Corp") → Entity |
| Description | none | A short phrase the user gives describing the tag's scope |
| Parent Tag | none | "under X" / "part of X" / a clear broader tag in context → resolve parent tag ID |
| Favorite | false | "favorite"/"pin"/"star" → true |

`Type` is a **status** property — exactly one of Area, Resource, Entity. If unclear, default to Area and say so.

## API Call

Call `mcp__notion__API-post-page` with:

```json
{
  "parent": { "type": "data_source_id", "data_source_id": "<tags_data_source_id>" },
  "icon": { "type": "icon", "icon": { "name": "tag", "color": "purple" } },
  "properties": {
    "Name": { "title": [{ "text": { "content": "<name>" } }] },
    "Type": { "status": { "name": "<Area|Resource|Entity>" } },
    "Description": { "rich_text": [{ "text": { "content": "<description>" } }] },
    "Parent Tag": { "relation": [{ "id": "<parent_tag_id>" }] },
    "Favorite": { "checkbox": <true|false> }
  }
}
```

The Tags `id` in the state file is a **data source ID** — pass it as `data_source_id`, not `database_id`, or the create fails with 404.

Omit properties that have no value.

Set the page `icon` to the built-in `tag` icon in `purple`. Use a built-in icon, never an emoji.

Do not set the `Notes` or `Sub-Tags` relations here — `Notes` is a back-reference populated from the note side, and `Sub-Tags` is the inverse of `Parent Tag`.

## Output

After creating, confirm:
```
Created tag: <name> (id: <first-8-chars>)
Type: <type> | Parent: <parent or —>
Inferred: <list what was auto-set from context>
```
