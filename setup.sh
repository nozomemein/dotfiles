#!/bin/bash
set -eu

# Install Homebrew
if ! command -v brew &>/dev/null; then
    echo "==> Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if [[ "$(uname -m)" == "arm64" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
else
    echo "homebrew: $(brew --version | head -1)"
fi

# Install chezmoi and just
command -v chezmoi &>/dev/null || brew install chezmoi
command -v just &>/dev/null || brew install just

# Init and apply dotfiles
echo "==> Applying dotfiles..."
chezmoi init --apply --source "$PWD"

# Install dev tools
echo "==> Installing dev tools..."
just setup all

echo "==> Done!"
