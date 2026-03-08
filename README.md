# dotfiles

Personal configuration files managed with symlinks.

## Contents

| Directory | Description | Target |
|-----------|-------------|--------|
| `zsh/` | Zsh configuration | `~/.zshrc` |
| `wezterm/` | WezTerm terminal config | `~/.config/wezterm/` |
| `nvim/` | Neovim (LazyVim) config | `~/.config/nvim/` |
| `lazygit/` | Lazygit config | `~/.config/lazygit/config.yml` |
| `claude/` | Claude Code settings | `~/.claude/` |
| `codex/` | Codex agent instructions | `~/.codex/AGENTS.md` |

## Setup

```bash
git clone ssh://git@github.com/takeshiemoto/dotfiles.git ~/projects/github.com/takeshiemoto/dotfiles
cd ~/projects/github.com/takeshiemoto/dotfiles
./install.sh
```

## What `install.sh` does

Creates symbolic links from each config file to its expected location. Existing files at the target paths are replaced.
