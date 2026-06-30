---
description: Create a new note in Notion. Use when the user wants to capture knowledge — says "create note", "add note", "new note", "save this", "jot down", "make a note", "bookmark this", or shares something worth keeping (an idea, link, reference, meeting log, procedure).
---

# Create Note

Read `.state/databases.json` for the Notes `id` (a data source ID). If missing, say to run `/agentic-mind-palace:setup`.

Notes are knowledge, not actions — there is no status lifecycle. Per the database's own rule: **every note should have at least one Tag** to define its nature.

## Process

1. Extract title from user intent
2. Infer properties from context (see inference rules below)
3. Capture the user's content as body blocks (preserve their structure — don't force a template)
4. Create page via `mcp__notion__API-post-page`
5. State what was created and what was inferred

## Inference Rules

| Property | Default | Override signal |
|----------|---------|----------------|
| Type | none | "for reference"/link/docs → Reference, "how to"/steps/recipe → Procedure, "meeting"/"call with" → Meeting, "journal"/"today I"/diary → Journal, log/"notes from"/decision/retro → Record, "plan for"/strategy/roadmap → Plan. A URL with no other signal → Reference. If no signal, leave Type unset and flag it |
| Tags | none | Infer from conversation context if a relevant tag exists. **If none found, flag it** — the note should have a tag |
| Projects | none | Infer if the note clearly belongs to a project in context |
| URL | none | Capture any link the user provides |
| Importance | none | "important"/"key"/"critical" → I, "useful" → II, otherwise leave unset |
| Favorite | false | "favorite"/"pin"/"star this" → true |

`Type` is multi-select — a note can be both `Reference` and `Plan`. Set all that apply.

If confidence is low on any inference, state what was chosen so the user can correct.

## Body Content

Capture what the user gave you as markdown blocks, preserving their structure (headings, lists, links, code). Do not impose a fixed template — a bookmark may have no body, a meeting log may be all bullets, an insight may be a paragraph.

If the user gave only a title (e.g. a bookmark), the body may be empty.

## API Call

Call `mcp__notion__API-post-page` with:

```json
{
  "parent": { "type": "data_source_id", "data_source_id": "<notes_data_source_id>" },
  "icon": { "type": "icon", "icon": { "name": "invitation", "color": "purple" } },
  "properties": {
    "Name": { "title": [{ "text": { "content": "<title>" } }] },
    "Type": { "multi_select": [{ "name": "<Meeting|Journal|Record|Procedure|Reference|Plan>" }] },
    "Tags": { "relation": [{ "id": "<tag_id>" }] },
    "Projects": { "relation": [{ "id": "<project_id>" }] },
    "URL": { "url": "<url>" },
    "Importance": { "select": { "name": "<I|II|III>" } },
    "Favorite": { "checkbox": <true|false> }
  },
  "children": [<blocks>]
}
```

The Notes `id` in `.state/databases.json` is a **data source ID** — pass it as `data_source_id`, not `database_id`, or the create fails with 404.

Omit properties that have no value (no URL = omit URL entirely).

Set the page `icon` to the built-in `invitation` icon in `purple`. Use a built-in icon, never an emoji.

## Output

After creating, confirm:
```
Created note: <title> (id: <first-8-chars>)
Type: <type> | Tags: <tags or none> | Importance: <importance or —>
Inferred: <list what was auto-set from context>
```

If no tag was set, add: `No tag set — this note should have at least one. Want me to add one?`
