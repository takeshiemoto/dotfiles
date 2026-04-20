# dotfiles

## リポジトリ概要

macOS 環境の設定ファイルを一元管理するリポジトリ。
`bash install.sh` でシンボリックリンクを作成してデプロイする。

## ディレクトリ構造

各ディレクトリが1つのパッケージに対応し、`install.sh` でホームディレクトリ配下にリンクされる。

| ディレクトリ | デプロイ先 | 内容 |
|---|---|---|
| `zsh/` | `~/` | `.zshrc`, `.zshenv` |
| `git/` | `~/`, `~/.config/git/` | `.gitconfig`, グローバル ignore |
| `wezterm/` | `~/.config/wezterm/` | WezTerm 設定 |
| `nvim/` | `~/.config/nvim/` | Neovim (LazyVim) |
| `lazygit/` | `~/.config/lazygit/` | Lazygit 設定 |
| `claude/` | `~/.claude/` | Claude Code ユーザースコープ設定 |
| `claude/skills/` | `~/.claude/skills/` | Claude Code ユーザースコープ skill |
| `codex/` | `~/.codex/` | Codex ユーザースコープ設定 |
| `agents/` | `~/.agents` | エージェント用 skills |
| `zsh-abbr/` | `~/.config/zsh-abbr/` | zsh-abbr 略語定義 |

## 変更時の注意

- 設定ファイルの追加・移動時は `install.sh` のリンク定義も更新すること。
- `claude/` と `codex/` はユーザースコープ（全プロジェクト共通）の設定。このリポジトリ固有の設定はルートの `CLAUDE.md` / `AGENTS.md` に書く。
- `Brewfile` は `brew bundle` で管理される依存一覧。ツール追加時はここにも追記する。
