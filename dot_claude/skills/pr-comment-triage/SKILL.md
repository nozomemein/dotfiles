---
name: pr-comment-triage
description: |
  GitHub PR の未解決レビューコメントを取得して triage する。
  - 対応必要 → 対応方針プランを提示 (write-plan へリレー可)
  - 対応不要 → 返信案を提示 → 承認後に reply + thread resolve
  トリガー: "PRコメント対応", "PRコメントみて", "PRコメント triage", "review コメント対応", "pr comment triage"
  使用場面: (1) レビューを受けた直後の triage, (2) 修正 push 後の再レビュー対応, (3) 古い PR の積み残しコメント整理
---

# PR Comment Triage

PR のレビューコメントを 1 件ずつ triage し、「対応する / 返信して resolve する」を判定する薄いスキル。

主旨:
1. **未解決スレッドだけ対象**にする (resolve 済みは触らない)
2. 「対応必要 / 対応不要 / 不明」の 3 値で判定
3. **reply 投稿 / resolve は必ずユーザー承認後**に実行する (誤爆防止)

---

## 1. 動作モードを決める

| モード | 用途 |
|---|---|
| **フル** | 未解決スレッド全件を 1 周 triage |
| **単一** | 指定 thread id だけ処理 |
| **判定のみ** | reply / resolve は一切しない、判定結果だけ提示 |

迷ったら **判定のみ** から始める。

---

## 2. コメント取得

PR 番号は `gh pr view --json number,baseRefName,headRefName` で取得。

未解決の review thread を一括取得:

```bash
gh api graphql -f query='
query($owner:String!, $repo:String!, $pr:Int!) {
  repository(owner:$owner, name:$repo) {
    pullRequest(number:$pr) {
      reviewThreads(first:100) {
        nodes {
          id
          isResolved
          isOutdated
          path
          line
          comments(first:50) {
            nodes { id author{login} body createdAt }
          }
        }
      }
    }
  }
}' -F owner=<owner> -F repo=<repo> -F pr=<num>
```

`isResolved: false` のスレッドだけ拾う。`isOutdated: true` (元コードが変わって追跡できなくなった) はそのまま残すか、対応済み扱いにするかをユーザーに確認する。

スレッドが 100 件を超える場合は `pageInfo { hasNextPage endCursor }` を足してページネーションする。

### Issue comment 系 (PR 全体の議論)

review thread に紐づかない PR 全体コメントは `gh pr view --comments` で別途取得。これは resolve の概念がないので、**判定のみで終わり** (reply は本人判断)。

---

## 3. 判定フレーム

各スレッドを次の 3 値で判定する。

| 値 | 条件 | アクション |
|---|---|---|
| **対応必要** | コード変更 / ドキュメント追加 / テスト追加など作業が要る | 対応方針プラン |
| **対応不要** | 既対応 / 別 PR で扱う / 質問への回答だけで足る / 採用しない理由が説明可能 | 返信案 + resolve 提案 |
| **不明** | 文脈が読み取れない / 採否判断ができない | ユーザーに質問 |

### 「対応不要」をさらに細分化

返信のトーンが変わるので、内部で 4 区分に分ける:

- **既対応**: 最新 commit で対応済み → 「`<sha>` で対応済みです」
- **別 PR**: スコープ外なので別 PR で扱う → 「別 PR (#NN 予定) で対応します」
- **質問への回答**: 説明だけで足りる → 内容を回答
- **採用しない**: 採用しない理由を説明 → 「<理由> のため、現状の実装で進めます」

---

## 4. 出力形式

### 4-1. 判定一覧 (まず必ずこれ)

```
スレッド N: <ファイル>:<行>  by @<reviewer>
要約: <コメント要旨 1 行>
判定: 対応必要 / 対応不要 / 不明
区分: <既対応 / 別 PR / 質問への回答 / 採用しない / コード変更要>
理由: <1 行>
```

### 4-2. 対応必要スレッドのプラン

複数ある場合は **write-plan スキルにリレー**する選択肢を提示。
単独なら:

```
- 修正対象: <ファイル:行>
- 変更内容: <何を直すか>
- テスト: <追加 / 修正する test>
- 想定影響範囲: <他に影響するか>
```

### 4-3. 対応不要スレッドの返信案

```
スレッド N (区分: <区分>)
返信本文:
---
<本文>
---
選択肢:
  [a] reply 投稿 + resolve する
  [b] reply 投稿のみ (resolve しない)
  [c] reply 内容を編集する
  [d] スキップ
```

ユーザーに承認 / 編集を求める。**まとめて承認**したい場合は「全部 a で」を許容。

---

## 5. アクション実行

承認が取れたものから順に実行。

### Reply 投稿

```bash
gh api graphql -f query='
mutation($threadId:ID!, $body:String!) {
  addPullRequestReviewThreadReply(input:{
    pullRequestReviewThreadId:$threadId, body:$body
  }) { comment { id } }
}' -F threadId=<id> -F body="$BODY"
```

### Thread resolve

```bash
gh api graphql -f query='
mutation($threadId:ID!) {
  resolveReviewThread(input:{threadId:$threadId}) {
    thread { isResolved }
  }
}' -F threadId=<id>
```

実行後、結果を 1 行で報告 (どの thread を resolve したか)。

---

## 6. やってはいけないこと

- **判定一覧を見せずに reply / resolve を実行する** (必ず承認をはさむ)
- **「Done」「Fixed」のような中身ない reply を投稿する** (sha / PR 番号 / ファイル位置を必ず添える)
- **議論を打ち切るトーンの reply を書く** (レビュアーが追問したい場合の余地を残す)
- **「対応必要」を勝手に resolve する** (必要なら code 変更を伴う作業フローへ渡す)
- **複数スレッドに同じ reply を貼り回す** (1 つの sha で複数解決する場合も、各 thread の文脈に合わせて書き分ける)
- **`isResolved: true` のスレッドを触る**
- **レビュアーへの感謝句で本文を埋める** (情報密度を落とすだけ。簡潔に事実を返す)

---

## 7. ワークフロー要約

```
1. モード宣言 (フル / 単一 / 判定のみ)
   ↓
2. 未解決スレッドを GraphQL で取得
   ↓
3. 各スレッドを 3 値で判定 → 判定一覧を提示
   ↓
4. ユーザー承認
   ├ 対応必要 → 対応方針プラン (or write-plan へリレー)
   └ 対応不要 → 返信案を提示 → 承認 → reply + resolve
   ↓
5. 実行結果を 1 行で報告
```
