---
description: Mark a task as done. Use when the user says "done", "complete", "finished", "mark done", "check off", or refers to completing a specific task.
---

# Complete Task

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
user to run `/agentic-mind-palace:setup`. Then read the Tasks DB ID from it.

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
