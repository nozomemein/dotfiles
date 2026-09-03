#!/bin/bash
set -eu

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Put an already-installed Homebrew on PATH (fresh shells don't have it yet)
if ! command -v brew &>/dev/null; then
    for b in /opt/homebrew/bin/brew /usr/local/bin/brew; do
        if [[ -x "$b" ]]; then
            eval "$("$b" shellenv)"
            break
        fi
    done
fi

# Install Homebrew
if ! command -v brew &>/dev/null; then
    echo "==> Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    for b in /opt/homebrew/bin/brew /usr/local/bin/brew; do
        if [[ -x "$b" ]]; then
            eval "$("$b" shellenv)"
            break
        fi
    done
else
    echo "homebrew: $(brew --version | head -1)"
fi

# Install chezmoi and just
command -v chezmoi &>/dev/null || brew install chezmoi
command -v just &>/dev/null || brew install just

# Apply dotfiles first: later steps read files chezmoi deploys (~/.Brewfile etc.)
echo "==> Applying dotfiles..."
chezmoi apply --source "$SCRIPT_DIR"

# Install dev tools
echo "==> Installing dev tools..."
cd "$SCRIPT_DIR"
just setup all

echo "==> Done!"
