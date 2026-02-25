# Run all setup tasks
all: rust bun node claude-code codex

# Install Rust via rustup
rust:
    #!/usr/bin/env zsh
    if command -v rustc &>/dev/null; then
        echo "rust: $(rustc --version)"
    else
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    fi

# Install Bun
bun:
    #!/usr/bin/env zsh
    if command -v bun &>/dev/null; then
        echo "bun: $(bun --version)"
    else
        curl -fsSL https://bun.com/install | bash
    fi

# Install Node.js via asdf
node:
    #!/usr/bin/env zsh
    if [[ "$(uname)" != "Darwin" ]]; then
        echo "Skipping: asdf + Node.js setup is macOS only"
        exit 0
    fi
    if ! command -v asdf &>/dev/null; then
        echo "asdf not found. Install it first (brew install asdf)"
        exit 1
    fi
    if ! asdf plugin list 2>/dev/null | grep -q nodejs; then
        asdf plugin add nodejs
    fi
    if command -v node &>/dev/null; then
        echo "node: $(node --version)"
    else
        asdf install nodejs latest
        asdf set --home nodejs latest
    fi

# Install Claude Code
claude-code:
    #!/usr/bin/env zsh
    if command -v claude &>/dev/null; then
        echo "claude-code: $(claude --version)"
    else
        curl -fsSL https://claude.ai/install.sh | bash
    fi

# Install OpenAI Codex via npm
codex:
    #!/usr/bin/env zsh
    if command -v codex &>/dev/null; then
        echo "codex: $(codex --version)"
    else
        npm i -g @openai/codex
    fi
