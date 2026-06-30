---
description: Create a new task in Notion. Use when the user wants to add a task, says "create task", "add task", "new task", "remind me to", "I need to", or describes something that should become a task.
---

# Create Task

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
user to run `/agentic-mind-palace:setup`. Then read the Tasks `id` (a **data source ID**) from it.

## Process

1. Extract title from user intent
2. Infer properties from context (see inference rules below)
3. Apply default template for body content
4. Create page via `mcp__notion__API-post-page`
5. State what was created and what was inferred

## Inference Rules

| Property | Default | Override signal |
|----------|---------|----------------|
| Status | To Do | Always To Do on create |
| Energy | 🔋 Normal | "quick"/"simple" → ⚡ Low, "deep work"/"big"/"complex" → 🪫 High |
| Context | none | "deep work"/"write"/"design" → Focus, "email"/"admin"/"batch" → Maintenance, "fix"/"build"/physical → Hands, "buy"/"pick up"/errand → Outdoor, "call"/"text"/"approve" → Phone, "waiting on X" → People, "research"/"tinker" → Explore, "review"/"plan"/"triage" → Review |
| My Day | false | "today"/"now"/"this morning"/"right away" → true |
| Due | none | Parse explicit dates, "Friday", "next week", "EOD", "tomorrow" |
| Project | none | Infer from conversation context if working within a project |

If confidence is low on any inference, state what was chosen so user can correct.

## Body Template

Always apply this structure:

```markdown
## Objective

<one sentence: what does "done" look like>

## Steps

- [ ] <first action>
- [ ] ...

## Notes

<optional — leave empty if task is brief and objective + steps are sufficient>
```

Rules:
- Objective = clear done-criteria, not a restatement of the title
- Steps = concrete next actions as checkboxes
- Notes = context, links, blockers, references. Skip if nothing to add — do not pad with filler.

## API Call

Call `mcp__notion__API-post-page` with:

```json
{
  "parent": { "type": "data_source_id", "data_source_id": "<tasks_data_source_id>" },
  "icon": { "type": "icon", "icon": { "name": "hexagon-dashed", "color": "purple" } },
  "properties": {
    "Name": { "title": [{ "text": { "content": "<title>" } }] },
    "Status": { "status": { "name": "To Do" } },
    "Due": { "date": { "start": "<YYYY-MM-DD>" } },
    "Energy": { "select": { "name": "<⚡ Low|🔋 Normal|🪫 High>" } },
    "Context": { "select": { "name": "<Focus|Maintenance|Hands|Outdoor|Phone|People|Explore|Review>" } },
    "My Day": { "checkbox": <true|false> },
    "Project": { "relation": [{ "id": "<project_id>" }] }
  },
  "children": [<blocks>]
}
```

The Tasks `id` in the state file is a **data source ID** — pass it as `data_source_id`, not `database_id`, or the create fails with 404.

Omit properties that have no value (no due date = omit Due entirely).

Always set the page `icon` to the Tasks database default — the built-in `hexagon-dashed` icon in `purple`. Use the built-in icon, never an emoji.

## Output

After creating, confirm:
```
Created: <title> (id: <first-8-chars>)
Status: To Do | Due: <date> | Energy: <energy> | Context: <context>
Inferred: <list what was auto-set from context>
```
