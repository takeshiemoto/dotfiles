# dotfiles

macOS dotfiles managed with [chezmoi](https://www.chezmoi.io/).

**全案件で共通利用できる設定のみ** を管理する。仕事識別子・マシン固有 ID・特定プロダクト依存プラグインは `~/.gitconfig.local` / `~/.claude/settings.local.json` 等の局所オーバーライドに逃がす。

## 初回セットアップ

```bash
brew install chezmoi
chezmoi init https://github.com/takeshiemoto/dotfiles.git
chezmoi apply
```

初回 apply 時の流れ:
1. `name`, `email` をプロンプトされる（`~/.config/chezmoi/chezmoi.toml` に保存）
2. `run_once_before_install-brew.sh` が Homebrew を導入（既にあればスキップ）
3. `dot_*` ファイル一式を `~/` 配下に展開
4. `run_once_after_brew-bundle.sh.tmpl` が `brew bundle` を実行

### ghq 配下で管理したい場合

```bash
git clone https://github.com/takeshiemoto/dotfiles.git ~/ghq/github.com/takeshiemoto/dotfiles
mkdir -p ~/.config/chezmoi
cat > ~/.config/chezmoi/chezmoi.toml <<EOF
sourceDir = "$HOME/ghq/github.com/takeshiemoto/dotfiles"

[data]
name = "takeshiemoto"
email = "private.takeshiemoto@gmail.com"
EOF
chezmoi apply
```

## 日常運用

### 設定を変更する

```bash
# 推奨: source を直接編集
$EDITOR $(chezmoi source-path ~/.zshrc)
chezmoi apply

# あるいは ~/ 側を編集してから取り込む
$EDITOR ~/.zshrc
chezmoi re-add
```

### 差分・状態確認

```bash
chezmoi diff      # source vs destination の差分
chezmoi status    # 変更があるファイル一覧
chezmoi managed   # chezmoi 管理下のファイル一覧
```

### 反映と配布

```bash
chezmoi apply                       # 自分のマシンに反映
cd $(chezmoi source-path) && git push  # 他マシンに配布
```

他マシンで取り込み:
```bash
chezmoi update    # git pull + apply を一括
```

## マシン固有/案件固有の設定

dotfiles には**入れない**。以下に逃がす:

| ツール | 置き場 | 備考 |
|---|---|---|
| git | `~/.gitconfig.local` | `~/.gitconfig` 末尾で `[include]` 済み。仕事メアド等はこちら |
| Claude Code | `~/.claude/settings.local.json` | gitignore 済み。仕事用プラグイン・組織固有 permissions 等 |
| Codex | `~/.codex/config.toml` を直接 | 公式 local override なし。trust 設定はツールが追記する分は dotfiles 側で関与しない |
| zsh | `~/.zshrc.local` 等 | 必要なら `dot_zshrc` 末尾に source 追加 |

## ディレクトリ構造

| Source | Destination | 用途 |
|---|---|---|
| `dot_zshrc` / `dot_zshenv` | `~/.zshrc` / `~/.zshenv` | zsh |
| `dot_gitconfig.tmpl` | `~/.gitconfig` | git（テンプレ展開） |
| `dot_config/wezterm/` | `~/.config/wezterm/` | WezTerm |
| `dot_config/nvim/` | `~/.config/nvim/` | Neovim (LazyVim) |
| `dot_config/lazygit/` | `~/.config/lazygit/` | Lazygit |
| `dot_config/git/ignore` | `~/.config/git/ignore` | グローバル gitignore |
| `dot_config/zsh-abbr/` | `~/.config/zsh-abbr/` | zsh-abbr 略語 |
| `dot_claude/` | `~/.claude/` | Claude Code ユーザースコープ |
| `dot_codex/` | `~/.codex/` | Codex ユーザースコープ |

## Bootstrap スクリプト

| Script | When |
|---|---|
| `run_once_before_install-brew.sh` | 初回 apply 前。Homebrew がなければ導入 |
| `run_once_after_brew-bundle.sh.tmpl` | 初回 apply 後。Brewfile に基づき `brew bundle` |

chezmoi が SHA256 で内容を追跡し、変更されたら再実行される（idempotent）。

## Brewfile

開発ツール / フォント / GUI アプリ一式。追加時は `Brewfile` に追記して以下を実行:

```bash
brew bundle --file=$(chezmoi source-path)/Brewfile
```

## 命名規約のメモ

chezmoi の規約:
- `dot_X` → `~/.X`（隠しファイル/ディレクトリ）
- `*.tmpl` → テンプレート展開（`{{ .var }}`, `{{ .chezmoi.homeDir }}` 等が使える）
- `run_once_before_*` / `run_once_after_*` → bootstrap script
- `private_*` → mode 0600 で展開（鍵類）
