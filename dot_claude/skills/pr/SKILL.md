---
name: pr
description: >-
  現在のブランチを push し、リポジトリの PR テンプレート（.github/PULL_REQUEST_TEMPLATE.md 等）に
  厳格に従って本文を組み立て、`gh pr create --draft` で Pull Request を作るスキル。ベースブランチは
  引数で必須指定する（例 `/pr develop`）。現在ブランチに既存 PR があれば新規作成せず本文を更新する。
  ユーザーが `/pr` で呼んだ時、または「PR 作って」「プルリク
  出して」「PR 作成して」のように今 PR を作りたい意図を明示した時に使う。確認は取らず自律実行するが、
  ベース未指定・テンプレート未発見など曖昧な時だけ止めて聞く。「PR を見せて」「PR 規約はどうなってる?」
  のような閲覧・規約の説明・一般的な質問では使わない（実行指示の時だけ）。
---

<!-- markdownlint-disable MD013 -->

# pr — テンプレート順守で PR を作る

`/pr <base>` で push から PR 作成までを確認なしで自律実行する。最優先はリポジトリのテンプレート厳守。コミット生成は範囲外（`commit` スキルの責務）。未コミット変更があってもコミットしない・警告のみ。

## 停止条件（自律実行の例外）

以下は止めて確認・報告する。停止時は、そこまでに判明した事実（未コミット変更・現在ブランチ・ベース・差分有無）も併せて伝える。

- ベース引数未指定（推測・自動検出しない）／指定ベースがリモートに無い。
- git リポジトリでない／`gh` 未認証。
- ベースに対し差分ゼロ（「PR にする差分がない」と伝えて終了）。
- テンプレート0件（勝手に作らない）／`PULL_REQUEST_TEMPLATE/` に複数あってどれか決められない。
- タイトル規約が要求する情報（チケット番号等）が確定できない（推測・捏造しない）。
- `git push` 拒否（force せず理由を報告）。

## 手順

1. 前提チェック：git リポジトリ・`gh auth status`・ベース引数の3点。
2. 差分確認：`git log <base>..HEAD` と `git diff <base>...HEAD`（3点表記）。未コミット変更があれば「PR に含まれない」と一言警告して続行。
3. テンプレート探索：GitHub 標準配置を大文字小文字・拡張子（`.md`/`.txt`/無し）のゆれ込みで探し、1件ならそれを使う。

   ```bash
   find . \( -path './.github/PULL_REQUEST_TEMPLATE*' \
           -o -iname 'PULL_REQUEST_TEMPLATE.md' \
           -o -ipath './docs/PULL_REQUEST_TEMPLATE*' \) -not -path './.git/*'
   ```

4. 本文生成：[references/body.md](references/body.md) を正として組み立てる。叙述の素材は手順2の log/diff のみ。
5. タイトル生成：[references/title.md](references/title.md) の規約探索・適用・自己照合に従う。
6. push：停止条件を全通過してから `git push -u origin HEAD`（中断する PR のブランチを公開しないため最後に置く）。
7. PR 作成/更新：
   - 既存 PR（`gh pr view --json number,url,state`）があれば `gh pr edit <number> --body-file <tmp>` で本文のみ全面再生成・置換。タイトルは触らない（手修正を潰さない）。手追記は保持されない旨を報告に1行添える。
   - なければ `gh pr create --base <base> --head <current> --draft --assignee takeshiemoto --title "<title>" --body-file <tmp>`。assignee は常に `takeshiemoto` 固定。本文は一時ファイル経由（エスケープ事故回避）。
8. 報告：ベース・draft を述べ、URL は半角スペースを挟んで行末に置く（例 `PR を作成した（base: develop、draft）: <URL>`）。URL の直後に文字を続けない（ターミナルのリンク検出が壊れる）。

## やらないこと

- コミットしない・force push しない。
- テンプレート構造を改変しない（節の増減・並べ替え・コメント削除）。
- draft 以外で作らない（常に `--draft`）。
- 停止条件以外で確認を取らない（本文・タイトル案の事前承認も求めない）。
