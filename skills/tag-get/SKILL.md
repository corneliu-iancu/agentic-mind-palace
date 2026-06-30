---
description: Get full details of a tag by page ID. Use when the user picks a tag from a list or asks for a tag's details, scope, or what's filed under it.
---

# Get Tag

## State

Database IDs ship with the plugin. Read them from the bundled config:

```bash
cat "$CLAUDE_PLUGIN_ROOT/.state/databases.json"   # { "databases": { ... } }
```

Read the Tags `id` (a **data source ID**) from it.

## Steps

1. Call `mcp__notion__API-retrieve-a-page` with the page ID — extract all properties
2. Call `mcp__notion__API-get-block-children` with the page ID — get full page content
3. If any block has `has_children: true`, fetch its children recursively

## Output

Always show full content. Format as markdown:

```
# <name>

Type: X | Parent: <parent tag or —> | Favorite: ✓/✗
Notes: N

---

<full page content as markdown>
```

The count comes from the tag's `# Notes` formula property. Map blocks: paragraph → text, headings → #/##/###, bullets → -, numbered → 1., to_do → checkboxes, code → fenced, quote → >, callout → > with icon.
