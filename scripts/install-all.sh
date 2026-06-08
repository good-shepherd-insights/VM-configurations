#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# AI Tools Install Script
# Repository: good-shepherd-insights/VM-configurations
#
# Installs all 13 AI tools on a fresh Ubuntu/Debian VM.
# Review each section before running — some tools require interactive auth.
#
# Usage:
#   bash scripts/install-all.sh              # Install everything
#   bash scripts/install-all.sh claude codex # Install specific tools only
# ==============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

info()  { echo -e "${GREEN}[INFO]${NC} $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; }

# All available tools
ALL_TOOLS=(prerequisites claude codex copilot gemini ollama fcc kimi opencode cursor-agent multica onecli nanoclaw hermes)

# If args given, only install those; otherwise install everything
if [[ $# -gt 0 ]]; then
    TOOLS=("$@")
else
    TOOLS=("${ALL_TOOLS[@]}")
fi

# ---- Prerequisites ----
install_prerequisites() {
    info "Installing prerequisites..."

    # nvm + Node.js
    if ! command -v node &>/dev/null; then
        info "Installing nvm + Node.js..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
        source ~/.bashrc
        nvm install --lts
    else
        info "Node.js $(node --version) already installed"
    fi

    # uv
    if ! command -v uv &>/dev/null; then
        info "Installing uv..."
        curl -LsSf https://astral.sh/uv/install.sh | sh
        source ~/.bashrc
    else
        info "uv $(uv --version) already installed"
    fi

    # Docker
    if ! command -v docker &>/dev/null; then
        info "Installing Docker..."
        curl -fsSL https://get.docker.com | sh
        sudo usermod -aG docker "$USER"
        warn "You may need to log out/in for Docker group to take effect"
    else
        info "Docker $(docker --version) already installed"
    fi
}

# ---- Tool 1: Claude Code ----
install_claude() {
    info "Installing Claude Code..."
    if command -v claude &>/dev/null; then
        info "Claude Code $(claude --version 2>/dev/null || echo 'already installed')"
        return
    fi
    curl -fsSL https://claude.ai/install.sh | bash
    info "Claude Code installed. Run 'claude login' to authenticate."
}

# ---- Tool 2: OpenAI Codex CLI ----
install_codex() {
    info "Installing OpenAI Codex CLI..."
    if command -v codex &>/dev/null; then
        info "Codex $(codex --version 2>/dev/null || echo 'already installed')"
        return
    fi
    npm install -g @openai/codex
    info "Codex installed. Set OPENAI_API_KEY environment variable."
}

# ---- Tool 3: GitHub Copilot CLI ----
install_copilot() {
    info "Installing GitHub Copilot CLI..."
    if command -v copilot &>/dev/null; then
        info "Copilot $(copilot --version 2>/dev/null || echo 'already installed')"
        return
    fi
    npm install -g @github/copilot
    info "Copilot installed. Run 'copilot auth' to authenticate."
}

# ---- Tool 4: Google Gemini CLI ----
install_gemini() {
    info "Installing Google Gemini CLI..."
    if command -v gemini &>/dev/null; then
        info "Gemini $(gemini --version 2>/dev/null || echo 'already installed')"
        return
    fi
    npm install -g @google/gemini-cli
    info "Gemini CLI installed. Run 'gemini' to authenticate with Google."
}

# ---- Tool 5: Ollama ----
install_ollama() {
    info "Installing Ollama..."
    if command -v ollama &>/dev/null; then
        info "Ollama $(ollama --version 2>/dev/null || echo 'already installed')"
        return
    fi
    curl -fsSL https://ollama.com/install.sh | sh
    info "Ollama installed and running as systemd service."
    info "Pull a model with: ollama pull glm-5.1:cloud"
}

# ---- Tool 6: Free Claude Code (FCC) ----
install_fcc() {
    info "Installing Free Claude Code (FCC)..."
    if command -v free-claude-code &>/dev/null; then
        info "FCC $(free-claude-code --version 2>/dev/null || echo 'already installed')"
        return
    fi
    uv tool install free-claude-code
    info "FCC installed. Run 'fcc-init' to configure, then copy configs/fcc/.env.example to ~/.fcc/.env"
}

# ---- Tool 7: Kimi CLI ----
install_kimi() {
    info "Installing Kimi CLI..."
    if command -v kimi &>/dev/null; then
        info "Kimi $(kimi --version 2>/dev/null || echo 'already installed')"
        return
    fi
    uv tool install kimi-cli
    info "Kimi installed. Copy configs/kimi/config.toml to ~/.kimi/config.toml and add API key."
}

# ---- Tool 8: OpenCode ----
install_opencode() {
    info "Installing OpenCode..."
    if command -v opencode &>/dev/null || [[ -f ~/.opencode/bin/opencode ]]; then
        info "OpenCode already installed"
        return
    fi
    curl -fsSL https://opencode.ai/install | bash
    info "OpenCode installed. Run 'opencode' to start."
}

# ---- Tool 9: Cursor Agent ----
install_cursor-agent() {
    info "Installing Cursor Agent..."
    if command -v agent &>/dev/null; then
        info "Cursor Agent $(agent --version 2>/dev/null || echo 'already installed')"
        return
    fi
    curl https://cursor.com/install -fsS | bash
    info "Cursor Agent installed. Uses your Cursor account credentials."
}

# ---- Tool 10: Multica ----
install_multica() {
    info "Installing Multica..."
    if command -v multica &>/dev/null; then
        info "Multica $(multica --version 2>/dev/null || echo 'already installed')"
        return
    fi
    curl -fsSL https://raw.githubusercontent.com/multica-ai/multica/main/scripts/install.sh | bash
    info "Multica installed. Run 'multica' to authenticate."
}

# ---- Tool 11: OneCLI ----
install_onecli() {
    info "Installing OneCLI..."
    if docker ps --format '{{.Names}}' | grep -q '^onecli$'; then
        info "OneCLI container already running"
        return
    fi
    mkdir -p ~/.onecli
    # Copy docker-compose.yml from this repo if available
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    if [[ -f "$SCRIPT_DIR/../configs/onecli/docker-compose.yml" ]]; then
        cp "$SCRIPT_DIR/../configs/onecli/docker-compose.yml" ~/.onecli/docker-compose.yml
    else
        curl -fsSL https://raw.githubusercontent.com/onecli/onecli/main/docker-compose.yml -o ~/.onecli/docker-compose.yml
    fi
    cd ~/.onecli
    docker compose up -d
    info "OneCLI started. App: http://localhost:10254, Gateway: http://localhost:10255"
}

# ---- Tool 12: NanoClaw v2 ----
install_nanoclaw() {
    info "Installing NanoClaw v2..."
    if [[ -d ~/nanoclaw-v2 ]]; then
        info "NanoClaw already cloned at ~/nanoclaw-v2"
        return
    fi
    git clone https://github.com/nanocoai/nanoclaw.git nanoclaw-v2
    cd ~/nanoclaw-v2
    bash setup.sh
    info "NanoClaw installed. Run 'cd ~/nanoclaw-v2 && bash nanoclaw.sh' to start."
}

# ---- Tool 13: Hermes Agent ----
install_hermes() {
    info "Installing Hermes Agent..."
    if command -v hermes &>/dev/null; then
        info "Hermes $(hermes --version 2>/dev/null || echo 'already installed')"
        return
    fi
    curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash
    info "Hermes installed. Run 'hermes setup' to configure."
}

# ---- Main ----
info "AI Tools Installer — installing: ${TOOLS[*]}"
echo ""

for tool in "${TOOLS[@]}"; do
    echo ""
    info "===== $tool ====="
    "install_$tool" 2>/dev/null || error "Failed to install $tool"
done

echo ""
info "===== Installation Complete ====="
echo ""
echo "Post-install steps:"
echo "  claude login           # Authenticate Claude Code"
echo "  copilot auth           # Authenticate GitHub Copilot"
echo "  fcc-init               # Set up Free Claude Code"
echo "  hermes setup           # Configure Hermes Agent"
echo "  ollama pull <model>    # Download an LLM model"
echo "  cd ~/nanoclaw-v2 && bash nanoclaw.sh  # Start NanoClaw"