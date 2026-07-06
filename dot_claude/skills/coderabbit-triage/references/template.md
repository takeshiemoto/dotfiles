# 分類 MD テンプレート（YAML DSL）

リポジトリ直下に `coderabbit-review-<ticket-or-pr>.md` として出力する。中身は単一の YAML を fenced code block に入れる。人間ではなくエージェントが再読する前提なので、冗長な散文は書かず構造化フィールドで埋める。

```yaml
meta:
  pr: <PR番号>
  ticket: <チケットID/任意>
  title: <PRタイトル>
  reviews: [<reviewのid…>]          # 任意。サマリーレビューのid
  review_commit_range: [<base短縮>, <head短縮>]  # 指摘が書かれた範囲。任意
  head_state: <OPEN/draft 等>
  summary: { total: N, act: a, defer: d, reject: r, resolved: s }

findings:
  - id: F1                          # 1コメント1finding。重複は dup_of でまとめる
    disposition: resolved            # resolved | reject | defer | act
    comment_id: <インラインコメントID>  # リプライ先。手順6で使う
    file: <path>
    line: <行 or null>
    claim: <指摘の要約（一文）>
    current_state: <HEADでの実態（一文）>
    evidence: <参照行/grep結果など根拠>
    # disposition 別の追加フィールド ↓
    reply: |                         # resolved/reject/defer は必須。投稿する本文そのもの
      <挨拶なし・事実と理由だけの返信>

  - id: F2
    disposition: reject
    comment_id: <…>
    file: <path>
    claim: <…>
    current_state: <…>
    reject_reason: <なぜ対応しないか。既存パターン名/スコープ外など>
    evidence: <根拠>
    reply: |
      <…>

  - id: F3
    disposition: defer
    comment_id: <…>
    file: <path>
    claim: <…>
    current_state: <…>
    defer_reason: <なぜ今やらないか>
    followup: <いつ・どう対応するか>
    reply: |
      <…>

  - id: F4
    disposition: act
    comment_id: <…>
    file: <path>
    claim: <…>
    current_state: <…>
    evidence: <…>
    action_plan:                     # 本PRで対応する手順
      - step1: <…>
      - step2: <…>
    priority: <release_blocker/normal 等>
    # actはリプライ任意。投稿するなら reply も付ける
```

## フィールドの使い分け

- `comment_id`：手順6で `pulls/<PR>/comments/<comment_id>/replies` に POST する先。全 finding に必須。
- 重複指摘：起点の finding に `dup_of: [Fx, Fy]` を持たせ、各スレッドには同趣旨のリプライを個別投稿する。
- `evidence`：「何を見てそう判定したか」を再現可能な形で（`ファイル:行`、`rg` の結果、規約のパス）。
