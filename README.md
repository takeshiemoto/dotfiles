# dotfiles

## Setup

### Manual

1. Install Homebrew
2. Clone this repo to `~/ghq/github.com/takeshiemoto/dotfiles`
3. Run `brew bundle` to install dependencies
4. Run `bash install.sh` to create symlinks
5. Run `gh auth login` to authenticate with GitHub
6. Install WezTerm from the official site

### What `install.sh` does

| Source | Target |
|--------|--------|
| `zsh/.zshrc`, `zsh/.zshenv` | `~/` |
| `git/.gitconfig` | `~/` |
| `wezterm/` | `~/.config/wezterm/` |
| `nvim/` | `~/.config/nvim/` |
| `lazygit/config.yml` | `~/.config/lazygit/` |
| `claude/` | `~/.claude/` |
| `codex/AGENTS.md` | `~/.codex/` |
| `agents/` | `~/.agents` |
| `zsh-abbr/user-abbreviations` | `~/.config/zsh-abbr/` |

### What `Brewfile` manages

ghq, peco, lazygit, neovim, zsh-abbr, zsh-autosuggestions, gh, mise
