#!/bin/sh
# Claude Code status line — mirrors the pure prompt style
input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')
model=$(echo "$input" | jq -r '.model.display_name')
remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')

# Shorten home directory to ~
home="$HOME"
short_cwd="${cwd/#$home/\~}"

# Git branch (skip optional locks to avoid contention)
branch=""
if git -C "$cwd" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch=$(GIT_OPTIONAL_LOCKS=0 git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null \
           || GIT_OPTIONAL_LOCKS=0 git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
fi

# Build the status line
line="$short_cwd"
[ -n "$branch" ] && line="$line  $branch"
line="$line  $model"
[ -n "$remaining" ] && printf '%s  context: %s%%\n' "$line" "$remaining" && exit 0
printf '%s\n' "$line"
