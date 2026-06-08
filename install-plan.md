# AI Tools Install Plan

Complete inventory and install instructions for all AI tools found on this VM.

---

## Prerequisites (install these first)

### 1. Node.js via nvm
```bash
# Install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
source ~/.bashrc

# Install Node.js
nvm install --lts
node --version   # should be v24.x+
```

### 2. uv (Python package manager)
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
source ~/.bashrc
uv --version
```

### 3. Docker + Docker Compose (for OneCLI, NanoClaw)
```bash
# Install Docker if not present
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER
newgrp docker
docker --version
```

### 4. Go (for building Multica from source, if needed)
```bash
# Only if building from source; the curl install script provides a prebuilt binary
sudo apt install -y golang-go
# OR use the official tarball:
# curl -fsSL https://go.dev/dl/go1.26.1.linux-amd64.tar.gz | sudo tar -C /usr/local -xzf -
```

---

## Tool Inventory (12 AI tools)

| # | Tool | Version | Type | Category |
|---|------|---------|------|----------|
| 1 | Claude Code | 2.1.150 | Native binary | AI Coding Agent |
| 2 | OpenAI Codex CLI | 0.133.0 | npm global | AI Coding Agent |
| 3 | GitHub Copilot CLI | 1.0.54 | npm global | AI Coding Assistant |
| 4 | Google Gemini CLI | 0.43.0 | npm global | AI Coding Agent |
| 5 | Ollama | 0.24.0 | Native binary + systemd | Local LLM Server |
| 6 | Free Claude Code (FCC) | 2.0.0 | Python/uv tool | AI Coding Agent (free tier wrapper) |
| 7 | Kimi CLI | 1.44.0 | Python/uv tool | AI Chat Agent |
| 8 | OpenCode | 1.15.12 | Native binary | AI Coding Agent (TUI) |
| 9 | Cursor Agent | 2026.05.24-dda726e | Native binary (bundle) | AI Coding Agent |
| 10 | Multica | 0.3.6 | Go binary | Multi-Agent Project Management |
| 11 | OneCLI | 1.23.0 (server) / 2.2.0 (CLI) | Docker + native binary | AI Agent Runtime |
| 12 | NanoClaw v2 | 2.0.70 | Git repo + Docker | Personal Claude Assistant |
| 13 | Hermes Agent | 0.15.1 | Git repo + Python venv | AI Agent Framework |

---

## Install Instructions

### Tool 1: Claude Code
**Official Anthropic CLI coding agent.**

```bash
curl -fsSL https://claude.ai/install.sh | bash
```
- Installs to: `~/.local/bin/claude` (symlink to `~/.local/share/claude/versions/<version>`)
- Config: `~/.claude/`, `~/.claude.json`
- Auth: `claude login` (requires Anthropic account / API key)
- Verify: `claude --version`

---

### Tool 2: OpenAI Codex CLI
**OpenAI's terminal coding agent.**

```bash
npm install -g @openai/codex
```
- Installs to: `~/.nvm/versions/node/<version>/bin/codex`
- Config: `~/.codex/`
- Auth: Set `OPENAI_API_KEY` environment variable
- Verify: `codex --version`

---

### Tool 3: GitHub Copilot CLI
**GitHub's AI-powered CLI assistant.**

```bash
npm install -g @github/copilot
```
- Installs to: `~/.nvm/versions/node/<version>/bin/copilot`
- Auth: `copilot auth` (requires GitHub account with Copilot subscription)
- Verify: `copilot --version`
- Note: Requires active GitHub Copilot subscription

---

### Tool 4: Google Gemini CLI
**Google's open-source AI coding agent.**

```bash
npm install -g @google/gemini-cli
```
- Installs to: `~/.nvm/versions/node/<version>/bin/gemini`
- Config: `~/.gemini/`
- Auth: Sign in with Google on first run, or set `GEMINI_API_KEY`
- Verify: `gemini --version`
- Source: https://github.com/google-gemini/gemini-cli

---

### Tool 5: Ollama
**Run LLMs locally.**

```bash
curl -fsSL https://ollama.com/install.sh | sh
```
- Installs to: `/usr/local/bin/ollama`
- Creates systemd service: `ollama.service` (auto-starts)
- Config: System-level service, data in `/usr/share/ollama/.ollama`
- To pin version: `OLLAMA_VERSION=0.24.0 curl -fsSL https://ollama.com/install.sh | sh`
- To pull a model: `ollama pull glm-5.1:cloud` (or any other model)
- Verify: `ollama --version` and `ollama list`

