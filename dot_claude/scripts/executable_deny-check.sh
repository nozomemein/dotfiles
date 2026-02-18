#!/usr/bin/env bash
set -euo pipefail

# Claude Code PreToolUse Hook: Bash コマンド検証スクリプト
# settings.json の permissions.deny パターンに基づき危険なコマンドをブロックする

SETTINGS_FILE="$HOME/.claude/settings.json"

# 標準入力からHookのJSON入力を読み取る
INPUT=$(cat)

TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Bashツール以外は無視
if [[ "$TOOL_NAME" != "Bash" ]]; then
  exit 0
fi

# コマンドが空なら無視
if [[ -z "$COMMAND" ]]; then
  exit 0
fi

# settings.json から deny パターンを読み込む
if [[ ! -f "$SETTINGS_FILE" ]]; then
  exit 0
fi

DENY_PATTERNS=$(jq -r '.permissions.deny[]? // empty' "$SETTINGS_FILE" 2>/dev/null)

if [[ -z "$DENY_PATTERNS" ]]; then
  exit 0
fi

# ワイルドカードパターンをBashのextglobパターンに変換してマッチング
match_pattern() {
  local cmd="$1"
  local pattern="$2"

  # "Bash(...)" の中身を抽出
  if [[ "$pattern" =~ ^Bash\((.+)\)$ ]]; then
    local inner="${BASH_REMATCH[1]}"

    # ワイルドカード(*) を正規表現に変換
    # エスケープしてから * を .* に置換
    local regex
    regex=$(printf '%s' "$inner" | sed 's/[.[\^$()+?{}|]/\\&/g; s/\*/.*/g')

    if echo "$cmd" | grep -qE "^${regex}$"; then
      return 0
    fi
  fi
  return 1
}

# コマンドを論理演算子で分割して各部分を検証
IFS=$'\n'
CMD_PARTS=$(echo "$COMMAND" | sed 's/&&/\n/g; s/||/\n/g; s/;/\n/g' | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')

for part in $CMD_PARTS; do
  [[ -z "$part" ]] && continue

  while IFS= read -r pattern; do
    [[ -z "$pattern" ]] && continue
    if match_pattern "$part" "$pattern"; then
      # ブロック: 終了コード2 + JSON で理由を返す
      echo '{"error": "🚫 ブロックされました: '"$part"' (パターン: '"$pattern"')"}'
      exit 2
    fi
  done <<< "$DENY_PATTERNS"
done

exit 0
