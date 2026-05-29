#!/bin/sh
# Disable macOS "Press and Hold" for VSCode.
#
# Without this, holding a key like `l` / `h` / `j` / `k` opens macOS's
# accent-character popup instead of repeating the keystroke — which breaks
# vim-style hjkl navigation in vscode-neovim (the popup intercepts the
# native key repeat). Neovim TUI bypasses macOS so it works without this
# tweak; VSCode uses the native input pipeline so it doesn't.
#
# Stored in ~/Library/Preferences/com.microsoft.VSCode.plist — persists
# across macOS reboots. Run-once: chezmoi only re-executes if this script
# changes.
#
# Reverse with: defaults delete com.microsoft.VSCode ApplePressAndHoldEnabled

if [ "$(uname)" = "Darwin" ]; then
  defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false
fi
