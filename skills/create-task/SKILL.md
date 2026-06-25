---
description: Create a new task in Notion. Use when the user wants to add a task, says "create task", "add task", "new task", "remind me to", "I need to", or describes something that should become a task.
---

# Create Task

Read `.state/databases.json` for the Tasks DB ID. If missing, say to run `/agentic-mind-palace:setup`.

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
| Energy | Normal | "quick"/"simple" → Low, "deep work"/"big"/"complex" → High |
| Location | Computer | "call" → Phone, "buy"/"pick up" → Errands, "office" → Office, "at home" → Home |
| P-I | Process | "write"/"design"/"build"/"think"/"research" → Immersive |
| Importance | II | "urgent"/"critical"/"blocker" → I, "whenever"/"low priority"/"someday" → III |
| My Day | false | "today"/"now"/"this morning"/"right away" → true |
| Due | none | Parse explicit dates, "Friday", "next week", "EOD", "tomorrow" |
| Tags | Agentic tag only | Always include Agentic tag |
| Project | none | Infer from conversation context if working within a project |

Always include the Agentic tag: `36446185-8f28-813d-90b5-f43d166c6241`

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
  "parent": { "database_id": "<tasks_db_id>" },
  "properties": {
    "Name": { "title": [{ "text": { "content": "<title>" } }] },
    "Status": { "status": { "name": "To Do" } },
    "Due": { "date": { "start": "<YYYY-MM-DD>" } },
    "Energy": { "select": { "name": "<Low|Normal|High>" } },
    "Location": { "select": { "name": "<Computer|Home|Errands|Office|Phone>" } },
    "P/I": { "select": { "name": "<Process|Immersive>" } },
    "Importance": { "select": { "name": "<I|II|III>" } },
    "My day": { "checkbox": <true|false> },
    "Tags": { "relation": [{ "id": "<tag_id>" }] }
  },
  "children": [<blocks>]
}
```

Omit properties that have no value (no due date = omit Due entirely).

## Output

After creating, confirm:
```
Created: <title> (id: <first-8-chars>)
Status: To Do | Due: <date> | Energy: <energy> | Location: <location>
Inferred: <list what was auto-set from context>
```
