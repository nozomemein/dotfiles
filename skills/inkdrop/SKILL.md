---
name: inkdrop
description: |
  Inkdrop MCP server を使ってノートの検索・閲覧・作成・更新を行う。
  トリガー: "inkdrop", "インクドロップ", "ノートを検索", "ノートにメモ", "ノート作って", "ノートを更新", "notebook 一覧"
  使用場面: (1) 過去ノートの検索・参照, (2) 調査結果や議事メモのノート化, (3) 既存ノートへの追記・修正, (4) タグ / notebook の整理
---

# Inkdrop

Inkdrop MCP server 経由でノートを操作するスキル。ツール名は Claude Code 上では `mcp__inkdrop__<tool>` の形で見える（例: `mcp__inkdrop__search-notes`）。deferred になっている場合は ToolSearch で `+inkdrop` を引いてから呼ぶ。

## 前提（セットアップ）

1. Inkdrop 本体の設定で **local HTTP server** を有効化する（Preferences → Advanced の developer 設定）
2. MCP server を登録する（Claude Code は `~/.claude.json`）:

```json
{
  "mcpServers": {
    "inkdrop": {
      "command": "npx",
      "args": ["-y", "@inkdropapp/mcp-server"],
      "env": {
        "INKDROP_LOCAL_SERVER_URL": "http://localhost:19840",
        "INKDROP_LOCAL_USERNAME": "<local-server-username>",
        "INKDROP_LOCAL_PASSWORD": "<local-server-password>"
      }
    }
  }
}
```

接続エラーになったら、まず Inkdrop アプリが起動していて local server が有効かを疑う。

出典: [Inkdrop MCP server reference](https://docs.inkdrop.app/reference/mcp-server)

## ツール一覧（12 個）

| ツール | 用途 | 主なパラメータ |
|---|---|---|
| `search-notes` | キーワードでノート検索 | `keyword` |
| `list-notes` | 条件でノート一覧 | `bookId`, `tagIds`, `keyword`, `sort`, `descending`, `limit` |
| `read-note` | ノート本文の取得 | `noteId` |
| `create-note` | ノート新規作成 | `bookId`, `title`, `body`（任意: `status`, `tags`） |
| `update-note` | ノート全体の更新 | `_id`, `_rev` + 更新フィールド |
| `patch-note` | ノート本文の部分置換 | `_id`, `_rev`, `old_string`, `new_string` |
| `list-notebooks` | notebook 一覧 | なし |
| `read-book` | notebook 単体取得 | `bookId` |
| `list-tags` | タグ一覧 | なし |
| `read-tag` | タグ単体取得 | `tagId` |
| `create-tag` | タグ新規作成 | `name`（任意: `color`） |
| `update-tag` | タグ更新 | `_id`, `_rev`, `name`（任意: `color`） |

ID は prefix 付き: ノート `note:*` / notebook `book:*` / タグ `tag:*`。削除ツールは存在しない（削除はユーザーがアプリ側で行う）。

## 検索構文（`search-notes` の keyword）

| 修飾子 | 意味 | 例 |
|---|---|---|
| `book:` | notebook で絞る | `book:Blog` |
| `tag:` | タグで絞る | `tag:JavaScript` |
| `status:` | ステータスで絞る | `status:onHold` |
| `title:` | タイトル内を検索 | `title:"JavaScript setTimeout"` |
| `body:` | 本文内を検索 | `body:KEYWORD` |
| `-` 前置 | 除外 | `-book:Backend`, `-tag:JavaScript` |
| `"..."` | 空白を含むフレーズ検索 | `"database associations"` |

修飾子は組み合わせ可能: `Typescript tag:Contribution status:Completed`

注意: 全文検索は **部分一致をサポートしない**（`trin` では `string` はヒットしない）。ヒットしないときは語を短くするのではなく、別の語・タグ・notebook 絞り込みに切り替える。

## 典型フロー

### 検索して読む

1. `search-notes` で候補を出す（絞り込みたければ `list-notes` に切り替え）
2. `read-note` で本文を取得（検索結果の抜粋だけで判断しない）

### ノートを作る

1. `list-notebooks` で保存先 `bookId` を特定する（推測で ID を書かない）
2. タグを付けるなら `list-tags` で既存タグを確認。無いものだけ `create-tag`
3. `create-note`。本文は Markdown

### ノートを更新する

1. `read-note` で現在の本文と `_rev` を取得する（`_rev` は更新のたびに変わるので毎回取り直す）
2. 部分修正なら `patch-note`（`old_string` → `new_string`）を既定とする
3. 全面書き換えのときだけ `update-note`。渡さなかったフィールドの扱いに注意し、既存内容を消さないよう read した内容をベースに組み立てる

## やってはいけないこと

- **read せずに update-note する**（古い内容の上書き・消失につながる。`_rev` も取れない）
- **部分修正に update-note を使う**（patch-note で済むものを全文置換しない）
- **既存タグを確認せずに create-tag する**（表記揺れの重複タグが増える）
- **bookId / tagId を推測で書く**（必ず list 系ツールで実 ID を確認する）
- **ユーザーの指示なくノートの主張・内容を書き換える**（追記・整形は指示の範囲で。大きな書き換えは事前に差分を提示して確認）
- **検索がヒットしないからと同じクエリを微修正して連打する**（部分一致非対応を思い出し、検索戦略を変える）

## ワークフロー要約

```
1. 目的を分類 (検索 / 作成 / 更新 / 整理)
   ↓
2. 参照系 (search-notes / list-notes / list-notebooks / list-tags) で対象を特定
   ↓
3. read-note で本文と _rev を取得
   ↓
4. 変更系 (create-note / patch-note / update-note / create-tag / update-tag) を実行
   ↓
5. 結果 (作成 / 更新したノートのタイトルと ID) を 1 行で報告
```
