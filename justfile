# chezmoi dotfiles management

# List available recipes
default:
    @just --list

# Dump Brewfile and track it with chezmoi
brew-dump:
    brew bundle dump --global --force
    chezmoi add ~/.Brewfile

# Show diff between installed packages and Brewfile
brew-diff:
    #!/usr/bin/env zsh
    echo "=== Missing (in Brewfile but not installed) ==="
    brew bundle check --global --verbose 2>&1 || true
    echo ""
    echo "=== Extra (installed but not in Brewfile) ==="
    brew bundle cleanup --global 2>&1 || true

# Install packages from Brewfile and remove extras
brew-apply:
    brew bundle --global --cleanup

# Apply chezmoi to home directory
apply:
    chezmoi apply

# Show diff between source and destination
diff:
    chezmoi diff
# Pull latest and apply
update:
    chezmoi update
