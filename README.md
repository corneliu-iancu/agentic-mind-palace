# notion2claude

PARA-powered Notion integration for Claude Code. Discover your workspace schema and interact with tasks, notes, and projects through natural language.

## Setup

### 1. Set your Notion API key

Create an [internal integration](https://www.notion.so/profile/integrations) in Notion, then export the key:

```bash
export NOTION_API_KEY="ntn_..."
```

Add to your shell profile (`.zshrc`, `.bashrc`) for persistence.

### 2. Share databases with integration

In Notion, open each database you want to use (Tasks, Notes, etc.) and share it with your integration via the "..." menu → "Connections".

### 3. Install plugin

Add to your Claude Code settings (`~/.claude/settings.json`):

```json
{
  "extraKnownMarketplaces": {
    "notion2claude": {
      "source": {
        "source": "git",
        "url": "https://github.com/corneliu-iancu/notion2claude.git"
      }
    }
  }
}
```

Then enable in Claude Code: `/plugin install notion2claude`

### 4. Run setup

```
/n2c:setup
```

This discovers your databases and saves their schemas locally.

## Skills

| Skill | Description |
|-------|-------------|
| `/n2c:setup` | Discover workspace databases, match to PARA entities |
| `/n2c:list-tasks` | List/filter tasks (status, due date, energy, My Day, etc.) |
| `/n2c:get-task` | Get full task details and content by page ID |

## How it works

- Ships a `.mcp.json` that connects Claude to the Notion API
- Setup discovers your databases by matching property schemas against PARA patterns
- Skills instruct Claude how to query and format Notion data
- State is stored locally in `.state/databases.json` (gitignored)

## Roadmap

- [ ] Task CRUD (create, update, complete)
- [ ] Notes operations
- [ ] Tags/Projects operations
- [ ] Daily briefing skill
- [ ] Smart search / knowledge retrieval
- [ ] Cross-system sync (Jira, GitHub)