---

### Tool 6: Free Claude Code (FCC)
**Free-tier wrapper around Claude Code.**

```bash
uv tool install free-claude-code
```
- Installs to: `~/.local/bin/fcc-claude`, `~/.local/bin/fcc-init`, `~/.local/bin/fcc-server`
- Data: `~/.local/share/uv/tools/free-claude-code/`
- Config: `~/.fcc/.env` (set up with `fcc-init`)
- The FCC server runs as a background process
- Source: https://github.com/Alishahryar1/free-claude-code
- Verify: `free-claude-code --version`

---

### Tool 7: Kimi CLI
**Kimi AI chat agent by Moonshot AI.**

```bash
uv tool install kimi-cli
```
- Installs to: `~/.local/bin/kimi`, `~/.local/bin/kimi-cli`
- Data: `~/.local/share/uv/tools/kimi-cli/`
- Config: `~/.kimi/config.toml`
- Auth: Requires Moonshot AI / Kimi API key
- Verify: `kimi --version`

---

### Tool 8: OpenCode
**Terminal-based AI coding agent with TUI.**

```bash
curl -fsSL https://opencode.ai/install | bash
```
- Installs to: `~/.opencode/bin/opencode`
- The binary is a self-contained ELF (~145MB, bundles Node.js runtime)
- Config: `~/.opencode/`, project-level `.opencode.json`
- Auth: Configured per-provider in settings (supports Claude, GPT, etc.)
- Verify: `opencode --version`

---

### Tool 9: Cursor Agent
**Cursor editor's headless CLI agent.**

```bash
curl https://cursor.com/install -fsS | bash
```
- Installs to: `~/.local/bin/agent` (symlink to `~/.local/share/cursor-agent/versions/<version>/cursor-agent`)
- The binary is a bash wrapper that sets `CURSOR_INVOKED_AS` and delegates to a bundled Node.js runtime
- Config: `~/.local/share/cursor-agent/`
- Auth: Uses Cursor account credentials
- Verify: `agent --version`

---

### Tool 10: Multica
**Multi-agent project management CLI (Go-based).**

```bash
curl -fsSL https://raw.githubusercontent.com/multica-ai/multica/main/scripts/install.sh | bash
```
- Installs to: `/usr/local/bin/multica`
- Prebuilt Go binary ( linux/amd64)
- Go module: `github.com/multica-ai/multica`
- Commands: agent, issue, project, workspace, squad, skill, autopilot, runtime, daemon
- Verify: `multica --version`

---

### Tool 11: OneCLI
**AI agent runtime with web UI and gateway.**

**Option A: Docker Compose (recommended for server)**

```bash
# Create OneCLI directory
mkdir -p ~/.onecli && cd ~/.onecli

# Download docker-compose.yml
curl -fsSL https://raw.githubusercontent.com/onecli/onecli/main/docker-compose.yml -o docker-compose.yml

# Create .env file (edit with your API keys)
cat > .env << 'EOF'
ONECLI_VERSION=latest
POSTGRES_USER=onecli
POSTGRES_PASSWORD=onecli
POSTGRES_DB=onecli
NEXTAUTH_SECRET=$(openssl rand -hex 32)
EOF

# Start services
docker compose up -d
```
- App UI: http://localhost:10254
- Gateway API: http://localhost:10255
- PostgreSQL: localhost:5432

**Option B: Standalone CLI binary**

The standalone binary at `~/.local/bin/onecli` (8.4MB) can be downloaded separately.
Check https://github.com/onecli/onecli for release binaries.

- Verify (Docker): `curl http://localhost:10254/health`
- Verify (CLI): `onecli --version`

---

### Tool 12: NanoClaw v2
**Personal Claude assistant with Docker containers.**

