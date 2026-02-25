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

# Add a file to chezmoi
add path:
    chezmoi add {{ path }}

# Edit and apply a managed file
edit path:
    chezmoi edit --apply {{ path }}

# Pull latest and apply
update:
    chezmoi update

# Git status of dotfiles repo
status:
    chezmoi git -- status

# Commit and push dotfiles
push message:
    chezmoi git -- add -A
    chezmoi git -- commit -m "{{ message }}"
    chezmoi git -- push
