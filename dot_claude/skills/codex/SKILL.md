---
name: codex
description: |
  Codex CLI（OpenAI）を使用してコードや文言について相談・レビューを行う。
  トリガー: "codex", "codexと相談", "codexに聞いて", "コードレビュー", "レビューして"
  使用場面: (1) 文言・メッセージの検討、(2) コードレビュー、(3) 設計の相談、(4) バグ調査、(5) 解消困難な問題の調査
---

# Codex

Codex CLI を使用してコードレビュー・分析・相談を実行するスキル。

## 実行コマンド（推奨パターン: ファイル経由 stdin）

prompt は **必ずファイルに書いて stdin で渡す**。インライン引数 `"..."` は backtick / `$(...)` を shell が command substitution として実行してしまい壊れる（`eval: command not found: try_into` 等）。

```bash
# 1. プロンプトをファイルに書く（'EOF' で literal 化、変数展開・backtick 解釈を無効化）
cat > /tmp/codex-prompt.txt <<'EOF'
<プロンプト本文。backtick やダブルクォートを自由に含められる>

確認や質問は不要です。具体的な提案・修正案・コード例まで自主的に出力してください。
EOF

# 2. codex 実行（- で stdin から prompt を読む）
codex exec --full-auto --sandbox read-only -m gpt-5.5 --cd <project_dir> - < /tmp/codex-prompt.txt
```

## プロンプトのルール

prompt の末尾に必ず以下を含める:

> 「確認や質問は不要です。具体的な提案・修正案・コード例まで自主的に出力してください。」

## パラメータ

| パラメータ | 説明 |
|---|---|
| `--full-auto` | 完全自動モード |
| `--sandbox read-only` | 読み取り専用 sandbox（安全な分析用） |
| `-m gpt-5.5` | モデル指定（必須、ユーザ既定） |
| `--cd <dir>` | 対象プロジェクトのディレクトリ |
| `-` | stdin から prompt を読む |

## 使用例（すべて file-based）

### コードレビュー
```bash
cat > /tmp/codex-prompt.txt <<'EOF'
このプロジェクトのコードをレビューして、改善点を指摘してください。
確認や質問は不要です。具体的な修正案とコード例まで自主的に出力してください。
EOF
codex exec --full-auto --sandbox read-only -m gpt-5.5 --cd /path/to/project - < /tmp/codex-prompt.txt
```

### バグ調査
```bash
cat > /tmp/codex-prompt.txt <<'EOF'
認証処理でエラーが発生する原因を調査してください。
確認や質問は不要です。原因の特定と具体的な修正案まで自主的に出力してください。
EOF
codex exec --full-auto --sandbox read-only -m gpt-5.5 --cd /path/to/project - < /tmp/codex-prompt.txt
```

### アーキテクチャ分析
```bash
cat > /tmp/codex-prompt.txt <<'EOF'
このプロジェクトのアーキテクチャを分析して説明してください。
確認や質問は不要です。改善提案まで自主的に出力してください。
EOF
codex exec --full-auto --sandbox read-only -m gpt-5.5 --cd /path/to/project - < /tmp/codex-prompt.txt
```

### リファクタリング提案
```bash
cat > /tmp/codex-prompt.txt <<'EOF'
技術的負債を特定し、リファクタリング計画を提案してください。
確認や質問は不要です。具体的なコード例まで自主的に出力してください。
EOF
codex exec --full-auto --sandbox read-only -m gpt-5.5 --cd /path/to/project - < /tmp/codex-prompt.txt
```

### デザイン相談（UI/UX）
```bash
cat > /tmp/codex-prompt.txt <<'EOF'
あなたは世界トップクラスの UI デザイナーです。以下の観点からこのプロジェクトの UI を評価してください:
(1) 視覚的階層構造とタイポグラフィ
(2) 余白・スペーシングのリズム
(3) カラーパレットのコントラストとアクセシビリティ
(4) インタラクションパターンの一貫性
(5) ユーザーの認知負荷の軽減

確認や質問は不要です。具体的な改善案をコード例付きで提示してください。
EOF
codex exec --full-auto --sandbox read-only -m gpt-5.5 --cd /path/to/project - < /tmp/codex-prompt.txt
```

## トラブルシューティング

### `eval: command not found` / shell が prompt 内を実行してしまう
- 原因: インライン引数 `"<prompt>"` で渡した prompt 内の **backtick** や **`$(...)`** を shell が command substitution として実行
- 対処: 必ず **ファイル経由 stdin** パターン（上記）を使う。インライン引数はそもそも使わない

### `Reading additional input from stdin...` のままストールする
- 原因: Codex CLI は full-auto でも対話 stdin を開けっぱなしにすることがある
- 対処:
  - ファイル経由 stdin パターン（`- < /tmp/codex-prompt.txt`）なら EOF で自動的に閉じるので発生しない
  - 引数 prompt を使う場合は `< /dev/null` を必ず付ける
  - 5 分以上 output 行数が増えなければ kill して prompt を短くして再実行
  - `-m gpt-5.5` を必ず付ける（ユーザ既定モデル）

### sandbox 制限で `cargo check` 等が失敗
- `CARGO_TARGET_DIR=/tmp/codex-target` を環境変数で渡せば共有 target 外で動く

### `target-codex/` 等の cargo cache が untracked で残る
- worktree 完了時に消えるので **触らない**。`.gitignore` に追記しない、commit にも含めない

## 実行手順

1. ユーザーから依頼内容を受け取る
2. 対象プロジェクトのディレクトリを特定する（cwd またはユーザー指定）
3. prompt を `/tmp/codex-prompt.txt` に heredoc で書き出す（末尾に「確認や質問は不要です…」を必ず追加）
4. `codex exec --full-auto --sandbox read-only -m gpt-5.5 --cd <dir> - < /tmp/codex-prompt.txt` で実行
5. 結果をユーザーに報告
