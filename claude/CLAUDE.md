# Claude Code 開発ガイドライン

## 基本設定

ここに書かれている内容はすべて強い制約です。必ず守ること。

### 言語設定

- 全てのコミュニケーションは日本語で行う
- 過度な丁寧語は避け、カジュアルな言葉遣いを使用する

## コーディング規約

### 全体

- 変数名、関数名などの命名は深く考えること

### TypeScript

- null を利用せず undefined を利用する
- let は使用せず、const を利用する
- else は極力使用せず、条件分岐は早期リターンで抜ける

### React

- useEffect の利用方法する前に、必ずドキュメントして利用方法が適切かを確認する
- type alias は極力使用せず、interface を利用する
- default export は使用せず、named export を利用する
- 関連する useState や useEffect は積極的にカスタム Hook にまとめる

## Gitルール

### コミットメッセージ

`<type>: <description>`

- feat: 新機能
- fix: バグ修正
- refactor: リファクタリング
- docs: ドキュメント更新
- chore: その他

## Pull Request作成ルール

- 必ず最初は Draft で作成すること
- 必ずプロジェクトの PullRequest テンプレートを参照し利用すること（ `/.github/PULL_REQUEST_TEMPLATE.md` ）
- 該当しない項目は空欄にせず明示的に `N/A` を入力すること