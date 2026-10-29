<!-- markdownlint-disable MD013 -->

# Notion への書き込み

Notion MCP（`mcp__claude_ai_Notion__*`）を使う。書く前に `notion://docs/enhanced-markdown-spec` を `notion-fetch` で一度読む。

## 画像のアップロード

`notion-create-file-upload` で upload_url と authorization ヘッダーを受け取り、curl で multipart POST する。

```sh
curl -s -o /dev/null -w "%{http_code}\n" -X POST "<upload_url>" -H "authorization: Bearer <token>" -F "file=@<path>;type=image/jpeg"
```

200 が返れば成功。本文には `<image src="file-upload://<file_upload_id>"></image>` で埋め込む。URL は 10 分ほどで失効するので、アップロード直後にページへ書く。

複数枚あるときは `notion-create-file-upload` を並列に呼び、curl も並列に投げる。

## 番号付きリストと画像

Notion は番号付きリストの途中に画像を挟むと番号が 1 に戻る。1〜3 の後に画像、4〜5 と書くと 1〜3、画像、1〜2 と表示される。

対策は、手順をすべて書き切ってから画像を置くこと。1 ステップに画像が 2 枚あるなら 2 枚とも手順の後に並べる。

## 部分更新の制約

`update_content` は本文の文字列しか一致させられない。画像ブロック（`![](notion-file-block://...)`）や表を含む範囲を old_str にすると No matches found になる。

- 文章だけの差し替えは `update_content` でよい。
- 画像や表を動かす、差し替える、消すときは `notion-fetch` で現在の本文を取り、既存画像の `notion-file-block://` 参照をそのまま使って `replace_content` で全文を書き直す。新しい画像だけ `file-upload://` で書く。
- `replace_content` 後は既存画像の参照 ID が変わる。次の全文書き換えの前に必ず `notion-fetch` し直す。

## タイトル

ページのタイトルは `update_properties` で `{"title": "..."}` を渡す。本文の先頭に `#` 見出しでタイトルを書かない。

## 書いた後

`notion-fetch` で読み戻し、見出しの階層、番号の連続、画像の位置を確認する。全文書き換えのたびに行う。
