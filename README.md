<!-- markdownlint-disable MD013 -->

# dotfiles

![dotfiles hero](https://github.com/user-attachments/assets/4e7240e1-ea61-470c-a34e-5f0bf4491b55)

[chezmoi](https://www.chezmoi.io/) で管理する macOS 用 dotfiles。まっさらな Mac をコマンド 1 つで普段の開発環境に戻す。シェル、ターミナル、エディタ、キーボードに加えて、Claude Code や Codex といった AI エージェントの設定も同じ流儀で扱う。

[![macOS](https://img.shields.io/badge/macOS-Apple%20Silicon-000000?logo=apple&logoColor=white&style=flat-square)](https://www.apple.com/macos/) [![chezmoi](https://img.shields.io/badge/managed%20with-chezmoi-1D89C8?style=flat-square)](https://www.chezmoi.io/) [![zsh](https://img.shields.io/badge/shell-zsh-F15A24?style=flat-square)](https://www.zsh.org/) [![Neovim](https://img.shields.io/badge/editor-LazyVim-57A143?logo=neovim&logoColor=white&style=flat-square)](https://www.lazyvim.org/) [![WezTerm](https://img.shields.io/badge/terminal-WezTerm-4E49EE?style=flat-square)](https://wezterm.org/)

## クイックスタート

まっさらな Mac で実行する。

```sh
curl -fsSL https://raw.githubusercontent.com/takeshiemoto/dotfiles/main/bootstrap.sh -o /tmp/bootstrap.sh && bash /tmp/bootstrap.sh
```

この 1 コマンドで sudo をキャッシュし、chezmoi と Homebrew を導入し、全設定ファイルを配置し、Brewfile のツールと mise 管理のランタイムを入れ、Claude Code をインストールし、herdr のエージェント hook を配線し、GitHub CLI にログインする。chezmoi が既にあるマシンでは次で足りる。

```sh
chezmoi init --apply takeshiemoto
```

既存環境に重ねる場合は、先に `chezmoi diff` で差分を確認する。

## 初回セットアップチェックリスト

bootstrap が自動化できない手順。上から順に済ませる。

1. Karabiner-Elements: システム設定でドライバ拡張と入力監視を許可する
2. サインイン: `claude` を起動して `/login` する（settings に列挙されたプラグインとマーケットプレイスのインストール確認が出る）。続けて `codex`、Slack、Rancher Desktop
3. 外部スキルの復元: `~/.claude/skills` 配下の追跡済み symlink は `~/.agents/skills` を指しているため、実体を入れ直す

   ```sh
   npx -y skills add mattpocock/skills -g --skill grill-me --skill grill-with-docs -y
   npx -y skills add iKora128/stop-ai-slop-jp -g -y
   ```

4. このマシン用の Git identity: `~/.gitconfig.local` に上書きを書くか、`~/.config/chezmoi/chezmoi.toml` の `[data]` を編集して再 apply する
5. Langfuse（任意）: エージェントのトレースは `http://localhost:3000` のセルフホストインスタンスに向いている。起動した上で、そのプロジェクトの public key を `~/.claude/settings.json` の `pluginConfigs` に設定する（新規インスタンスはキーが変わる）。使わないなら `langfuse-observability` プラグインを無効にする
6. ghq 配下での source 管理（任意）: `ghq get takeshiemoto/dotfiles` した後、`~/.config/chezmoi/chezmoi.toml` の最上位に `sourceDir` を置き、`chezmoi source-path` で確認する。`[data]` セクションより下に書くと data 値として扱われてしまう

   ```toml
   sourceDir = "/Users/<you>/ghq/github.com/takeshiemoto/dotfiles"
   ```

## 設計方針

- 汎用の設定だけを追跡する。マシン固有と職場固有の値は gitignore されたローカルオーバーライドに置き、このリポジトリには入れない
- 実行時状態はツールに委ねる。管理対象のキーだけを強制し、ツールが実行時に書く内容はそのまま通す。`chezmoi apply` がアプリと喧嘩しない
- 構成から再現する。Brewfile が変われば `brew bundle` が、mise 設定が変われば `mise install` が再実行される。tap は事前に信頼済みで、フォントも Brewfile から入る

## 構成

配置先は chezmoi の命名規則どおり。`dot_` は `~/.` に、`private_` はパーミッション 600 で置かれる。

- `dot_zshrc`, `dot_zshenv`: zsh。abbr、autosuggestions、peco のヒストリ検索と ghq リポジトリジャンプ
- `dot_config/wezterm/`: WezTerm。vague カラー、リーダーキーのペイン操作、JetBrains Mono と UDEV Gothic NF のフォールバック
- `dot_config/nvim/`: Neovim (LazyVim)。vague カラースキーム、TypeScript と Go と Rust と PHP の extras、JetBrains 風の自動保存
- `dot_config/lazygit/`: lazygit
- `dot_config/private_karabiner/`: Karabiner-Elements。vim 用に Esc で英数も送出し、単押しの Cmd で IME を切り替える
- `dot_config/zsh-abbr/`: シェルの略語定義
- `dot_config/mise/`: mise によるランタイム管理
- `dot_config/herdr/`: herdr エージェントマルチプレクサ
- `dot_config/private_homebrew/`: tap の信頼リスト。`brew bundle` を無人で通すため
- `dot_config/git/ignore`, `dot_gitconfig.tmpl`: git の既定値、グローバル ignore、`~/.gitconfig.local` の include
- `dot_claude/`: Claude Code。settings、rules、ユーザースコープのスキル
- `dot_codex/`: Codex。AGENTS.md と、modify スクリプト経由の config
- `dot_config/ccstatusline/`: Claude Code のステータスライン

## AI エージェントの設定管理

Claude Code と Codex も他のツールと同じ dotfiles として扱う。ユーザースコープの settings と rules、自作スキル（commit や PR のワークフロー、chezmoi 操作、計画の grill）を追跡し、セッション、キャッシュ、認証状態は追跡しない。新しいファイルを作ったら都度取り込む。

```sh
chezmoi add ~/.claude/settings.json
chezmoi add ~/.claude/skills/<name>
```

[skills.sh](https://skills.sh) で入れた外部スキルの実体は `~/.agents/skills` にあり、このリポジトリは `~/.claude/skills` 配下の symlink だけを追跡する。新しいマシンではチェックリストの手順で実体を復元する。

## ツールが書き換える設定

Codex は `~/.codex/config.toml` を実行時に書き換え、書く内容はリリースごとに増える。chezmoi の `modify_` スクリプトで管理キー（model、reasoning effort、MCP サーバー）だけを強制し、それ以外は素通しにする。アプリが何を書いても diff は空のまま保たれる。

## 日常の操作

```sh
chezmoi diff          # 何が変わるかを見る
chezmoi add <file>    # ライブの編集をリポジトリに取り込む
chezmoi apply         # リポジトリの状態を反映する
chezmoi cd            # ソースリポジトリに移動する
```

## ローカルオーバーライド

- `~/.gitconfig.local`: 職場のメールアドレスなどマシン固有の git 設定
- `~/.config/chezmoi/chezmoi.toml`: git identity の data 値と、ソースを ghq 配下に置く場合の `sourceDir`

## ブートストラップ

- `bootstrap.sh`: まっさらな Mac の入口。sudo キープアライブ、chezmoi init、Claude Code のインストール、herdr 統合、GitHub CLI ログイン
- `run_once_before_install-brew.sh`: Homebrew が無ければインストールする
- `run_onchange_after_brew-bundle.sh.tmpl`: Brewfile が変わるたびに `brew bundle --no-upgrade` を実行する
- `run_onchange_after_macos-defaults.sh`: macOS のキーボード設定を `defaults write` で焼く。キーリピート最速、長押しポップアップ無効、内蔵キーボードと HHKB の Caps Lock を Control 化。反映には再ログインが要る
- `run_onchange_after_mise-install.sh.tmpl`: mise 設定が変わるたびに `mise install` を実行する

## フォント

主フォントは JetBrains Mono、フォールバックは UDEV Gothic NF。どちらも Brewfile から入るので、新しいマシンで手動のフォント作業は無い。
