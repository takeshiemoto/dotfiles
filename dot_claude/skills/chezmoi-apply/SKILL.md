---
name: chezmoi-apply
description: >-
  Apply an instructed configuration change to chezmoi-managed dotfiles, then run
  `chezmoi apply` to propagate it to the live files. Use this skill whenever the
  user asks to change, add, or tweak a config managed by chezmoi (anything under
  the dotfiles source repo such as dot_config/, dot_claude/, files with dot_/
  private_/ executable_/ run_/ modify_ prefixes or .tmpl templates) and wants the
  change reflected to their home directory. Triggers on requests like "WezTermの
  設定をこう変えて反映して", "この設定を適用して chezmoi apply して", "dotfilesに〜を
  追加して反映".
---

# chezmoi 設定変更 → apply

chezmoi で管理された設定を変更し、ライブのファイル（`$HOME` 配下）へ反映するまでを一気通貫で行うスキル。

## 大原則：ソースを編集する。ターゲットを直接編集しない

このリポジトリは chezmoi の**ソースディレクトリ**そのもの。編集対象は必ずソースファイル（リポジトリ内のファイル）であり、`$HOME` 配下のライブファイルではない。ライブファイルを直接編集しても、次の `chezmoi apply` で上書きされて失われる。

ソースファイルは chezmoi の命名規則で属性が表現される：

| プレフィックス / 拡張子 | 意味 |
|---|---|
| `dot_` | ターゲットでは `.` で始まる（例 `dot_config/` → `~/.config/`） |
| `private_` | パーミッション 600 |
| `executable_` | 実行ビット付き |
| `run_` | apply 時に実行されるスクリプト（冪等性に注意） |
| `modify_` | 既存ファイルを stdin で受け取り加工して出力するスクリプト |
| `.tmpl` | Go テンプレート。`{{ }}` を含む |

## ワークフロー

### 1. 対象のソースファイルを特定する

ユーザーがライブのパス（例 `~/.config/wezterm/wezterm.lua`）で指示してきたら、対応するソースを引く：

```bash
chezmoi source-path ~/.config/wezterm/wezterm.lua
```

逆に、リポジトリ内のソースがどのライブパスに対応するか確認したいとき：

```bash
chezmoi target-path dot_config/wezterm/wezterm.lua
```

管理下にあるファイル一覧：

```bash
chezmoi managed | grep -i wezterm
```

### 2. ソースファイルを編集する

通常ファイルは Edit/Write でソースを直接書き換える。ただし注意：

- **`.tmpl` テンプレート** … `{{ }}` の構文を壊さないこと。リテラルの `{{` が必要な場合は `{{ "{{" }}`。
- **`modify_` スクリプト** … 出力されたファイルではなく**スクリプト本体**を編集する（自動追記される設定はこちらで管理する）。
- **`run_` スクリプト** … apply のたびに実行される。`run_once_` / `run_onchange_` の使い分けを変えないこと。

### 3. 差分をプレビューする

apply 前に必ず差分を確認し、意図した変更だけが出ているかチェックする：

```bash
chezmoi diff <target-path>      # 対象だけ
chezmoi diff                    # 全体
```

差分が予想外（無関係なファイルが出る、テンプレート展開がおかしい等）なら、apply せずに原因を調べる。

### 4. apply する

```bash
chezmoi apply <target-path>     # 対象だけ反映（推奨）
chezmoi apply                   # 全体反映
```

範囲を絞れるなら個別ターゲットを指定し、無関係なファイルへの副作用を避ける。

### 5. 反映を確認する

```bash
chezmoi diff <target-path>      # 出力が空なら反映済み
```

空であれば成功。ユーザーには「ソースを編集 → diff 確認 → apply → 反映確認」まで完了したことと、再起動やリロードが必要なツール（WezTerm 等は次回起動時に反映）があればそれを伝える。

## やってはいけないこと

- ライブファイル（`$HOME` 配下）を直接 Edit / Write する。
- `chezmoi diff` をスキップして `chezmoi apply` を実行する。
- `chezmoi add` でライブファイルを取り込もうとする（このスキルはソースを編集する流れ。`add` はソース外で行った変更を取り込むときだけ）。
- `run_` / `modify_` の出力結果を直接編集する。

## チートシート

```bash
chezmoi source-path <live-path>   # ライブ → ソース
chezmoi target-path <source-path> # ソース → ライブ
chezmoi managed                   # 管理対象一覧
chezmoi diff [target]             # 差分プレビュー
chezmoi apply [target]            # 反映
chezmoi edit <live-path>          # ソースを開く（chezmoi 経由）
```
