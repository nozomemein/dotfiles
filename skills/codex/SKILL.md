---
name: codex
description: |
  Codex CLI（OpenAI）を使用してコードや文言について相談・レビューを行う。
  トリガー: "codex", "codexと相談", "codexに聞いて", "コードレビュー", "レビューして"
  使用場面: (1) 文言・メッセージの検討、(2) コードレビュー、(3) 設計の相談、(4) バグ調査、(5) 解消困難な問題の調査
---

# Codex

Codex CLI を使用してコードレビュー・分析・相談を実行するスキル。

## 実行手順

1. 対象プロジェクトのディレクトリを特定する（cwd またはユーザー指定）
2. prompt を `/tmp/codex-prompt.txt` に heredoc で書き出す（末尾に下記の定型文を必ず追加）
3. `codex exec --sandbox read-only -m gpt-5.6-sol -c model_reasoning_effort=max --cd <dir> - < /tmp/codex-prompt.txt` で実行
4. 結果をユーザーに報告

## 実行コマンド（ファイル経由 stdin が必須）

prompt は **必ずファイルに書いて stdin で渡す**。インライン引数 `"..."` は backtick / `$(...)` を shell が command substitution として実行してしまい壊れる（`eval: command not found: try_into` 等）。

```bash
# 1. プロンプトをファイルに書く（'EOF' で literal 化、変数展開・backtick 解釈を無効化）
cat > /tmp/codex-prompt.txt <<'EOF'
<プロンプト本文。backtick やダブルクォートを自由に含められる>

確認や質問は不要です。具体的な提案・修正案・コード例まで自主的に出力してください。
EOF

# 2. codex 実行（- で stdin から prompt を読む）
codex exec --sandbox read-only -m gpt-5.6-sol -c model_reasoning_effort=max --cd <project_dir> - < /tmp/codex-prompt.txt
```

prompt の末尾には必ず「確認や質問は不要です。具体的な提案・修正案・コード例まで自主的に出力してください。」を含める。Codex が確認待ちで止まるのを防ぐため。

## パラメータ

| パラメータ | 説明 |
|---|---|
| `--sandbox read-only` | 読み取り専用 sandbox（安全な分析用）。`codex exec` は非対話なので approval は常に `never`。`--full-auto` は deprecated（`--sandbox workspace-write` の別名）なので付けない |
| `-m gpt-5.6-sol` | モデル指定（必須、ユーザ既定） |
| `-c model_reasoning_effort=max` | reasoning effort（low / medium / high / xhigh / max / ultra、既定 max） |
| `--cd <dir>` | 対象プロジェクトのディレクトリ |
| `-` | stdin から prompt を読む |

## プロンプト例

コマンドは常に上記と同一。用途に応じて prompt 本文だけ変える。

- コードレビュー: 「このプロジェクトのコードをレビューして、改善点を指摘してください。」
- バグ調査: 「認証処理でエラーが発生する原因を調査してください。」
- アーキテクチャ分析: 「このプロジェクトのアーキテクチャを分析して説明してください。」
- リファクタリング提案: 「技術的負債を特定し、リファクタリング計画を提案してください。」

デザイン相談（UI/UX）は評価観点まで指定すると出力が締まる:

```text
あなたは世界トップクラスの UI デザイナーです。以下の観点からこのプロジェクトの UI を評価してください:
(1) 視覚的階層構造とタイポグラフィ
(2) 余白・スペーシングのリズム
(3) カラーパレットのコントラストとアクセシビリティ
(4) インタラクションパターンの一貫性
(5) ユーザーの認知負荷の軽減
```

## トラブルシューティング

### `eval: command not found` / shell が prompt 内を実行してしまう
- 原因: インライン引数 `"<prompt>"` で渡した prompt 内の **backtick** や **`$(...)`** を shell が command substitution として実行
- 対処: 必ず **ファイル経由 stdin** パターンを使う。インライン引数はそもそも使わない

### `Reading additional input from stdin...` のままストールする
- 原因: Codex CLI は exec モードでも対話 stdin を開けっぱなしにすることがある
- 対処:
  - ファイル経由 stdin パターン（`- < /tmp/codex-prompt.txt`）なら EOF で自動的に閉じるので発生しない
  - 引数 prompt を使う場合は `< /dev/null` を必ず付ける
  - 5 分以上 output 行数が増えなければ kill して prompt を短くして再実行
  - `-m gpt-5.6-sol -c model_reasoning_effort=max` を必ず付ける（ユーザ既定モデル）

### `failed to load models cache: missing field ...` が出る
- 原因: `~/.codex/models_cache.json` を ChatGPT アプリ / VS Code 拡張の新しい codex が書き、古い CLI がスキーマを読めない (バージョンずれ)
- 対処: `npm i -g @openai/codex@latest && asdf reshim nodejs` で CLI を追従させる。非致命なので急ぎでなければ無視してよい

### sandbox 制限で `cargo check` 等が失敗
- `CARGO_TARGET_DIR=/tmp/codex-target` を環境変数で渡せば共有 target 外で動く

### `target-codex/` 等の cargo cache が untracked で残る
- worktree 完了時に消えるので **触らない**。`.gitignore` に追記しない、commit にも含めない
