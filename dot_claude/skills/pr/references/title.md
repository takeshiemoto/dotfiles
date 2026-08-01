<!-- markdownlint-disable MD013 -->

# PR タイトルの付け方

簡潔第一。`<prefix>:` を除く本体は日本語30文字以内を目安に、主目的だけを1フレーズで言い切る。変更の列挙・手段・補足はタイトルに入れず本文へ回す。「〜し、〜する」のような複数事項の接続や `（…）` での補足は避け、文末の「〜する」等も削る。

## 規約探索

命名規約の定義がリポジトリ内に在るかを網羅的に調べる（テンプレ探索と同格の必須手順）。既存 PR やコミット履歴から推測しない。規約は明示的に定義された情報源からだけ取る。規約を見落として独自フォーマットで付けるのが最頻の事故。型（`fix:` 等）の外側に付くプレフィックス／スコープ／チケット番号を落とさない。「定義なし」と結論してよいのは、下記をすべて当たって痕跡が無いときだけ。

定義が置かれうる場所（網羅的に当たる）：

1. PR タイトル lint（CI で落ちる＝最優先で適合）：

   ```bash
   grep -rilE 'semantic.?pull.?request|pr.?title|commitlint|release.?please' .github 2>/dev/null
   ```

   `amannn/action-semantic-pull-request`・`.github/semantic.yml`・commitlint・release-please 等の必須形式・許可 type/scope。
2. 規約・設定ファイル：

   ```bash
   ls CONTRIBUTING.md .github/CONTRIBUTING.md docs/CONTRIBUTING.md CLAUDE.md AGENTS.md commitlint.config.* .commitlintrc* .czrc cz.json 2>/dev/null
   ```

   ＋ PR テンプレ冒頭の HTML コメント（`PULL_REQUEST_TEMPLATE/` 含む）、`package.json` の commitlint 節、`README`・`docs/**` に書かれた命名／ブランチ／PR タイトル規則、`CLAUDE.md`/`AGENTS.md`。
3. チケット番号の供給元：定義された規約が番号を要求する場合のみ、その値を現在のブランチ名から取る（`git branch --show-current`、例 `feature/ABC-1234-radio-hover` → `ABC-1234`）。確定できなければ捏造せず停止。

## 適用

1. 定義あり → その構造を完全に再現して厳格適合。衝突時は CI で落ちる lint 設定を最優先。
2. 定義された規約が要求する情報（チケット番号等）が確定できなければ停止して聞く（推測・捏造しない）。
3. 定義なし（上記すべてを当たって痕跡なし）→ フォールバックで `commit` スキル準拠の `<prefix>: <日本語の説明>` 1行。コミット1個ならそのメッセージ流用、複数なら主目的を1本に要約。prefix 混在時は主目的（迷えば `feat` > `fix` > その他）。

## emit 前の自己照合（必須）

作ったタイトルを、検出した定義済み規約と1度照合する。定義が要求する要素（プレフィックス／スコープ／チケット）が欠けていれば違反 —— 付け直す。
