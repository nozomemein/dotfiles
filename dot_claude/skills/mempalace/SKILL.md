---
name: mempalace
description: |
  MemPalace（ローカル AI メモリシステム）を使ったドキュメント・会話ログの検索・管理。
  トリガー: "mempalace", "記憶を検索", "過去の会話", "ドキュメント検索", "palace search", "なぜこの設計にしたか", "前に話した", "以前の議論"
  使用場面: (1) 過去の会話・議論の検索、(2) 設計判断の経緯確認、(3) ドキュメントの意味検索、(4) ナレッジグラフへの事実登録・参照、(5) プロジェクトのタイムライン確認
---

# MemPalace Skill

ローカルで動作する AI メモリシステム。ChromaDB ベースのベクトル検索でドキュメント・会話ログを意味検索する。

## 階層構造（Palace メタファー）

```
Palace
├── Wing (プロジェクト・人)
│   ├── Room (トピック: auth, billing, deploy ...)
│   │   ├── Closet (要約)
│   │   └── Drawer (原文)
│   └── Hall (メモリ種別、Wing 横断)
│       ├── hall_facts       — 確定した意思決定
│       ├── hall_events      — セッション、マイルストーン
│       ├── hall_discoveries — ブレイクスルー、発見
│       ├── hall_preferences — 習慣、好み
│       └── hall_advice      — 推奨事項、解決策
└── Tunnel (Wing 間の同名 Room を自動接続)
```

### 検索精度と絞り込みの関係

| 絞り込み | 精度 |
|----------|------|
| なし | 60.9% |
| Wing のみ | 73.1% |
| Wing + Hall | 84.8% |
| Wing + Room | 94.8% |

**可能な限り Wing や Room を指定して検索すること。**

## MCP ツール一覧

MCP サーバー経由で以下のツールが利用可能。
セットアップ: `claude mcp add mempalace -s user -- python -m mempalace.mcp_server`

### 検索・参照

| ツール | 用途 | 主要パラメータ |
|--------|------|----------------|
| `mempalace_search` | 全体の意味検索 | query, wing?, room?, hall? |
| `mempalace_search_wing` | Wing 内検索 | query, wing |
| `mempalace_search_room` | Wing + Room 内検索 | query, wing, room |
| `mempalace_search_full_text` | 生テキスト全文検索 | query |
| `mempalace_status` | Palace 全体の概要 | なし |
| `mempalace_list_wings` | Wing 一覧 | なし |
| `mempalace_list_rooms` | Wing 内の Room 一覧 | wing |
| `mempalace_wake_up` | 重要事実のコンテキスト生成（~170 tokens） | なし |

### ナレッジグラフ

| ツール | 用途 | 主要パラメータ |
|--------|------|----------------|
| `mempalace_get_entity` | エンティティの事実を取得 | entity |
| `mempalace_query_entity` | 特定時点のエンティティ状態 | entity, as_of? |
| `mempalace_add_triple` | 関係性を追加 | subject, predicate, object, valid_from, valid_to? |
| `mempalace_invalidate` | 関係性を終了 | subject, predicate, object, ended |
| `mempalace_timeline` | エンティティの時系列ストーリー | entity |
| `mempalace_check_contradiction` | 事実の矛盾チェック | assertion |

### エージェント

| ツール | 用途 | 主要パラメータ |
|--------|------|----------------|
| `mempalace_list_agents` | エージェント一覧 | なし |
| `mempalace_get_agent_config` | エージェント設定の取得 | agent |
| `mempalace_diary_write` | エージェント日記への書き込み | agent, entry |
| `mempalace_diary_read` | エージェント日記の読み込み | agent, last_n? |

### データ取り込み

| ツール | 用途 | 主要パラメータ |
|--------|------|----------------|
| `mempalace_mine_local_file` | 個別ファイルのインデックス追加 | file_path |

## 検索の使い分け

### 設計判断の経緯を調べたい

```
mempalace_search("なぜ GraphQL に切り替えたか", wing="backend", hall="hall_facts")
```

### 特定プロジェクトのドキュメントを検索

```
mempalace_search_wing("認証フローの設計", wing="yomi")
```

### 特定トピックに絞った検索

```
mempalace_search_room("レプリケーションの障害対応", wing="yomi", room="replication")
```

### 人物やプロジェクトの現在の状態

```
mempalace_query_entity("Maya")
mempalace_timeline("Orion")
```

## CLI コマンド（参考）

### データ取り込み

```bash
# ドキュメントの取り込み
mempalace mine ~/projects/myapp/docs --wing myapp

# 会話ログの取り込み
mempalace mine ~/chats/ --mode convos --wing myapp

# 自動分類つき取り込み
mempalace mine ~/chats/ --mode convos --extract general

# プレビュー（実行しない）
mempalace mine ~/docs --dry-run
```

### 検索

```bash
mempalace search "認証の設計"
mempalace search "auth flow" --wing backend
mempalace search "rate limiting" --room api
```

### その他

```bash
mempalace status          # Palace 概要
mempalace wake-up         # 重要事実のコンテキスト出力
mempalace split ~/chats/  # 大きなファイルの分割（mine 前処理）
```

## 実行手順

1. ユーザーの質問から検索キーワードと絞り込み条件（wing/room/hall）を判断する
2. `mempalace_status` または `mempalace_list_wings` で利用可能な Wing を確認する（初回のみ）
3. 適切な MCP ツールで検索を実行する
4. 結果が不十分な場合は、絞り込みを緩めるか別のキーワードで再検索する
5. 検索結果をユーザーの質問に対する回答として整理して提示する

## 注意事項

- embedding モデル（デフォルト: `all-MiniLM-L6-v2`）は英語特化。日本語の意味検索は精度が落ちる可能性がある
- コードそのものより、設計判断・議論・ドキュメントの検索に向いている
- `entities.json` が mine 元ディレクトリに生成される。`.git/info/exclude` で除外すること
- データは `~/.mempalace/` に保存される。リセットは `rm -rf ~/.mempalace`
