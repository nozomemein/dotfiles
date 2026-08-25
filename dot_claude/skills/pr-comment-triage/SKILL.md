---
name: pr-comment-triage
description: |
  GitHub PR の未解決レビューコメントを取得して triage する。
  - 対応必要 → 修正を実装して commit / push し、reply + thread resolve まで実行 (デフォルト)
  - 対応不要 → 返信を投稿して thread resolve まで実行 (デフォルト)
  - プラン提示だけ・承認制にしたい場合は明示指示
  トリガー: "PRコメント対応", "PRコメントみて", "PRコメント triage", "review コメント対応", "pr comment triage"
  使用場面: (1) レビューを受けた直後の triage, (2) 修正 push 後の再レビュー対応, (3) 古い PR の積み残しコメント整理
---

# PR Comment Triage

PR のレビューコメントを 1 件ずつ triage し、「修正して resolve する / 返信して resolve する」まで実行するスキル。

主旨:
1. **未解決スレッドだけ対象**にする (resolve 済みは触らない)
2. 「対応必要 / 対応不要 / 不明」の 3 値で判定
3. **「対応必要」は特段の指示がなければ修正を実装して commit / push し、reply + resolve まで実行する**
4. **「対応不要」は特段の指示がなければ reply 投稿 + resolve まで実行する**
5. 判定一覧・返信本文・修正内容はその場で提示する。承認待ちにするのは「判定のみ」「プランのみ」「承認制で」など明示指示があるときだけ

---

## 1. 動作モードを決める

| モード | 用途 |
|---|---|
| **フル** (デフォルト) | 未解決スレッド全件を 1 周 triage し、「対応必要」は修正実装 + commit / push + reply + resolve、「対応不要」は reply + resolve まで実行 |
| **単一** | 指定 thread id だけ処理 (フルと同じく実行まで) |
| **判定のみ** | 修正 / reply / resolve は一切しない、判定結果だけ提示 |
| **プランのみ** | 「対応必要」は対応方針プランの提示まで (write-plan へリレー可)。修正は実装しない |
| **承認制** | 修正内容・返信案を提示して承認を待ってから実行 |

特段の指示がなければ **フル** で動く。「判定のみ」「プランのみ」「承認制」は、ユーザーがそう言ったときだけ選ぶ。

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
| **対応必要** | コード変更 / ドキュメント追加 / テスト追加など作業が要る | 修正実装 + commit / push + reply + resolve (デフォルトで実行) |
| **対応不要** | 既対応 / 別 PR で扱う / 質問への回答だけで足る / 採用しない理由が説明可能 | reply 投稿 + resolve (デフォルトで実行) |
| **不明** | 文脈が読み取れない / 採否判断ができない | ユーザーに質問 (修正 / reply / resolve はしない) |

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

### 4-2. 対応必要スレッドの修正

デフォルト (フル / 単一) では、修正方針を提示したうえで **そのまま実装 → commit → push → reply + resolve まで実行する**。

各スレッドについて、実装前に方針を 1 ブロックで示す:

```
- 修正対象: <ファイル:行>
- 変更内容: <何を直すか>
- テスト: <追加 / 修正する test>
- 想定影響範囲: <他に影響するか>
```

実装の流れ:

1. 修正を実装し、関連テスト (あれば) を実行して通す
2. commit する (下記の Co-Authored-By trailer を付ける)。関連する複数スレッドを 1 commit にまとめてよい
3. push する (**push 前に reply / resolve しない**。sha がリモートに存在しない状態でレビュアーに提示しないため)
4. 各スレッドに「`<sha>` で対応しました + 変更の要旨」を reply して resolve

修正の規模が大きい / 設計判断を伴う場合は無理に 1 周で終わらせず、そのスレッドだけ「プラン提示 + ユーザー確認」に切り替えてよい (**プランのみ** モードでは全スレッドこの動きになり、write-plan スキルへのリレーも選択肢として提示する)。

#### 対応 commit には Co-Authored-By を付ける

レビューコメントの指摘を取り込んだ commit には、コメントの writer を trailer として追加する:

```text
Co-Authored-By: <login> <<id>+<login>@users.noreply.github.com>
```

- noreply メールアドレスは `gh api users/<login> --jq '"\(.id)+\(.login)@users.noreply.github.com"'` で組み立てる
- 1 commit で複数レビュアーの指摘を取り込んだ場合は、人数分の trailer を並べる
- 対象は **指摘を反映した commit だけ**。「対応不要」で reply する場合や、指摘と無関係の commit には付けない

### 4-3. 対応不要スレッドの返信

デフォルト (フル / 単一) では、返信本文を提示したうえで **そのまま reply 投稿 + resolve を実行する**。

```
スレッド N (区分: <区分>)
返信本文:
---
<本文>
---
→ reply 投稿 + resolve 済み
```

**承認制** モードのときだけ、実行前に選択肢を提示して承認を待つ:

```
選択肢:
  [a] reply 投稿 + resolve する
  [b] reply 投稿のみ (resolve しない)
  [c] reply 内容を編集する
  [d] スキップ
```

**まとめて承認**したい場合は「全部 a で」を許容。

---

## 5. アクション実行

デフォルトでは「対応不要」の reply + resolve を先に済ませ、その後「対応必要」の修正 → commit / push → reply + resolve を実行する。承認制のときは承認が取れたものから順に実行。

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

- **判定一覧と返信本文・修正内容を見せずに実行する** (実行はするが、何を変更しどう投稿したかは必ず可視化する)
- **「判定のみ」「プランのみ」「承認制」と指示されているのに修正 / reply / resolve を実行する**
- **「不明」のスレッドに reply / resolve する** (ユーザーに質問して判定が確定してから)
- **「Done」「Fixed」のような中身ない reply を投稿する** (sha / PR 番号 / ファイル位置を必ず添える)
- **議論を打ち切るトーンの reply を書く** (レビュアーが追問したい場合の余地を残す)
- **「対応必要」を修正せずに resolve する** (resolve は修正を push して sha を reply で示した後だけ)
- **テストを実行せずに (または fail のまま) 修正 commit を push する** (テストが無い repo ではこの限りではない)
- **複数スレッドに同じ reply を貼り回す** (1 つの sha で複数解決する場合も、各 thread の文脈に合わせて書き分ける)
- **`isResolved: true` のスレッドを触る**
- **レビュアーへの感謝句で本文を埋める** (情報密度を落とすだけ。簡潔に事実を返す)

---

## 7. ワークフロー要約

```
1. モード宣言 (デフォルト: フル / 指示があれば 単一・判定のみ・プランのみ・承認制)
   ↓
2. 未解決スレッドを GraphQL で取得
   ↓
3. 各スレッドを 3 値で判定 → 判定一覧を提示
   ↓
4. 判定ごとに分岐 (承認制のときだけ実行前に承認を待つ)
   ├ 対応必要 → 修正方針を提示 → 実装 → commit / push → reply + resolve
   │            (プランのみモードならプラン提示 or write-plan へリレーで止める)
   ├ 対応不要 → 返信本文を提示 → reply + resolve を実行
   └ 不明     → ユーザーに質問
   ↓
5. 実行結果を報告 (修正 commit の sha / resolve した thread)
```
