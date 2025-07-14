# MCP Server Setup Script

Interactive setup for MCP servers with Claude Desktop and SuperClaude.

## Quick Start

```bash
chmod +x mcp_setup.sh
./mcp_setup.sh
```

## Requirements

- [Claude Code](https://claude.ai/code)
- [Node.js](https://nodejs.org/)
- [SuperClaude](https://github.com/NomenAK/SuperClaude) (recommended)

## How It Works

1. Run the script
2. Select servers by typing numbers + ENTER
3. Press ENTER alone to continue
4. Enter credentials if prompted

## Available Servers

**SuperClaude Core:**
- Context7 (--c7) - Documentation access
- Sequential (--seq) - Multi-step reasoning
- Magic (--magic) - UI components
- Puppeteer (--pup) - Browser automation

**Additional:**
- n8n - Workflow automation
- ClickUp - Project management
- Various documentation servers

## Quick Selection

Type `a` + ENTER to select all core servers.

## Example Usage (SuperClaude)

```bash
/design --api --seq --persona-architect
/build --react --magic --persona-frontend
/analyze --code --c7 --persona-mentor
```

## Files Created

- Environment: `~/.claude_mcp_env`
- Backups: `~/.claude_backups/`

## Troubleshooting

If script won't run:
```bash
bash ./mcp_setup.sh
```

Test your setup:
```bash
source ~/.claude_mcp_env
```

## Credits

- [SuperClaude](https://github.com/NomenAK/SuperClaude) by NomenAK
- [GitMCP.io](https://gitmcp.io) for repo conversion

## License

Unlicensed