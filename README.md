Dotfiles managed by [chezmoi](https://github.com/twpayne/chezmoi). macOS only.

## Setup

```bash
git clone https://github.com/nozomemein/dotfiles.git ~/.local/share/chezmoi
cd ~/.local/share/chezmoi
bash setup.sh
```

## Commands

```
just                   # List all commands
just apply             # Apply chezmoi to home directory
just diff              # Show diff between source and destination
just update            # Pull latest and apply
```

### brew

```
just brew add minio          # Add brew package to Brewfile
just brew add cask firefox   # Add cask to Brewfile
just brew remove minio       # Remove package from Brewfile
just brew diff               # Show diff between installed and Brewfile
just brew apply              # Install from Brewfile and remove extras
```

### setup

```
just setup all          # Install all dev tools
just setup rust         # Rust via rustup
just setup bun          # Bun
just setup node         # Node.js via asdf
just setup claude-code  # Claude Code
just setup codex        # OpenAI Codex
```
