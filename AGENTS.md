<!-- markdownlint-disable MD013 -->

# dotfiles

## エージェント・ガイドライン

- オーバーエンジニアリングは禁止。ただし、既存の設計には忠実であること。
- 冗長に見える場合でも、設計意図を守るために必要なら許容する。
- 実装判断では、対象がスケールするかを重視する。数が増えてもパフォーマンスや可読性を維持できるかを確認する。

## 回答スタイル

- アウトプットは適切にセクション分けする。
- 各セクションは200文字以内を目安にする。

## リポジトリ概要

macOS 環境の設定ファイルを [chezmoi](https://www.chezmoi.io/) で一元管理するリポジトリ。人間向けのセットアップ手順は README にあり、このファイルが設計と規約を持つ。

## 設計方針

- 汎用の設定だけを追跡する。マシン固有と案件固有の値は `~/.gitconfig.local` や `~/.config/chezmoi/chezmoi.toml` などローカルにだけ置き、このリポジトリには入れない
- 実行時状態はツールに委ねる。管理対象のキーだけを強制し、ツールが実行時に書く内容はそのまま通す。`chezmoi apply` がアプリと喧嘩しない状態を保つ
- 構成から再現する。Brewfile が変われば `brew bundle` が、mise 設定が変われば `mise install` が再実行される。tap は `dot_config/private_homebrew/` で事前信頼済み、フォントも Brewfile から入る
- cask は `chezmoi init` の対話で選ぶ。`.chezmoi.toml.tmpl` が cask ごとに導入可否を聞き、回答は `~/.config/chezmoi/chezmoi.toml` の `[data.install]` にローカル保存され、Brewfile テンプレートと `.chezmoiignore` が `.install` フラグで分岐する。CLI 系は設定ファイルが依存するため無条件で入れる

## ディレクトリ構造

chezmoi の命名規約に従う。`dot_` は `~/.` に展開され、`private_` はパーミッション 600、`*.tmpl` はテンプレート処理される。

- `dot_zshrc`, `dot_zshenv`: zsh。abbr、autosuggestions、peco のヒストリ検索と ghq リポジトリジャンプ
- `dot_gitconfig.tmpl`: git 設定。末尾で `~/.gitconfig.local` を include
- `dot_config/wezterm/`: WezTerm。vague カラー、JetBrains Mono と IBM Plex Sans JP のフォールバック
- `dot_config/nvim/`: Neovim (LazyVim)。vague カラースキーム
- `dot_config/lazygit/`: lazygit
- `dot_config/git/ignore`: グローバル gitignore
- `dot_config/zsh-abbr/`: zsh-abbr 略語定義
- `dot_config/herdr/`: herdr
- `dot_config/private_homebrew/`: brew の tap 信頼リスト（trust.json）と Brewfile の描画先（Brewfile.tmpl → `~/.config/homebrew/Brewfile`）
- `.chezmoi.toml.tmpl`: `chezmoi init` 時の対話プロンプト（git identity と cask ごとの導入可否）
- `.chezmoitemplates/Brewfile`: Brewfile 本体。cask は `.install` フラグで条件分岐する
- `dot_config/private_karabiner/`: Karabiner-Elements。Esc で英数も送出し、単押しの Cmd で IME を切り替える
- `dot_config/mise/`: mise グローバル設定
- `dot_config/ccstatusline/`: ccstatusline（Claude Code ステータスライン）
- `dot_claude/`: Claude Code ユーザースコープ設定（settings.json、rules、skills）
- `dot_codex/`: Codex ユーザースコープ設定
- `ghq/github.com/takeshiemoto/obsidian/dot_obsidian/`: Obsidian vault 設定。appearance や core plugins などの宣言的設定だけを追跡し、workspace.json など実行時状態は追跡しない

bootstrap スクリプト:

- `bootstrap.sh`: まっさらな Mac の入口（chezmoiignore 済み）。sudo キープアライブ、chezmoi init、Claude Code のインストール、herdr 統合、GitHub CLI ログイン
- `run_once_before_install-brew.sh`: apply 前に 1 回。Homebrew をインストールする
- `run_onchange_after_brew-bundle.sh.tmpl`: 描画後の Brewfile 変更時（apply 後）に `brew bundle --no-upgrade` を実行する
- `run_onchange_after_macos-defaults.sh`: macOS のキーボードと Dock の設定を `defaults write` で適用する。キーボードの反映には再ログインが要る
- `run_onchange_after_mise-install.sh.tmpl`: mise 設定変更時に `mise install` を実行する

run スクリプトは初回 apply 時に brew が PATH に無い前提で書く（スクリプト内で brew shellenv を eval する）。

## AI エージェントの設定管理

Claude Code と Codex も他のツールと同じ dotfiles として扱う。ユーザースコープの settings と rules、自作スキルを追跡し、セッション、キャッシュ、認証状態は追跡しない。新しいファイルを作ったら `chezmoi add` で都度取り込む。

skills.sh で入れた外部スキルの実体は `~/.agents/skills` にあり、このリポジトリは `~/.claude/skills` 配下の symlink（`symlink_` ソース）だけを追跡する。

## ツールが書き換える設定

- Codex の `~/.codex/config.toml` は `modify_` スクリプトで管理する。管理キー（model 等）だけを強制し、Codex が実行時に追記する設定はそのまま通す
- 素の追跡ファイルは、ツールのシリアライザ形式に source を合わせて diff を恒常ゼロにする。`dot_claude/private_settings.json` は Claude Code の書き戻しと同一バイト（形式はバージョンで変わるため、ドリフトしたら `chezmoi add` で追随する）、`dot_gitconfig.tmpl` は gh が書く空 helper 行（`=` の後に末尾スペース）と gist セクションを同一バイトで含む

## 変更時の注意

- 設定ファイルの追加・移動時は chezmoi 命名規約に従う（`dot_*`、`private_*`、`*.tmpl`）
- 仕事識別子（勤務先・案件・社内ツールを特定できる名称やプレフィックス）や machineId 系の値は dotfiles に commit しない。ルール文中にも実名を書かない
- ツール追加時は `.chezmoitemplates/Brewfile` に追記する。cask を任意化する場合は `.chezmoi.toml.tmpl` に promptBoolOnce を足し、`.install` フラグで分岐する
- このリポジトリ固有の指示は `AGENTS.md` に書く（chezmoiignore 済み）
