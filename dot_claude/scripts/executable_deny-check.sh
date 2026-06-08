#!/usr/bin/env bash
set -euo pipefail

# Claude Code PreToolUse Hook: Bash command validator.
# Hooks fire even in bypass-permission mode, so this is the real barrier.
# Fail-closed: any parse error blocks the command.

SETTINGS_FILE="$HOME/.claude/settings.json"

emit_error() {
  jq -cn --arg error "🚫 Blocked: $1" '{error:$error}'
}

INPUT=$(cat)

if ! TOOL_NAME=$(printf '%s' "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null); then
  emit_error "invalid hook input JSON"
  exit 2
fi

if ! COMMAND=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null); then
  emit_error "invalid hook input JSON"
  exit 2
fi

if [[ "$TOOL_NAME" != "Bash" ]]; then
  exit 0
fi
if [[ -z "$COMMAND" ]]; then
  exit 0
fi

# ---- Normalization helpers ----
# Collapse tabs / newlines / runs of spaces into a single space.
normalize_shell_text() {
  printf '%s' "$1" | tr '\n\t\r' '   ' | sed -E 's/[[:space:]]+/ /g; s/^ //; s/ $//'
}

# Simple quote stripping (for detection only).
strip_shell_quotes() {
  printf '%s' "$1" | tr -d "\"'"
}

block() {
  local part="$1"
  local reason="$2"
  emit_error "$part ($reason)"
  exit 2
}

grep_re() {
  local regex="$1"
  local text="$2"
  grep -Eiq -- "$regex" <<< "$text"
}

# Split by &&, ||, ; into logical sections and normalize each.
IFS=$'\n'
CMD_PARTS=$(printf '%s' "$COMMAND" | sed 's/&&/\n/g; s/||/\n/g; s/;/\n/g' | while IFS= read -r line; do normalize_shell_text "$line"; done)
NORMALIZED_COMMAND=$(normalize_shell_text "$COMMAND")
SCAN_COMMAND=$(strip_shell_quotes "$NORMALIZED_COMMAND")

# ---- (1) prefix-match against settings.json deny patterns ----
# Mimic Claude Code's prefix-wildcard semantics:
#   "Bash(foo *)" should also match the bare "foo" (trailing " *" → ([[:space:]]+.*)?).
match_pattern() {
  local cmd="$1"
  local pattern="$2"

  [[ "$pattern" =~ ^Bash\((.+)\)$ ]] || return 1
  local inner
  inner=$(normalize_shell_text "${BASH_REMATCH[1]}")

  # Escape regex metacharacters (* is expanded later; also escape \ [ ]).
  local escaped
  escaped=$(printf '%s' "$inner" | sed -E 's/[][\\.^$()+?{}|]/\\&/g')

  local regex
  if [[ "$escaped" == *" *" ]]; then
    local body="${escaped% \*}"
    body=$(printf '%s' "$body" | sed -E 's/[[:space:]]+/[[:space:]]+/g; s/\*/.*/g')
    regex="${body}([[:space:]]+.*)?"
  else
    regex=$(printf '%s' "$escaped" | sed -E 's/[[:space:]]+/[[:space:]]+/g; s/\*/.*/g')
  fi

  local norm_cmd
  norm_cmd=$(strip_shell_quotes "$(normalize_shell_text "$cmd")")
  grep -qE -- "^${regex}$" <<< "$norm_cmd"
}

if [[ -f "$SETTINGS_FILE" ]]; then
  if ! DENY_PATTERNS=$(jq -r '.permissions.deny[]? // empty' "$SETTINGS_FILE" 2>/dev/null); then
    block "$SETTINGS_FILE" "settings.json parse error"
  fi

  if [[ -n "$DENY_PATTERNS" ]]; then
    for part in $CMD_PARTS; do
      [[ -z "$part" ]] && continue
      while IFS= read -r pattern; do
        [[ -z "$pattern" ]] && continue
        if match_pattern "$part" "$pattern"; then
          block "$part" "pattern: $pattern"
        fi
      done <<< "$DENY_PATTERNS"
    done
  fi
fi

