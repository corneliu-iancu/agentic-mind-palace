# Agentic Mind Palace 🏰

PARA-powered Notion integration for Claude Code. Interact with tasks, notes, tags, and projects through natural language.

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

Add the marketplace, then install the plugin:

```
/plugin marketplace add corneliu-iancu/agentic-mind-palace
/plugin install agentic-mind-palace@corneliu-iancu
```

The marketplace is named `corneliu-iancu`; the plugin is `agentic-mind-palace`, hence the `@corneliu-iancu` suffix on install.

The database IDs and schema ship with the plugin (`.state/databases.json`), so there's no setup step — the skills work as soon as the plugin is installed and your integration can see the databases.

## Skills

Skills are named `<entity>-<action>`.

### Tasks
| Skill | Description |
|-------|-------------|
| `/agentic-mind-palace:task-list` | List/filter tasks (status, due date, energy, My Day, etc.) |
| `/agentic-mind-palace:task-get` | Get full task details and content by page ID |
| `/agentic-mind-palace:task-create` | Create task with inferred properties and default template |
| `/agentic-mind-palace:task-update` | Change any task property (status, due, energy, tags, etc.) |
| `/agentic-mind-palace:task-complete` | Mark a task as done |
| `/agentic-mind-palace:my-day` | View and manage today's focused tasks |

### Notes
| Skill | Description |
|-------|-------------|
| `/agentic-mind-palace:note-list` | List/filter notes (type, tag, favorite, importance) |
| `/agentic-mind-palace:note-get` | Get full note details and content by page ID |
| `/agentic-mind-palace:note-create` | Capture a note with inferred type and tags |
| `/agentic-mind-palace:note-update` | Change any note property, or archive it |

### Tags
| Skill | Description |
|-------|-------------|
| `/agentic-mind-palace:tag-list` | List/filter tags; resolves tag names to IDs for other skills |
| `/agentic-mind-palace:tag-get` | Get full tag details and content by page ID |
| `/agentic-mind-palace:tag-create` | Create a tag (Area, Resource, or Entity) |
| `/agentic-mind-palace:tag-update` | Change any tag property, or archive it |

### Projects
| Skill | Description |
|-------|-------------|
| `/agentic-mind-palace:project-list` | List/filter projects (active by default; status, favorites) |
| `/agentic-mind-palace:project-get` | Get full project details, content, and task counts |
| `/agentic-mind-palace:project-create` | Create a project with inferred status, dates, and tags |
| `/agentic-mind-palace:project-update` | Change any project property, or close/archive it |

## How it works

- Ships a `.mcp.json` that connects Claude to the Notion API
- Ships the workspace schema in `.state/databases.json` — the data source IDs and properties for Tasks, Notes, Projects, and Tags. Skills read it via `$CLAUDE_PLUGIN_ROOT/.state/databases.json`, so it travels with the plugin and works in every environment without a setup step
- Skills instruct Claude how to query and format Notion data
- Creation infers properties from conversation context (a task's energy/context, a note's type, a tag's classification)

> The bundled config pins this plugin to one workspace's databases. To use it with a different Notion workspace, replace the IDs in `.state/databases.json` with your own data source IDs.

## Roadmap

- [x] Task CRUD (list, get, create, update, complete)
- [x] My Day management
- [x] Notes CRUD (list, get, create, update)
- [x] Tags CRUD (list, get, create, update)
- [x] Projects CRUD (list, get, create, update)
- [ ] Daily briefing skill
- [ ] Smart search / knowledge retrieval
- [ ] Cross-system sync (Jira, GitHub)
