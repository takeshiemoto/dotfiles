<!-- markdownlint-disable MD013 -->

# Chrome の準備

Claude in Chrome（`mcp__claude-in-chrome__*`）を使う。Playwright や DevTools MCP は使わない。依頼者のログイン済みセッションをそのまま使えるのが理由。

## タブ

1. `tabs_context_mcp` を `createIfEmpty: true` で呼ぶ。別セッションのタブ ID は使えないため、毎回ここから始める。
2. `Claude in Chrome is turned off in your settings.` が返ったら、依頼者に拡張の設定で有効にしてもらい、再度 `tabs_context_mcp` を呼ぶ。有効化後はタブグループが作り直され、タブ ID が変わる。

## 幅

`resize_window` は 1 回では反映されないことがある。必ず `javascript_tool` で `window.innerWidth` を確かめる。

1. `resize_window` を幅 1290、高さ 1000 で呼ぶ（ウィンドウ枠ぶんを足して viewport が 1280 になる）。
2. `javascript_tool` で `({inner: innerWidth + 'x' + innerHeight})` を評価する。1280 でなければ、幅を 1 つ変えて（1280 → 1290 など）もう一度呼ぶ。同じ値を 2 回送っても反映されない。
3. 以降、同じセッション内では幅を変えない。

viewport の高さは 723 前後になる。1 画面に収まらないステップは、スクロールして撮るか、長い入力欄の高さを一時的に抑える（`capture.md`）。

## 画面の読み取り

- 構造を知りたいときは `read_page` を `filter: interactive` で呼ぶ。入力欄の `ref` が取れる。
- 文言を一覧したいときは `get_page_text`。補足文（ヘルパーテキスト）や初期値の説明がここで拾える。
- 入力は `form_input` に `ref` を渡す。ラジオボタンは `find` で位置を特定して `left_click` する。
- SPA の画面遷移は `javascript_tool` で該当リンクを `.click()` しても、`navigate` で URL を直接開いてもよい。未送信フォームからの離脱確認は SPA 遷移では出ないことが多いが、出たら依頼者に知らせる。