```bash
# Clone the repo
git clone https://github.com/nanocoai/nanoclaw.git nanoclaw-v2
cd nanoclaw-v2

# Run the setup script (interactive)
bash setup.sh

# OR launch directly
bash nanoclaw.sh
```
- Installs to: `~/nanoclaw-v2/`
- Requires: Node.js, pnpm, Docker
- Setup handles: Node.js/pnpm installation, Docker build, channel adapters
- CLI: `~/nanoclaw-v2/bin/ncl` (symlinked to `~/.local/bin/ncl`)
- Config: `~/nanoclaw-v2/data/`, per-group `~/nanoclaw-v2/groups/`
- Service (Linux): `systemctl --user restart nanoclaw-v2-ed4e884b`
- Verify: `ncl help`
- Source: https://github.com/nanocoai/nanoclaw

---

### Tool 13: Hermes Agent
**AI agent framework with multi-platform gateway.**

```bash
curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash
```
- Installs to: `~/.hermes/hermes-agent/`
- CLI: `~/.local/bin/hermes` (shell wrapper pointing to venv)
- Setup wizard: `hermes setup` (configures providers, API keys, channels)
- Config: `~/.hermes/config.yaml`, `~/.hermes/.env`
- Skills: `~/.hermes/skills/`
- Logs: `~/.hermes/logs/`
- Verify: `hermes --version`
- Source: https://github.com/NousResearch/hermes-agent

---

## Full Install Script (all tools in one go)

> **Warning:** Review each command before running. Some tools require interactive auth or API keys.

```bash
#!/usr/bin/env bash
set -euo pipefail

echo "=== Installing AI Tools ==="

# ---- Prerequisites ----
echo "[1/16] Installing nvm + Node.js..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
source ~/.bashrc
nvm install --lts

echo "[2/16] Installing uv..."
curl -LsSf https://astral.sh/uv/install.sh | sh
source ~/.bashrc

echo "[3/16] Installing Docker (if not present)..."
if ! command -v docker &>/dev/null; then
  curl -fsSL https://get.docker.com | sh
  sudo usermod -aG docker $USER
fi

# ---- AI Tools ----
echo "[4/16] Installing Claude Code..."
curl -fsSL https://claude.ai/install.sh | bash

echo "[5/16] Installing OpenAI Codex CLI..."
npm install -g @openai/codex

echo "[6/16] Installing GitHub Copilot CLI..."
npm install -g @github/copilot

echo "[7/16] Installing Google Gemini CLI..."
npm install -g @google/gemini-cli

echo "[8/16] Installing Ollama..."
curl -fsSL https://ollama.com/install.sh | sh

echo "[9/16] Installing Free Claude Code (FCC)..."
uv tool install free-claude-code

echo "[10/16] Installing Kimi CLI..."
uv tool install kimi-cli

echo "[11/16] Installing OpenCode..."
curl -fsSL https://opencode.ai/install | bash

echo "[12/16] Installing Cursor Agent..."
curl https://cursor.com/install -fsS | bash

echo "[13/16] Installing Multica..."
curl -fsSL https://raw.githubusercontent.com/multica-ai/multica/main/scripts/install.sh | bash

echo "[14/16] Installing OneCLI..."
mkdir -p ~/.onecli && cd ~/.onecli
curl -fsSL https://raw.githubusercontent.com/onecli/onecli/main/docker-compose.yml -o docker-compose.yml
docker compose up -d
cd ~

echo "[15/16] Installing NanoClaw v2..."
git clone https://github.com/nanocoai/nanoclaw.git nanoclaw-v2
cd nanoclaw-v2
bash setup.sh
cd ~

echo "[16/16] Installing Hermes Agent..."
curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash

echo ""
echo "=== All AI tools installed! ==="
echo ""
echo "Post-install steps:"
echo "  - claude login          # Authenticate Claude Code"
echo "  - copilot auth          # Authenticate GitHub Copilot"
echo "  - fcc-init              # Set up Free Claude Code"
echo "  - hermes setup          # Configure Hermes Agent"
echo "  - ollama pull <model>   # Download an LLM model"
echo "  - cd ~/nanoclaw-v2 && bash nanoclaw.sh  # Start NanoClaw"
```

---

## Non-AI Tool Found: Fresh Editor

Also found on the system: **Fresh** (v0.3.8) — a terminal-based text editor with LSP support. This is a general-purpose editor, not an AI tool, but installed via:

```bash
curl https://raw.githubusercontent.com/sinelaw/fresh/refs/heads/master/scripts/install.sh | sh
```

Installs to: `/usr/bin/fresh` (deb package: `fresh-editor`)