# ---- (2) Scan the raw command for dangerous syntax ----
# Covers: pipe / command substitution / eval / bash -c / xargs /
# absolute path / wrapper invocation / dynamic subcommand.
# (gh api's HTTP method check goes here too because flag order is arbitrary.)
scan_raw_bypass_rules() {
  local raw="$1"
  local scan="$2"

  local boundary='(^|[;&|()<>{}`])'
  local wrappers='((time|command|exec|sudo|nice|nohup)[[:space:]]+|(/usr/bin/)?env([[:space:]]+[-A-Za-z0-9_=]+)*[[:space:]]+)*'
  local gh_path='(/[^[:space:];|&()<>{}`]+/)?gh'
  local gh_cmd="${boundary}[[:space:]]*${wrappers}${gh_path}[[:space:]]+"
  local topics='(repo|pr|issue|release|secret|variable|ssh-key|gpg-key|auth|ruleset|rs|workflow|api|cache|codespace|cs|gist|label|project|run|alias|extension|ext|config)'
  local dyn='(\$\(|\$[A-Za-z_][A-Za-z0-9_]*|`)'
  # Allow list (also excluded from the scan):
  #   gh pr edit / update-branch / merge
  #   gh issue edit
  #   gh workflow run
  local dangerous='(repo[[:space:]]+(delete|archive|edit|rename|unarchive|sync|set-default)|repo[[:space:]]+autolink[[:space:]]+(create|delete)|repo[[:space:]]+deploy-key[[:space:]]+(add|delete)|pr[[:space:]]+(close|lock)|issue[[:space:]]+(close|delete|lock|transfer|pin|unpin)|release[[:space:]]+(delete|delete-asset|edit|upload)|secret[[:space:]]+(delete|remove|set)|variable[[:space:]]+(delete|remove|set)|ssh-key[[:space:]]+delete|gpg-key[[:space:]]+delete|auth[[:space:]]+(logout|login|refresh|switch|setup-git)|ruleset[[:space:]]+(create|edit|delete)|rs[[:space:]]+(create|edit|delete)|workflow[[:space:]]+(disable|enable)|cache[[:space:]]+delete|codespace[[:space:]]+(delete|edit|stop)|cs[[:space:]]+(delete|edit|stop)|label[[:space:]]+(clone|create|delete|edit)|gist[[:space:]]+(delete|edit|rename)|project[[:space:]]+(close|copy|create|delete|edit|field-create|field-delete|item-add|item-archive|item-create|item-delete|item-edit|link|unlink|mark-template)|run[[:space:]]+(cancel|delete)|alias[[:space:]]+(set|import)|extension[[:space:]]+(install|remove|upgrade)|ext[[:space:]]+(install|remove|upgrade)|config[[:space:]]+set)'

  grep_re "${gh_cmd}${dangerous}([[:space:]]|$)" "$scan" && block "$raw" "dangerous gh subcommand"
  grep_re "${gh_cmd}${topics}[[:space:]]+${dyn}" "$scan" && block "$raw" "dynamic gh subcommand is not analyzable"
  grep_re "${boundary}[[:space:]]*${dyn}[[:space:]]+${topics}[[:space:]]+" "$scan" && block "$raw" "dynamic gh invocation is not analyzable"
  grep_re "${boundary}[[:space:]]*eval[[:space:]]+.*${gh_path}[[:space:]]+" "$scan" && block "$raw" "gh via eval is forbidden"
  grep_re "${boundary}[[:space:]]*${wrappers}((/[^[:space:];|&()<>{}\`]+/)?(ba|z)?sh|dash)[[:space:]]+-[^[:space:]]*c[[:space:]]+.*${gh_path}[[:space:]]+" "$scan" && block "$raw" "gh via shell -c is forbidden"
  grep_re "${boundary}.*xargs([^;&|]*[[:space:]])${wrappers}${gh_path}[[:space:]]+${dangerous}" "$scan" && block "$raw" "dangerous gh via xargs"
  grep_re '\|[[:space:]]*((/[^[:space:];|&()<>{}`]+/)?(ba|z)?sh|dash)([[:space:]]|$)' "$raw" && block "$raw" "pipe-to-shell is forbidden"

  if grep_re "${gh_cmd}api([[:space:]]|$)" "$scan" &&
     grep_re '(^|[[:space:]])((-X[[:space:]=]*)|(--method([[:space:]]+|=)))(delete|put|patch)([[:space:]]|$)' "$scan"; then
    block "$raw" "destructive gh api method (DELETE/PUT/PATCH) is forbidden"
  fi

  # ---- AWS CLI: destructive S3 operations ----
  local aws_path='(/[^[:space:];|&()<>{}`]+/)?aws'
  local aws_cmd="${boundary}[[:space:]]*${wrappers}${aws_path}[[:space:]]+"
  local aws_dangerous='(s3[[:space:]]+(rm|rb|mv)|s3api[[:space:]]+(delete-bucket|delete-bucket-policy|delete-bucket-lifecycle|delete-bucket-cors|delete-bucket-website|delete-bucket-tagging|delete-bucket-replication|delete-bucket-encryption|delete-public-access-block|delete-object|delete-objects|delete-object-tagging|put-bucket-acl|put-bucket-policy|put-object-acl|put-bucket-versioning))'

  grep_re "${aws_cmd}${aws_dangerous}([[:space:]]|$)" "$scan" && block "$raw" "dangerous aws S3 operation"
  grep_re "${aws_cmd}s3[[:space:]]+sync.*--delete\b" "$scan" && block "$raw" "aws s3 sync --delete is forbidden"

  # Block aws s3 / s3api via shell -c the same way as gh.
  local shell_c="${boundary}[[:space:]]*${wrappers}((/[^[:space:];|&()<>{}\`]+/)?(ba|z)?sh|dash)[[:space:]]+-[^[:space:]]*c[[:space:]]+"
  grep_re "${shell_c}.*${aws_path}[[:space:]]+(s3|s3api)[[:space:]]+" "$scan" && block "$raw" "aws via shell -c is forbidden"

  # Normalize the return value so that no-match grep_re results don't trip set -e.
  return 0
}

scan_raw_bypass_rules "$NORMALIZED_COMMAND" "$SCAN_COMMAND"

exit 0
