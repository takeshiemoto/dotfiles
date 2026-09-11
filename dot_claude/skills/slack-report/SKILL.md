---
name: slack-report
description: >-
  「Slack にも流して」「Slack に投稿して」「DM に送って」「#channel に流して」のように、
  直前の回答を Slack へ送る指示を受けたら、Slack MCP を呼ぶ前に必ず使う。
  直前の回答を固定の型（結論 1 段落・箇条書き 4 件まで・参照 3 件）へ再構成し、
  指定なしなら自分の DM、指定ありならそのチャンネルへ確認なしで送信する。
  告知文の作成や日報の生成は対象外。
---

<!-- markdownlint-disable MD013 -->

# slack-report — 直前の回答を Slack へ流す

自分あての備忘が主用途。読者は走査するので、走査で全体が掴める型に固定する。

## 手順

1. 宛先を決める。指定なしは自分の DM。`slack_send_message` の説明にある current user の user_id を `channel_id` にする。チャンネル指定は `slack_search_channels` を `channel_types: public_channel,private_channel` で引き、名前が完全一致する 1 件を使う。一致が 0 件か複数なら候補を示して聞き返す。
2. 直前の回答を下記の型に流し込む。型の枠を超える情報は捨てる。
3. `slack_send_message` で送信する。送信前の確認は取らない。
4. 返ってきたメッセージリンクを 1 行で報告する。

詳細が無いと備忘として成立しない場合だけ、本文送信後にスレッド返信を 1 通付ける。返信も同じ規則で書く。

## 型

3 つのブロックを空行で区切る。ラベルは付けない。ブロックの形の違いで見分ける。

```markdown
1 文目で答え、続く文で補足する。改行せず 1 段落、3 文以内。

- 根拠となる事実 1
- 根拠となる事実 2
- 根拠となる事実 3
- 次にやること 1 件。無ければ省く

- URL かパス。3 件まで。無ければブロックごと省く
```

## 規則と根拠

各規則は読みやすさ研究に基づく。根拠を崩す変更はしない。

- 結論を先頭に置く。読者は上部を最も読む F 字型の走査をし、本文の約 20% しか読まない。Nielsen 2006 F-Shaped Pattern、Nielsen 2008 How Little Do Users Read。BLUF は Army Regulation 25-50 の規定。
- 箇条書きは 4 件まで。次にやることは常に最後の項目に置き、位置で見分ける。短期記憶の容量は 4±1 チャンク。Cowan 2001 The Magical Number 4。
- 段落内では改行しない。改行はブロックの区切りと箇条書きの区切りだけに使い、横幅は Slack の折り返しに任せる。
- 装飾は使わない。太字・絵文字・表・見出し記法・引用・コードブロック・バッククォートのいずれも用いず、平文と箇条書きだけで書く。パス・コマンド・エラー文も平文のまま書く。絵文字なしのメッセージが最も有能と評価される。Collabra: Psychology, Emojis at Work。
- 構造データは 項目: 値 の形の箇条書きにする。
- 本文にはリンクを混ぜず参照ブロックに集める。

## 出典

- https://www.nngroup.com/articles/f-shaped-pattern-reading-web-content-discovered/
- https://www.nngroup.com/articles/how-little-do-users-read/
- https://www.cambridge.org/core/services/aop-cambridge-core/content/view/44023F1147D4A1D44BDC0AD226838496/S0140525X01003922a.pdf
- https://online.ucpress.edu/collabra/article/12/1/147309/217078/Emojis-at-Work-The-Effects-of-Emoji-Use-on
- https://armypubs.army.mil/epubs/DR_pubs/DR_a/ARN42124-AR_25-50-007-WEB-13.pdf
