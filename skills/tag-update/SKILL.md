---
description: Update any property of an existing tag. Use when the user wants to change a tag's type, description, parent, title, favorite, or archive it. Triggers on "change", "set", "rename", "describe", "favorite", "archive", "nest under".
---

# Update Tag

## State

Database IDs ship with the plugin. Read them from the bundled config:

```bash
cat "$CLAUDE_PLUGIN_ROOT/.state/databases.json"   # { "databases": { ... } }
```

Read the Tags `id` (a **data source ID**) from it.

## Tag Resolution

Find the tag using this priority:

1. **From context** — match from recently listed tags in conversation
2. **By name/fuzzy match** — search Tags DB by title
3. **By ID** — explicit page ID

If ambiguous, show candidates and ask.

## Updatable Properties

| Property | API field | Values |
|----------|-----------|--------|
| Title | `Name` (title) | Any string |
| Type | `Type` (status) | Area, Resource, Entity |
| Description | `Description` (rich_text) | Any string, or empty to clear |
| Parent Tag | `Parent Tag` (relation) | Array of tag page IDs |
| Favorite | `Favorite` (checkbox) | true, false |
| Archive | `Archive` (checkbox) | true, false |

Not updatable: ID, the `# Notes` formula and other activity formulas, and the `Notes`/`Sub-Tags` relations — those are back-references set from the other side.

## Parsing User Intent

- "make it a resource" / "it's an area" → Type
- "describe it as X" → Description
- "nest under X" / "make it a child of X" → Parent Tag: resolve parent tag ID
- "favorite this" / "pin it" → Favorite: true
- "archive it" → Archive: true
- "rename to X" → Name

## API Call

Call `mcp__notion__API-patch-page` with:

```json
{
  "page_id": "<tag_page_id>",
  "properties": {
    "<property>": <new_value>
  }
}
```

Only include properties being changed.

## Clearing a property

To clear the description: `"Description": { "rich_text": [] }`
To clear the parent: `"Parent Tag": { "relation": [] }`

## Output

```
Updated tag: <name> (id: <first-8-chars>)
  <property>: <old value> → <new value>
```

Show what changed. If multiple properties updated at once, list each.
