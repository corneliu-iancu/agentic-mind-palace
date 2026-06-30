---
description: Mark a task as done. Use when the user says "done", "complete", "finished", "mark done", "check off", or refers to completing a specific task.
---

# Complete Task

## State

Database IDs ship with the plugin. Read them from the bundled config:

```bash
cat "$CLAUDE_PLUGIN_ROOT/.state/databases.json"   # { "databases": { ... } }
```

Read the Tasks `id` (a **data source ID**) from it.

## Task Resolution

Find the task to complete using this priority:

1. **From context** — if tasks were recently listed in conversation, user says "the first one", "that one", "the PR task" → match from recent results
2. **By name/fuzzy match** — user names the task: "complete the meditation task" → search Tasks DB by title
3. **By ID** — user provides explicit page ID

If ambiguous (multiple matches), show candidates and ask which one.

## Action

Set Status → Done. Nothing else.

Call `mcp__notion__API-patch-page` with:

```json
{
  "page_id": "<task_page_id>",
  "properties": {
    "Status": { "status": { "name": "Done" } }
  }
}
```

## Output

```
✓ Done: <task title> (id: <first-8-chars>)
```
