<!-- markdownlint-disable MD013 -->

# 撮影の手順

## 注釈ヘルパーの注入

`scripts/annotate.js` の中身を `javascript_tool` にそのまま渡して評価する。`window.__annot` が定義される。フルロードの遷移で消えるので、`navigate` の後は注入し直す。

主な関数。

- `__annot.box(el, 番号, 'ラベル', 'left')`: 枠と丸数字。フォーム項目は `'left'`、ボタンやリンクは第 4 引数なし。
- `__annot.field('項目名')`: 項目名から入力欄の枠要素を引く。
- `__annot.button('ボタン名')`: 表示文字からボタンやリンクを引く。
- `__annot.maskText('表示名')`: ヘッダーのユーザー名などを隠す。
- `__annot.rect(l, t, r, b)`: 複数要素をまとめて囲む矩形。右端は値の要素の right から取る。親要素の right を使うと幅が潰れることがある。
- `__annot.clear()`: 全部消す。

## 1 枚を撮る流れ

1. 撮りたい区画を `scrollIntoView({block:'start'})` で上端に寄せ、`window.scrollBy(0,-16)` で見出しの余白を作る。400ms ほど待つ。
2. `__annot.clear()` → `__annot.maskText(...)` → `__annot.box(...)` の順に重ねる。ラベルは手順番号と同じ丸数字にする。
3. `document.activeElement.blur()` でフォーカスを外す（入力欄のカーソルが写るため）。
4. `computer` の hover でマウスを右下隅（viewport 幅-1, 高さ-1）へ逃がす。
5. `computer` の screenshot を `save_to_disk: true` で撮る。返ったパスを scratchpad に `stepN-内容.jpg` の名前で `cp` する。
6. `__annot.clear()`。

撮った画像は必ず自分の目で見る。確認する点は、ラベルが項目名や説明文に被っていないか、右端で切れていないか、枠の幅が潰れていないか、カーソルやトーストが写っていないか。

## ラベルの位置

- フォーム項目は `'left'`。項目名と入力欄の間の余白に収まる。項目名が長くて近いときはラベルの文字を短くする（IdP エンティティ ID → エンティティ ID）。
- 枠の上にラベルを置くと、直前の項目の説明文に被る。フォームでは使わない。
- 画面右上のボタンは第 4 引数なしでよい。右端の折り返しはヘルパーが面倒を見る。
- コピーボタンのような小さい対象は、入力欄全体でなくボタンだけを囲み、ラベルを `'left'` で付けると項目名が隠れない。

## 1 画面に収まらないとき

長文を貼る textarea は内容に合わせて伸び、後続の項目や送信ボタンが viewport から押し出される。2 枚に分けると同じ欄が両方に写って重複するので、1 枚に収める。

```js
const ta = [...document.querySelectorAll('textarea')].find(t => t.value.startsWith('-----BEGIN'));
ta.style.height = '160px'; ta.style.overflowY = 'auto'; ta.style.resize = 'none';
```

この加工をしたら、報告に 撮影のため入力欄の高さを抑えた と書く。実画面と見た目が違うため。

## トースト

登録直後のトーストは数秒で消える。撮影前に 4 秒ほど待つか、`[role=alert]` 内の閉じるボタンを押す。

## ダミー証明書

X.509 の形式チェックがある欄には、openssl で自己署名証明書を作って貼る。有効期限や発行先が詳細画面に表示されるので、架空と分かる CN にする。

```sh
openssl req -x509 -newkey rsa:2048 -nodes -keyout <scratchpad>/idp.key -out <scratchpad>/idp.crt -days 730 -subj "/CN=idp.example.com/O=Example IdP"
```

鍵と証明書は scratchpad に置き、成果物に混ぜない。

## ログイン画面

ログイン済みのセッションではログイン画面を開けない（/login が自動で転送される）。撮るにはログアウトが要り、ログアウトすると以降の設定画面は撮れず、作ったデータの削除もできなくなる。順序は、設定画面の撮影をすべて終える → 依頼者の許可を得てログアウト → ログイン画面を撮る。

ログイン画面でダミーのメールアドレス（登録したドメインのもの）を入れて次へ進むと、SSO ボタンなど分岐後の画面が撮れる。パスワード入力や SSO ボタンの押下はしない。
