# chezmoi dotfiles management

# List available recipes
default:
    @just --list

# Dump Brewfile and track it with chezmoi
brew-dump:
    brew bundle dump --global --force
    chezmoi add ~/.Brewfile

# Install packages from Brewfile
brew-install:
    brew bundle --global

# Apply chezmoi to home directory
apply:
    chezmoi apply

# Show diff between source and destination
diff:
    chezmoi diff
# Pull latest and apply
update:
    chezmoi update
