# Agentic Mind Palace 🏰

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
    "agentic-mind-palace": {
      "source": {
        "source": "git",
        "url": "https://github.com/corneliu-iancu/agentic-mind-palace.git"
      }
    }
  }
}
```

Then enable in Claude Code: `/plugin install agentic-mind-palace`

### 4. Run setup

```
/agentic-mind-palace:setup
```

This discovers your databases and saves their schemas locally.

## Skills

### Setup
| Skill | Description |
|-------|-------------|
| `/agentic-mind-palace:setup` | Discover workspace databases, match to PARA entities |

### Tasks
| Skill | Description |
|-------|-------------|
| `/agentic-mind-palace:list-tasks` | List/filter tasks (status, due date, energy, My Day, etc.) |
| `/agentic-mind-palace:get-task` | Get full task details and content by page ID |
| `/agentic-mind-palace:create-task` | Create task with inferred properties and default template |
| `/agentic-mind-palace:update-task` | Change any task property (status, due, energy, tags, etc.) |
| `/agentic-mind-palace:complete-task` | Mark a task as done |
| `/agentic-mind-palace:my-day` | View and manage today's focused tasks |

## How it works

- Ships a `.mcp.json` that connects Claude to the Notion API
- Setup discovers your databases by matching property schemas against PARA patterns
- Skills instruct Claude how to query and format Notion data
- Task creation infers properties from context (energy, location, importance, P/I)
- State is stored locally in `.state/databases.json` (gitignored)

## Roadmap

- [x] Task read operations (list, get)
- [x] Task CRUD (create, update, complete)
- [x] My Day management
- [ ] Notes operations
- [ ] Tags/Projects operations
- [ ] Daily briefing skill
- [ ] Smart search / knowledge retrieval
- [ ] Cross-system sync (Jira, GitHub)
