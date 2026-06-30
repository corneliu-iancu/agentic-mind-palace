---
description: Get full details of a project by page ID. Use when the user picks a project from a list or asks for a project's details, status, or its tasks.
---

# Get Project

Read `.state/databases.json` to confirm setup. If missing, say to run `/agentic-mind-palace:setup`.

## Steps

1. Call `mcp__notion__API-retrieve-a-page` with the page ID — extract all properties
2. Call `mcp__notion__API-get-block-children` with the page ID — get full page content
3. If any block has `has_children: true`, fetch its children recursively

## Output

Always show full content. Format as markdown:

```
# <project name>

Status: X | Dates: <range or —> | Favorite: ✓/✗
Tasks: N open · N done · N overdue

---

<full page content as markdown>
```

The task counts come from the project's rollup/formula properties (`# Open`, `# Done`, `Overdue Tasks Count`). If `Tasks Overview` (formula) is populated, you may surface it instead. Map blocks: paragraph → text, headings → #/##/###, bullets → -, numbered → 1., to_do → checkboxes, code → fenced, quote → >, callout → > with icon.
