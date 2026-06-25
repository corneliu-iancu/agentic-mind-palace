---
description: Create a new tag in Notion. Use when the user wants a new classification — says "create tag", "add tag", "new tag", "new area", "new resource", or names a category that doesn't exist yet when tagging a task or note.
---

# Create Tag

Read `.state/databases.json` for the Tags `id` (a data source ID). If missing, say to run `/agentic-mind-palace:setup`.

Tags are the classification layer — Areas, Resources, and Entities through which notes, tasks, and projects gain context. Before creating, check the tag doesn't already exist (use list-tags) to avoid duplicates.

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

The Tags `id` in `.state/databases.json` is a **data source ID** — pass it as `data_source_id`, not `database_id`, or the create fails with 404.

Omit properties that have no value.

Set the page `icon` to the built-in `tag` icon in `purple`. Use a built-in icon, never an emoji.

Do not set the `Tasks`, `Notes`, or `Projects` relations here — those are back-references populated from the task/note/project side.

## Output

After creating, confirm:
```
Created tag: <name> (id: <first-8-chars>)
Type: <type> | Parent: <parent or —>
Inferred: <list what was auto-set from context>
```
