---
description: Create a new project in Notion. Use when the user wants to start a project — says "create project", "new project", "start a project", or describes an outcome that coordinates multiple tasks over time.
---

# Create Project

Read `.state/databases.json` for the Projects `id` (a data source ID). If missing, say to run `/agentic-mind-palace:setup`.

A project is a system that moves an idea from intention to reality — it coordinates tasks, notes, and decisions toward a defined outcome. Unlike a task, it's not a single action. If the user describes one concrete action, suggest task-create instead.

## Process

1. Extract the project name from user intent
2. Infer `Status` and `Dates` from context (see inference rules)
3. Optionally apply the body template for an outcome + milestones
4. Create page via `mcp__notion__API-post-page`
5. State what was created and what was inferred

## Inference Rules

| Property | Default | Override signal |
|----------|---------|----------------|
| Status | Prototype | "actively working"/"in progress" → Doing, else Prototype on create |
| Dates | none | Parse a start and/or end date — "by end of Q3", "from Monday", "due Aug 15" |
| Favorite | false | "favorite"/"pin"/"star" → true |

`Status` is a **status** property — exactly one of Prototype, Doing, Done, Canceled, Archived.

If confidence is low on any inference, state what was chosen so the user can correct.

## Body Template

Apply this structure unless the user gives their own content:

```markdown
## Outcome

<one sentence: what does "done" look like for this project>

## Milestones

- [ ] <first milestone>
- [ ] ...

## Notes

<context, constraints, links — skip if nothing to add>
```

## API Call

Call `mcp__notion__API-post-page` with:

```json
{
  "parent": { "type": "data_source_id", "data_source_id": "<projects_data_source_id>" },
  "icon": { "type": "icon", "icon": { "name": "folder", "color": "purple" } },
  "properties": {
    "Project name": { "title": [{ "text": { "content": "<name>" } }] },
    "Status": { "status": { "name": "<Prototype|Doing|Done|Canceled|Archived>" } },
    "Dates": { "date": { "start": "<YYYY-MM-DD>", "end": "<YYYY-MM-DD>" } },
    "Favorite": { "checkbox": <true|false> }
  },
  "children": [<blocks>]
}
```

The title property is **`Project name`**, not `Name`.

The Projects `id` in `.state/databases.json` is a **data source ID** — pass it as `data_source_id`, not `database_id`, or the create fails with 404.

Omit properties that have no value. For a single date, include only `start` (drop `end`).

Set the page `icon` to the built-in `folder` icon in `purple`. Use a built-in icon, never an emoji.

Do not set the `Tasks` or `Notes` relations here — those are back-references populated from the task/note side.

## Output

After creating, confirm:
```
Created project: <name> (id: <first-8-chars>)
Status: <status> | Dates: <range or —>
Inferred: <list what was auto-set from context>
```
