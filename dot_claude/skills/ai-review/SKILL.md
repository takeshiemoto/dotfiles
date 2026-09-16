---
name: ai-review
description: 同じ差分を Claude のサブエージェント、Codex、CodeRabbit に並列でレビューさせ、指摘を突合して pass / fix / block を出す。/ai-review [ベースブランチ] で起動する
disable-model-invocation: true
---

<!-- markdownlint-disable MD013 -->

# ai-review

別ベンダーの 3 つのレビューを互いの結果を見せずに走らせ、突合で見逃しと誤検知を減らす。このスキルはレビューだけを行い、コードは直さない。

## 1. 対象を確定する

- 引数にベースブランチがあれば、対象は `git merge-base HEAD <base>` からの差分。Codex のフラグは `--base <base>`、CodeRabbit のフラグは `--base <base>`。
- 引数がなく `git status --porcelain` が空でなければ、対象は未コミットの変更（ステージ済み、未ステージ、未追跡）。Codex のフラグは `--uncommitted`、CodeRabbit のフラグは `--uncommitted --include-untracked --base <現在のブランチ>`。CodeRabbit はリモートのないリポジトリでベースブランチを判定できずに失敗するため、`--base` を必ず付ける。
- 引数がなく作業ツリーがクリーンなら、レビュー対象なしと伝えて終了する。

対象の差分と未追跡ファイルの一覧を取得し、変更ファイル一覧と `git diff --numstat` の結果を手元に残す。

完了条件: Codex と CodeRabbit のフラグと、差分を再現するコマンドが 1 つに決まっている。

## 2. 秘密情報を確認する

差分と未追跡ファイルに次のどれかがあれば、Codex と CodeRabbit には送らず Claude 側だけで続行し、最終報告にその旨と該当箇所を書く。

- `.env` 系ファイル、`*.pem`、`*.key`、`id_rsa` などの鍵ファイル
- `-----BEGIN .*PRIVATE KEY-----`、`AKIA[0-9A-Z]{16}`、`gh[pousr]_[A-Za-z0-9]{36}`、`sk-[A-Za-z0-9_-]{20,}`
- `(api[_-]?key|secret|token|password)\s*[:=]\s*["']?[^\s"']{8,}` に一致し、プレースホルダーではない値

完了条件: Codex と CodeRabbit へ送るかどうかが決まっている。

## 3. 2 つのレビューを並列で起動する

同じ応答の中で次の 3 つを呼ぶ。手順 2 で外部送信を止めた場合は Claude だけを呼ぶ。

- Codex: Bash を `run_in_background: true` で `codex review <手順 1 のフラグ> 2>/dev/null` として起動する。標準出力が最終レビューになる。
- CodeRabbit: Bash を `run_in_background: true` で `coderabbit review --agent <手順 1 のフラグ> 2>/dev/null` として起動する。`--use-credits` は付けない。出力は 1 行 1 JSON で、`"type":"finding"` の行が指摘になる。行番号は `codegenInstructions` の `at line N` から読む。`"type":"error"` の行が出たら、そのレビューは失敗として扱い、残りで続行する。
- Claude: Agent ツールで general-purpose のサブエージェントを起動する。プロンプトには対象の差分を再現するコマンドと下記の出力形式だけを渡し、Codex の存在や結果には触れない。

サブエージェントへ渡す指示:

- 読み取り専用でレビューする。ファイルを変更しない。
- 差分全体と、変更箇所の理解に要る周辺コード、呼び出し元、テストを読む。
- この変更が持ち込んだ欠陥だけを指摘する。正しさ、セキュリティ、性能、保守性に実害があり、再現する経路をコードで示せるものに限る。
- 指摘ごとに、優先度（P0 から P3）、`path:行`、欠陥の要約、発生する入力と結果、修正の方向を書く。セキュリティの指摘には分類（injection、XSS、SSRF、認可、秘密情報、その他）を付ける。
- 指摘がなければ、指摘なしと 1 行で返す。

起動したすべての完了通知が届くまで待つ。

完了条件: 起動したすべてのレビューについて、結果か失敗が揃っている。

## 4. 指摘を突合する

全レビューの指摘を、ファイル、行範囲、欠陥の中身で対応付ける。同じファイルで行範囲が重なり、同じ欠陥を指すものを一致とみなす。CodeRabbit の severity は critical を P0 から P1、major を P1 から P2、minor 以下を P3 として読む。

- 2 つ以上のレビューが一致した指摘: 採用する。優先度が食い違えば高い方を取る。
- 1 つのレビューだけの指摘: 指摘された `path:行` と周辺コードを自分で読み、発生する入力と結果を確かめる。確かめられたら採用し、確かめられなければ却下して理由を 1 行で残す。

完了条件: 全指摘が採用か却下のどちらかに分類され、却下には理由がある。

## 5. security-review への昇格を判定する

次の条件のどれかに当たれば、ユーザーに `/security-review` の実行を勧め、当たった条件を示す。`/security-review` は非対話で実行できないため、このスキルからは起動しない。

- A 変更パス: `auth`、`payment`、`migration`、`middleware`、`Dockerfile`、`.github/workflows/`、`*.sql`、ロックファイル（`package-lock.json`、`pnpm-lock.yaml`、`yarn.lock`、`bun.lock`、`Gemfile.lock`、`poetry.lock`、`uv.lock`、`Cargo.lock`、`go.sum`）を含む
- B 追加行の内容: 暗号処理、SQL 文字列の連結や埋め込み、`innerHTML`、`dangerouslySetInnerHTML`、デシリアライズ（`pickle.loads`、`yaml.load`、`unserialize` など）、`eval`、`exec`、`child_process`、`subprocess` を含む
- C 規模: 変更ファイルが 20 を超える、または追加行が 1,000 を超える
- D 採用した指摘: injection、XSS、SSRF、認可、秘密情報のどれかに分類されるものがある
- E 判定の食い違い: 1 つのレビューだけが P0 か P1 のセキュリティ指摘を出し、ほかのレビューが同じ箇所に何も出していない

完了条件: A から E のそれぞれに当否が付いている。

## 6. 結論を報告する

結論は次の順で最初に当たったものにする。

- block: 採用した指摘に P0 がある、または D に当たる
- fix: 採用した指摘が 1 件以上ある
- pass: 採用した指摘がない

報告には次を含める。

- 結論と対象（ベースブランチか未コミットか）
- 採用した指摘: 優先度、`path:行`、要約、出どころ（指摘したレビューの名前をすべて）
- 却下した指摘と理由
- 当たった昇格条件と `/security-review` の推奨。当たらなければ省く
- 手順 2 で Codex と CodeRabbit を外した場合、または手順 3 で失敗したレビューがある場合はその旨
