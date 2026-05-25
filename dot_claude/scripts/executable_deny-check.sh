#!/usr/bin/env bash
set -euo pipefail

# Claude Code PreToolUse Hook: Bash コマンド検証スクリプト
# bypass-permission モードでも hook は走るので、ここが本当の防壁。
# fail-closed 原則: 解析エラー時はブロック。

SETTINGS_FILE="$HOME/.claude/settings.json"

emit_error() {
  jq -cn --arg error "🚫 ブロックされました: $1" '{error:$error}'
}

INPUT=$(cat)

if ! TOOL_NAME=$(printf '%s' "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null); then
  emit_error "hook input JSON が不正"
  exit 2
fi

if ! COMMAND=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null); then
  emit_error "hook input JSON が不正"
  exit 2
fi

if [[ "$TOOL_NAME" != "Bash" ]]; then
  exit 0
fi
if [[ -z "$COMMAND" ]]; then
  exit 0
fi

# ---- 正規化ヘルパ ----
# tab/改行/連続スペースを単一空白へ
normalize_shell_text() {
  printf '%s' "$1" | tr '\n\t\r' '   ' | sed -E 's/[[:space:]]+/ /g; s/^ //; s/ $//'
}

# 単純なクォート剥がし (検出用)
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

# &&, ||, ; で論理セクション分割した上で各セクションを正規化
IFS=$'\n'
CMD_PARTS=$(printf '%s' "$COMMAND" | sed 's/&&/\n/g; s/||/\n/g; s/;/\n/g' | while IFS= read -r line; do normalize_shell_text "$line"; done)
NORMALIZED_COMMAND=$(normalize_shell_text "$COMMAND")
SCAN_COMMAND=$(strip_shell_quotes "$NORMALIZED_COMMAND")

# ---- (1) settings.json の deny パターンによる prefix-match ----
# Claude Code 本体の prefix-wildcard 仕様:
#   "Bash(foo *)" は "foo" 単体にもマッチ → 末尾 " *" を ([[:space:]]+.*)? に変換
match_pattern() {
  local cmd="$1"
  local pattern="$2"

  [[ "$pattern" =~ ^Bash\((.+)\)$ ]] || return 1
  local inner
  inner=$(normalize_shell_text "${BASH_REMATCH[1]}")

  # 正規表現メタ文字エスケープ ( * は後で展開、\ や [ ] も含める)
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
          block "$part" "パターン: $pattern"
        fi
      done <<< "$DENY_PATTERNS"
    done
  fi
fi

# ---- (2) raw command 全体への危険構文 scan ----
# pipe / command substitution / eval / bash -c / xargs / 絶対パス / wrapper 経由 / 動的サブコマンド
# (引数順序が任意な gh api の HTTP method もここで)
scan_raw_bypass_rules() {
  local raw="$1"
  local scan="$2"

  local boundary='(^|[;&|()<>{}`])'
  local wrappers='((time|command|exec|sudo|nice|nohup)[[:space:]]+|(/usr/bin/)?env([[:space:]]+[-A-Za-z0-9_=]+)*[[:space:]]+)*'
  local gh_path='(/[^[:space:];|&()<>{}`]+/)?gh'
  local gh_cmd="${boundary}[[:space:]]*${wrappers}${gh_path}[[:space:]]+"
  local topics='(repo|pr|issue|release|secret|variable|ssh-key|gpg-key|auth|ruleset|rs|workflow|api|cache|codespace|cs|gist|label|project|run|alias|extension|ext|config)'
  local dyn='(\$\(|\$[A-Za-z_][A-Za-z0-9_]*|`)'
  # 許可リスト(scan からは除外):
  #   gh pr edit / update-branch / merge
  #   gh issue edit
  #   gh workflow run
  local dangerous='(repo[[:space:]]+(delete|archive|edit|rename|unarchive|sync|set-default)|repo[[:space:]]+autolink[[:space:]]+(create|delete)|repo[[:space:]]+deploy-key[[:space:]]+(add|delete)|pr[[:space:]]+(close|lock)|issue[[:space:]]+(close|delete|lock|transfer|pin|unpin)|release[[:space:]]+(delete|delete-asset|edit|upload)|secret[[:space:]]+(delete|remove|set)|variable[[:space:]]+(delete|remove|set)|ssh-key[[:space:]]+delete|gpg-key[[:space:]]+delete|auth[[:space:]]+(logout|login|refresh|switch|setup-git)|ruleset[[:space:]]+(create|edit|delete)|rs[[:space:]]+(create|edit|delete)|workflow[[:space:]]+(disable|enable)|cache[[:space:]]+delete|codespace[[:space:]]+(delete|edit|stop)|cs[[:space:]]+(delete|edit|stop)|label[[:space:]]+(clone|create|delete|edit)|gist[[:space:]]+(delete|edit|rename)|project[[:space:]]+(close|copy|create|delete|edit|field-create|field-delete|item-add|item-archive|item-create|item-delete|item-edit|link|unlink|mark-template)|run[[:space:]]+(cancel|delete)|alias[[:space:]]+(set|import)|extension[[:space:]]+(install|remove|upgrade)|ext[[:space:]]+(install|remove|upgrade)|config[[:space:]]+set)'

  grep_re "${gh_cmd}${dangerous}([[:space:]]|$)" "$scan" && block "$raw" "危険な gh サブコマンド"
  grep_re "${gh_cmd}${topics}[[:space:]]+${dyn}" "$scan" && block "$raw" "gh の動的サブコマンドは検査不能"
  grep_re "${boundary}[[:space:]]*${dyn}[[:space:]]+${topics}[[:space:]]+" "$scan" && block "$raw" "動的 gh 呼び出しは検査不能"
  grep_re "${boundary}[[:space:]]*eval[[:space:]]+.*${gh_path}[[:space:]]+" "$scan" && block "$raw" "eval 経由の gh は禁止"
  grep_re "${boundary}[[:space:]]*${wrappers}((/[^[:space:];|&()<>{}\`]+/)?(ba|z)?sh|dash)[[:space:]]+-[^[:space:]]*c[[:space:]]+.*${gh_path}[[:space:]]+" "$scan" && block "$raw" "shell -c 経由の gh は禁止"
  grep_re "${boundary}.*xargs([^;&|]*[[:space:]])${wrappers}${gh_path}[[:space:]]+${dangerous}" "$scan" && block "$raw" "xargs 経由の危険な gh"
  grep_re '\|[[:space:]]*((/[^[:space:];|&()<>{}`]+/)?(ba|z)?sh|dash)([[:space:]]|$)' "$raw" && block "$raw" "pipe-to-shell は禁止"

  if grep_re "${gh_cmd}api([[:space:]]|$)" "$scan" &&
     grep_re '(^|[[:space:]])((-X[[:space:]=]*)|(--method([[:space:]]+|=)))(delete|put|patch)([[:space:]]|$)' "$scan"; then
    block "$raw" "gh api の破壊的メソッド (DELETE/PUT/PATCH) は禁止"
  fi
}

scan_raw_bypass_rules "$NORMALIZED_COMMAND" "$SCAN_COMMAND"

exit 0
