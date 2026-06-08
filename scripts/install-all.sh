#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# AI Tools Install + Configure Script
# Reads keys.env for API keys and auto-configures all tools.
#
# Usage:
#   cp keys.env.example keys.env && chmod 600 keys.env
#   <edit keys.env with your values>
#   bash scripts/install-all.sh              # Install + configure everything
#   bash scripts/install-all.sh claude codex # Install specific tools only
#   bash scripts/install-all.sh configure    # Only configure (skip installs)
# ==============================================================================

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[0;33m'; NC='\033[0m'
info()  { echo -e "${GREEN}[INFO]${NC} $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
KEYS_FILE="$REPO_DIR/keys.env"
CONFIGS_DIR="$REPO_DIR/configs"

load_keys() {
    if [[ -f "$KEYS_FILE" ]]; then
        info "Loading keys from $KEYS_FILE"
        set -a; source "$KEYS_FILE"; set +a
    else
        warn "No keys.env found. Copy keys.env.example to keys.env and fill in values."
        warn "Tool configs will NOT be populated. Install-only mode."
    fi
}

write_config() { mkdir -p "$(dirname "$1")"; cat > "$1"; info "  Wrote $1"; }
has() { command -v "$1" &>/dev/null; }

ALL_TOOLS=(prerequisites claude codex copilot gemini ollama fcc kimi opencode cursor-agent multica onecli nanoclaw hermes configure)
if [[ $# -gt 0 ]]; then TOOLS=("$@"); else TOOLS=("${ALL_TOOLS[@]}"); fi

load_keys

# =====================================================================
# INSTALL FUNCTIONS
# =====================================================================

install_prerequisites() {
    info "Installing prerequisites..."
    if ! has node; then
        info "Installing nvm + Node.js..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
        source ~/.bashrc; nvm install --lts
    else info "Node.js $(node --version) already installed"; fi
    if ! has uv; then
        info "Installing uv..."; curl -LsSf https://astral.sh/uv/install.sh | sh; source ~/.bashrc
    else info "uv already installed"; fi
    if ! has docker; then
        info "Installing Docker..."; curl -fsSL https://get.docker.com | sh
        sudo usermod -aG docker "$USER"; warn "Log out/in for Docker group"
    else info "Docker already installed"; fi
}

install_claude()     { info "Installing Claude Code..."; has claude && { info "Already installed"; return; }; curl -fsSL https://claude.ai/install.sh | bash; info "Run 'claude login' to authenticate."; }
install_codex()      { info "Installing Codex CLI..."; has codex && { info "Already installed"; return; }; npm install -g @openai/codex; }
install_copilot()    { info "Installing Copilot CLI..."; has copilot && { info "Already installed"; return; }; npm install -g @github/copilot; info "Run 'copilot auth'."; }
install_gemini()     { info "Installing Gemini CLI..."; has gemini && { info "Already installed"; return; }; npm install -g @google/gemini-cli; }
install_ollama()     { info "Installing Ollama..."; has ollama && { info "Already installed"; return; }; curl -fsSL https://ollama.com/install.sh | sh; info "Pull a model: ollama pull glm-5.1:cloud"; }
install_fcc()        { info "Installing FCC..."; has free-claude-code && { info "Already installed"; return; }; uv tool install free-claude-code; }
install_kimi()       { info "Installing Kimi CLI..."; has kimi && { info "Already installed"; return; }; uv tool install kimi-cli; }
install_opencode()   { info "Installing OpenCode..."; [[ -f ~/.opencode/bin/opencode ]] && { info "Already installed"; return; }; curl -fsSL https://opencode.ai/install | bash; }
install_cursor-agent(){ info "Installing Cursor Agent..."; has agent && { info "Already installed"; return; }; curl https://cursor.com/install -fsS | bash; }
install_multica()    { info "Installing Multica..."; has multica && { info "Already installed"; return; }; curl -fsSL https://raw.githubusercontent.com/multica-ai/multica/main/scripts/install.sh | bash; }
install_onecli()     {
    info "Installing OneCLI..."
    docker ps --format '{{.Names}}' 2>/dev/null | grep -q '^onecli$' && { info "Already running"; return; }
    mkdir -p ~/.onecli
    if [[ -f "$CONFIGS_DIR/onecli/docker-compose.yml" ]]; then cp "$CONFIGS_DIR/onecli/docker-compose.yml" ~/.onecli/docker-compose.yml
    else curl -fsSL https://raw.githubusercontent.com/onecli/onecli/main/docker-compose.yml -o ~/.onecli/docker-compose.yml; fi
    cd ~/.onecli && docker compose up -d; info "App: http://localhost:10254";
}
install_nanoclaw()   { info "Installing NanoClaw v2..."; [[ -d ~/nanoclaw-v2 ]] && { info "Already cloned"; return; }; git clone https://github.com/nanocoai/nanoclaw.git ~/nanoclaw-v2; cd ~/nanoclaw-v2 && bash setup.sh; }
install_hermes()     { info "Installing Hermes Agent..."; has hermes && { info "Already installed"; return; }; curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash; info "Run 'hermes setup'."; }

# =====================================================================
# CONFIGURE — reads keys.env, writes all tool config files
# =====================================================================
install_configure() {
    source "$SCRIPT_DIR/configure.sh"
    configure
}

# =====================================================================
# MAIN
# =====================================================================
info "AI Tools Installer — targets: ${TOOLS[*]}"
echo ""

for tool in "${TOOLS[@]}"; do
    echo ""; info "===== $tool ====="
    "install_$tool" 2>/dev/null || error "Failed: $tool"
done

echo ""
info "===== Done ====="
echo ""
echo "Next steps:"
echo "  1. Authenticate: claude login | copilot auth | gemini"
echo "  2. Pull Ollama model: ollama pull glm-5.1:cloud"
echo "  3. Start NanoClaw: cd ~/nanoclaw-v2 && bash nanoclaw.sh"
echo "  4. Setup Hermes: hermes setup"