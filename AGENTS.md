# dotfiles

## リポジトリ概要

macOS 環境の設定ファイルを [chezmoi](https://www.chezmoi.io/) で一元管理するリポジトリ。

## ディレクトリ構造

chezmoi の命名規約に従い、`dot_` 接頭辞をつけたファイル/ディレクトリが `~/` の対応する場所に展開される。`*.tmpl` はテンプレートとして処理される。

| ソース | デプロイ先 | 用途 |
|---|---|---|
| `dot_zshrc`, `dot_zshenv` | `~/.zshrc`, `~/.zshenv` | zsh 設定 |
| `dot_gitconfig.tmpl` | `~/.gitconfig` | git 設定（末尾で `~/.gitconfig.local` を include） |
| `dot_config/wezterm/` | `~/.config/wezterm/` | WezTerm |
| `dot_config/nvim/` | `~/.config/nvim/` | Neovim (LazyVim) |
| `dot_config/lazygit/` | `~/.config/lazygit/` | Lazygit |
| `dot_config/git/ignore` | `~/.config/git/ignore` | グローバル gitignore |
| `dot_config/zsh-abbr/` | `~/.config/zsh-abbr/` | zsh-abbr 略語定義 |
| `dot_claude/` | `~/.claude/` | Claude Code ユーザースコープ設定 |
| `dot_codex/` | `~/.codex/` | Codex ユーザースコープ設定 |

bootstrap スクリプト:

| ファイル | 実行タイミング | 用途 |
|---|---|---|
| `run_once_before_install-brew.sh` | apply 前に1回 | Homebrew をインストール |
| `run_once_after_brew-bundle.sh.tmpl` | apply 後に1回 | `brew bundle` を実行 |

## マシン固有設定の分離

dotfiles で管理するのは「全案件で共通利用できるもの」のみ。**マシン固有・案件固有の設定は dotfiles に書かない**。

| ツール | 仕事/マシン固有設定の置き場 |
|---|---|
| git | `~/.gitconfig.local`（dotfiles で管理せず、各マシンに直接置く） |
| Claude Code | `~/.claude/settings.local.json`（gitignore 済み。仕事用プラグイン等はここ） |
| Codex | `~/.codex/config.toml`（chezmoi 適用後にツールが追記する trust 設定はそのまま放置） |

## 変更時の注意

- 設定ファイルの追加・移動時は chezmoi 命名規約に従う（`dot_*`、`*.tmpl`）
- 仕事識別子（`kubell`, `chatwork-st`, `kbs-` 等）や machineId 系の値は絶対に dotfiles に commit しない
- `Brewfile` はツール追加時に追記する
- このリポジトリ固有の指示は `CLAUDE.md` / `AGENTS.md` に書く（chezmoiignore 済み）

## セットアップ

```bash
brew install chezmoi
chezmoi init https://github.com/takeshiemoto/dotfiles.git
chezmoi apply
```

既存環境がある場合は `chezmoi apply --dry-run --verbose` で差分を確認してから実行する。
