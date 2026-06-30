---
description: Get full details of a task by page ID. Use when user picks a task from a list or asks for task details.
---

# Get Task

## State

Database IDs ship with the plugin. Read them from the bundled config:

```bash
cat "$CLAUDE_PLUGIN_ROOT/.state/databases.json"   # { "databases": { ... } }
```

Read the Tasks `id` (a **data source ID**) from it.

## Steps

1. Call `mcp__notion__API-retrieve-a-page` with the page ID — extract all properties
2. Call `mcp__notion__API-get-block-children` with the page ID — get full page content
3. If any block has `has_children: true`, fetch its children recursively

## Output

Always show full content. Format as markdown:

```
# <title>

Status: X | Due: X | Energy: X | Context: X | My Day: ✓/✗

---

<full page content as markdown>
```

Map blocks: paragraph → text, headings → #/##/###, bullets → -, numbered → 1., to_do → checkboxes, code → fenced, quote → >, callout → > with icon.
