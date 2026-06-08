# VM Configurations

AI tools installation and configuration reference for VM provisioning.

## Repository Structure

```
.
├── README.md                          # This file
├── keys.env.example                   # Single keys file — copy to keys.env, fill in values
├── install-plan.md                    # Full install script and instructions for all tools
├── configs/
│   ├── claude-code/
│   │   ├── settings.json              # Claude Code global settings
│   │   ├── settings.local.json        # Claude Code local permissions
│   │   └── config.toml                # Claude Code model/provider config (~/.config/claude/)
│   ├── codex/
│   │   └── config.toml                # OpenAI Codex CLI config
│   ├── copilot/
│   │   └── config.json                # GitHub Copilot CLI config
│   ├── gemini/
│   │   └── settings.json              # Google Gemini CLI settings
│   ├── ollama/
│   │   └── ollama.service             # Systemd service unit
│   ├── fcc/
│   │   └── .env.example               # Free Claude Code env template
│   ├── kimi/
│   │   └── config.toml                # Kimi CLI config
│   ├── opencode/
│   │   └── package.json               # OpenCode install metadata
│   ├── multica/
│   │   └── config.json.example        # Multica CLI config template
│   ├── onecli/
│   │   ├── docker-compose.yml         # OneCLI Docker Compose config
│   │   └── config.json.example        # OneCLI CLI config template
│   ├── nanoclaw/
│   │   ├── .env.example               # NanoClaw env template
│   │   └── .mcp.json                  # NanoClaw MCP servers config
│   └── hermes/
│       ├── config.yaml.example        # Hermes Agent config template
│       └── .env.example               # Hermes Agent env template
├── scripts/
│   └── install-all.sh                 # One-shot install script for all tools
└── versions.json                      # Pinned version numbers
```

## Tools Covered

| # | Tool | Version | Type |
|---|------|---------|------|
| 1 | Claude Code | 2.1.150 | AI Coding Agent |
| 2 | OpenAI Codex CLI | 0.133.0 | AI Coding Agent |
| 3 | GitHub Copilot CLI | 1.0.54 | AI Coding Assistant |
| 4 | Google Gemini CLI | 0.43.0 | AI Coding Agent |
| 5 | Ollama | 0.24.0 | Local LLM Server |
| 6 | Free Claude Code (FCC) | 2.0.0 | AI Coding Agent (free tier wrapper) |
| 7 | Kimi CLI | 1.44.0 | AI Chat Agent |
| 8 | OpenCode | 1.15.12 | AI Coding Agent (TUI) |
| 9 | Cursor Agent | 2026.05.24-dda726e | AI Coding Agent |
| 10 | Multica | 0.3.6 | Multi-Agent Project Management |
| 11 | OneCLI | 1.23.0 (server) / 2.2.0 (CLI) | AI Agent Runtime |
| 12 | NanoClaw v2 | 2.0.70 | Personal Claude Assistant |
| 13 | Hermes Agent | 0.15.1 | AI Agent Framework |

## Quick Start

1. Copy the keys template and fill in your values:
   ```bash
   cp keys.env.example keys.env
   chmod 600 keys.env
   # Edit keys.env — only fill in keys for tools you use
   ```

2. Run the install script (installs tools + auto-configures from keys.env):
   ```bash
   bash scripts/install-all.sh
   ```

3. Or install specific tools only:
   ```bash
   bash scripts/install-all.sh claude ollama hermes
   ```

4. Or re-run just the configuration (no installs):
   ```bash
   bash scripts/install-all.sh configure
   ```

See [install-plan.md](install-plan.md) for detailed per-tool instructions.

## Security Note

All configuration files in this repo have been sanitized — API keys, tokens, and secrets have been replaced with placeholders. Never commit real credentials.