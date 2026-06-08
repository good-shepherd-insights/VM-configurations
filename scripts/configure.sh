#!/usr/bin/env bash
# =====================================================================
# CONFIGURE FUNCTION — reads keys.env and writes all tool configs
# =====================================================================
# This file is sourced by install-all.sh. Do not run standalone.
# All variables from keys.env are already loaded via load_keys().

configure() {
    info "===== Configuring tool configs from keys.env ====="

    # ---- Claude Code ----
    if [[ -n "${ANTHROPIC_API_KEY:-}" || -n "${CLAUDE_CUSTOM_BASE_URL:-}" ]]; then
        info "Configuring Claude Code..."
        mkdir -p ~/.claude ~/.config/claude
        if [[ -n "${ANTHROPIC_API_KEY:-}" ]]; then
            cat > ~/.claude/settings.json << 'EOF'
{
  "env": {
    "ANTHROPIC_API_KEY": ""
  }
}
EOF
            sed -i "s|\"ANTHROPIC_API_KEY\": \"\"|\"ANTHROPIC_API_KEY\": \"${ANTHROPIC_API_KEY}\"|" ~/.claude/settings.json
        elif [[ -n "${CLAUDE_CUSTOM_BASE_URL:-}" ]]; then
            cat > ~/.config/claude/config.toml << EOF
[anthropic]
base_url = "${CLAUDE_CUSTOM_BASE_URL}"
api_key = ""
auth_token = "${CLAUDE_CUSTOM_AUTH_TOKEN:-ollama}"

[model_defaults]
model = "glm-5.1:cloud"
EOF
            cat > ~/.claude/settings.json << 'EOF'
{
  "env": {
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "glm-5.1:cloud",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "glm-5.1:cloud"
  }
}
EOF
        fi
        info "  Wrote ~/.claude/settings.json and ~/.config/claude/config.toml"
    else warn "Claude Code: No ANTHROPIC_API_KEY or CLAUDE_CUSTOM_BASE_URL set. Skipping."; fi

    # ---- Codex ----
    if [[ -n "${OPENAI_API_KEY:-}" ]]; then
        info "Configuring Codex..."
        mkdir -p ~/.codex
        cat > ~/.codex/config.toml << EOF
model = "glm-5.1:cloud"
model_provider = "ollama-cloud"

[model_providers.ollama-cloud]
name = "Ollama Cloud"
base_url = "http://localhost:11434/v1"
wire_api = "responses"
EOF
        info "  Wrote ~/.codex/config.toml"
    else warn "Codex: No OPENAI_API_KEY set. Skipping."; fi

    # ---- Gemini ----
    if [[ -n "${GEMINI_API_KEY:-}" ]]; then
        info "Configuring Gemini CLI..."
        mkdir -p ~/.gemini
        cat > ~/.gemini/settings.json << 'EOF'
{
  "security": {
    "auth": {
      "selectedType": "oauth-personal"
    }
  }
}
EOF
        info "  Wrote ~/.gemini/settings.json (uses OAuth — GEMINI_API_KEY exported for env)"
    else warn "Gemini: No GEMINI_API_KEY set. Uses OAuth on first run."; fi

    # ---- FCC ----
    if [[ -n "${NVIDIA_NIM_API_KEY:-}" || -n "${OPENROUTER_API_KEY:-}" ]]; then
        info "Configuring FCC..."
        mkdir -p ~/.fcc
        if [[ -f "$CONFIGS_DIR/fcc/.env.example" ]]; then
            cp "$CONFIGS_DIR/fcc/.env.example" ~/.fcc/.env
            # Replace placeholders with actual values from keys.env
            for var in NVIDIA_NIM_API_KEY OPENROUTER_API_KEY MISTRAL_API_KEY CODESTRAL_API_KEY \
                       DEEPSEEK_API_KEY KIMI_API_KEY WAFER_API_KEY OPENCODE_API_KEY ZAI_API_KEY \
                       FIREWORKS_API_KEY GEMINI_API_KEY_FCC GROQ_API_KEY CEREBRAS_API_KEY \
                       HF_TOKEN FCC_ANTHROPIC_AUTH_TOKEN FCC_DISCORD_BOT_TOKEN FCC_TELEGRAM_BOT_TOKEN; do
                val="${!var:-}"
                if [[ -n "$val" ]]; then
                    sed -i "s|^${var}=.*|${var}=\"${val}\"|" ~/.fcc/.env 2>/dev/null || true
                fi
            done
            if [[ -n "${FCC_DEFAULT_MODEL:-}" ]]; then
                sed -i "s|^MODEL=.*|MODEL=\"${FCC_DEFAULT_MODEL}\"|" ~/.fcc/.env
            fi
            info "  Wrote ~/.fcc/.env"
        fi
    else warn "FCC: No provider keys set. Skipping."; fi

    # ---- Kimi ----
    if [[ -n "${KIMI_CLI_API_KEY:-}" ]]; then
        info "Configuring Kimi..."
        mkdir -p ~/.kimi
        if [[ -f "$CONFIGS_DIR/kimi/config.toml" ]]; then
            cp "$CONFIGS_DIR/kimi/config.toml" ~/.kimi/config.toml
            sed -i "s|api_key = \"<YOUR_OLLAMA_CLOUD_API_KEY>\"|api_key = \"${KIMI_CLI_API_KEY}\"|" ~/.kimi/config.toml
            info "  Wrote ~/.kimi/config.toml"
        fi
    else warn "Kimi: No KIMI_CLI_API_KEY set. Skipping."; fi

    # ---- Multica ----
    if [[ -n "${MULTICA_TOKEN:-}" ]]; then
        info "Configuring Multica..."
        mkdir -p ~/.multica
        cat > ~/.multica/config.json << EOF
{
  "server_url": "https://api.multica.ai",
  "app_url": "https://multica.ai",
  "workspace_id": "${MULTICA_WORKSPACE_ID:-}",
  "token": "${MULTICA_TOKEN}"
}
EOF
        info "  Wrote ~/.multica/config.json"
    else warn "Multica: No MULTICA_TOKEN set. Skipping."; fi

    # ---- OneCLI ----
    info "Configuring OneCLI..."
    mkdir -p ~/.onecli
    if [[ -f "$CONFIGS_DIR/onecli/docker-compose.yml" ]]; then
        cp "$CONFIGS_DIR/onecli/docker-compose.yml" ~/.onecli/docker-compose.yml
    fi
    cat > ~/.onecli/config.json << EOF
{
  "api-host": "http://${ONECLI_BIND_HOST:-127.0.0.1}:${ONECLI_APP_PORT:-10254}"
}
EOF
    # Write .env for docker-compose
    cat > ~/.onecli/.env << ENVEOF
ONECLI_VERSION=latest
POSTGRES_USER=${ONECLI_POSTGRES_USER:-onecli}
POSTGRES_PASSWORD=${ONECLI_POSTGRES_PASSWORD:-onecli}
POSTGRES_DB=${ONECLI_POSTGRES_DB:-onecli}
ONECLI_BIND_HOST=${ONECLI_BIND_HOST:-127.0.0.1}
ONECLI_APP_PORT=${ONECLI_APP_PORT:-10254}
ONECLI_GATEWAY_PORT=${ONECLI_GATEWAY_PORT:-10255}
NEXTAUTH_SECRET=${ONECLI_NEXTAUTH_SECRET:-}
ENVEOF
    info "  Wrote ~/.onecli/config.json and ~/.onecli/.env"

    # ---- NanoClaw ----
    info "Configuring NanoClaw..."
    if [[ -d ~/nanoclaw-v2 ]]; then
        cat > ~/nanoclaw-v2/.env << EOF
ONECLI_URL=${NANOCLAW_ONECLI_URL:-http://127.0.0.1:10254}
TZ=${NANOCLAW_TZ:-UTC}
EOF
        info "  Wrote ~/nanoclaw-v2/.env"
    else warn "NanoClaw: Not cloned yet. Run install_nanoclaw first."; fi

    # ---- Hermes ----
    if [[ -n "${HERMES_API_KEY:-}" ]]; then
        info "Configuring Hermes..."
        if [[ -f "$CONFIGS_DIR/hermes/config.yaml.example" ]]; then
            cp "$CONFIGS_DIR/hermes/config.yaml.example" ~/.hermes/config.yaml
            sed -i "s|<YOUR_FEATHERLESS_API_KEY>|${HERMES_API_KEY}|g" ~/.hermes/config.yaml
            if [[ -n "${HERMES_MODEL:-}" ]]; then sed -i "s|default: zai-org/GLM-5.1|default: ${HERMES_MODEL}|" ~/.hermes/config.yaml; fi
            if [[ -n "${HERMES_BASE_URL:-}" ]]; then sed -i "s|base_url: https://api.featherless.ai/v1|base_url: ${HERMES_BASE_URL}|" ~/.hermes/config.yaml; fi
            info "  Wrote ~/.hermes/config.yaml"
        fi
        if [[ -f "$CONFIGS_DIR/hermes/.env.example" ]]; then
            cp "$CONFIGS_DIR/hermes/.env.example" ~/.hermes/.env
            for var in OPENROUTER_API_KEY_HERMES GOOGLE_API_KEY OLLAMA_API_KEY GLM_API_KEY \
                       KIMI_API_KEY_HERMES ARCEEAI_API_KEY MINIMAX_API_KEY HF_TOKEN_HERMES \
                       OPENCODE_ZEN_API_KEY OPENCODE_GO_API_KEY HERMES_TELEGRAM_BOT_TOKEN \
                       HERMES_DISCORD_BOT_TOKEN HERMES_SLACK_BOT_TOKEN HERMES_SLACK_APP_TOKEN \
                       BROWSERBASE_API_KEY BROWSERBASE_PROJECT_ID EXA_API_KEY PARALLEL_API_KEY \
                       FIRECRAWL_API_KEY FAL_KEY GROQ_API_KEY_HERMES GITHUB_TOKEN; do
                val="${!var:-}"
                if [[ -n "$val" ]]; then
                    sed -i "s|^${var}=.*|${var}=${val}|" ~/.hermes/.env 2>/dev/null || true
                fi
            done
            info "  Wrote ~/.hermes/.env"
        fi
    else warn "Hermes: No HERMES_API_KEY set. Run 'hermes setup' manually."; fi

    # ---- Ollama (pull model if service is running) ----
    if has ollama && ollama list 2>/dev/null | grep -q "glm-5.1:cloud"; then
        info "Ollama model glm-5.1:cloud already pulled."
    elif has ollama; then
        info "Pulling Ollama model glm-5.1:cloud (this may take a while)..."
        ollama pull glm-5.1:cloud || warn "Ollama pull failed. Run manually: ollama pull glm-5.1:cloud"
    fi

    # ---- Export keys for current shell session ----
    info "Exporting key variables to current shell..."
    for var in ANTHROPIC_API_KEY OPENAI_API_KEY GEMINI_API_KEY OLLAMA_CLOUD_API_KEY \
               NVIDIA_NIM_API_KEY OPENROUTER_API_KEY KIMI_CLI_API_KEY \
               MULTICA_TOKEN HERMES_API_KEY; do
        val="${!var:-}"
        if [[ -n "$val" ]]; then export "$var=$val"; fi
    done

    info "===== Configuration complete ====="
}