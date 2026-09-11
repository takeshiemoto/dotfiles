---
name: record-browser
description: >-
  ブラウザ操作の動画を撮る。実装案のデモ、修正の証跡、バグ再現の共有として
  録画して・動画にして・操作を撮って・証跡を残して、と言われたら使う。
  `/record-browser <URL> <操作手順>` でも起動する。
  Playwright MCP の browser_start_video で 2 倍密度の webm を撮り、
  ポインタと章カードを入れ、mp4 に変換してデスクトップへ置く。
  静止画のスクリーンショットだけで足りる依頼は対象外。
---

<!-- markdownlint-disable MD013 -->

# record-browser

Playwright MCP（--caps=devtools、--device Desktop Chrome HiDPI で登録済み）で操作を録画し、mp4 にして納品する。

## 手順

1. `browser_start_video` が使えることを確かめる。無ければ、Playwright MCP が未登録か devtools 無効なので、次の登録コマンドを示して止まる。

   ```sh
   claude mcp add playwright -s user -- npx -y @playwright/mcp@latest --caps=devtools --device "Desktop Chrome HiDPI"
   ```

2. `browser_navigate` で対象 URL を開く。ページが開く前に録画やポインタを有効化すると No open pages available で失敗する。ログインが要るページは、ユーザーの指示に従ってログインを済ませてから次へ進む。
3. `browser_start_video` を filename と size 2560x1440 で開始する。filename は用途を表す kebab-case に日付を付ける（例 `fix-login-toast-2026-09-11.webm`）。
4. `browser_video_show_actions` を cursor pointer、duration 1500 で有効化する。ポインタは操作間を移動し、クリック位置に赤い点、対象要素に枠が付く。
5. `browser_video_chapter` で最初の章カードを出してから、ユーザーの手順を実行する。場面が切り替わるたびに章カードを 1 枚入れる。手順は画面上の文言（ボタン名、入力値、待つ条件）で読み、要素は snapshot から解決する。待つ条件がある操作は `browser_wait_for` で満たされてから次へ進む。
6. `browser_stop_video` で停止する。返るパスは MCP プロセスの cwd 基準で、通常はセッション開始時の作業ディレクトリに置かれる。
7. webm をデスクトップへ移し、同名の mp4 を作る。

   ```sh
   ffmpeg -i <name>.webm -c:v libx264 -pix_fmt yuv420p -crf 18 -movflags +faststart <name>.mp4
   ```

8. mp4 と webm のパス、長さ、章の一覧を報告して終わる。

## 完了条件

- ユーザーの手順がすべて実行され、各場面に章カードが入っている。
- ~/Desktop に webm と mp4 が両方あり、ffprobe で 2560x1440 が確認できる。

## 補足

- 動画はページ内容の録画なので OS の実カーソルは映らない。手順 4 の仮想ポインタがその代替。
- 圧縮設定は Playwright 内蔵で固定。にじみが気になるときは size を下げず、視聴側で縮小表示する。
- 撮り直しは手順 2 からやり直す。同じ filename を指定すると上書きされる。
