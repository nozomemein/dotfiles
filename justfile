# chezmoi dotfiles management

mod brew 'just/brew.just'
mod setup 'just/setup.just'

# List available recipes
default:
    @just --list --unsorted --list-submodules

# Apply chezmoi to home directory
apply:
    chezmoi apply

# Show diff between source and destination
diff:
    chezmoi diff
# Pull latest and apply
update:
    chezmoi update
