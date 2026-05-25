---
description: Get full details of a single Notion task by its page ID. Use when the user wants to see task details, read task content, or refers to a specific task by ID. Also triggers after list-tasks when user picks a specific item.
---

# Get Task

Retrieve and display the full content of a single task page.

## Prerequisites

Read `.state/databases.json` from this plugin's root directory to confirm Tasks DB is configured.

If `.state/databases.json` is missing, tell the user to run `/n2c:setup` first.

## Process

### Step 1: Retrieve page properties

Call `mcp__notion__API-retrieve-a-page` with the task's page ID.

Extract and format properties:
- Title (from title property)
- Status
- Due date
- Energy
- Importance
- Location
- P-I (Process/Immersive)
- My Day (yes/no)
- Tags (resolve relation IDs to names if possible)

### Step 2: Retrieve page content

Call `mcp__notion__API-get-block-children` with the task's page ID.

### Step 3: Format output

Present as readable markdown:

```markdown
# Task: <title>

| Property   | Value        |
|------------|--------------|
| Status     | To Do        |
| Due        | 2026-05-28   |
| Energy     | High         |
| Importance | I            |
| My Day     | ✓            |
| Tags       | #quarterly   |

---

<page content rendered as markdown>
```

### Content block rendering

Map Notion block types to markdown:
- `paragraph` → plain text
- `heading_1/2/3` → `#/##/###`
- `bulleted_list_item` → `- item`
- `numbered_list_item` → `1. item`
- `to_do` → `- [ ] item` or `- [x] item`
- `code` → fenced code block with language
- `quote` → `> text`
- `callout` → `> <icon> text`
- `toggle` → `<summary>` (note: children may need separate fetch)
- `divider` → `---`

### Nested blocks

If a block has `has_children: true`, fetch its children with another `mcp__notion__API-get-block-children` call using the block ID. Render with appropriate indentation.

## Error handling

- Invalid page ID: "Task not found. Check the ID — you can get IDs from `/n2c:list-tasks`."
- Page exists but isn't in Tasks DB: show content anyway but note "This page isn't in your Tasks database."
