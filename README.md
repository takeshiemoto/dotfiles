# dotfiles

macOS dotfiles managed with [chezmoi](https://www.chezmoi.io/).
Universal config only — machine- and project-specific values stay in gitignored local overrides.

## Install

```bash
brew install chezmoi
chezmoi init https://github.com/takeshiemoto/dotfiles.git
chezmoi apply
```

## Layout

| Source | Destination |
|---|---|
| `dot_zshrc`, `dot_zshenv` | `~/.zshrc`, `~/.zshenv` |
| `dot_gitconfig.tmpl` | `~/.gitconfig` (includes `~/.gitconfig.local`) |
| `dot_config/` | `~/.config/` — wezterm, nvim, lazygit, zsh-abbr, git |
| `dot_claude/` | `~/.claude/` |
| `dot_codex/` | `~/.codex/` |

## Local overrides

| File | For |
|---|---|
| `~/.gitconfig.local` | work email, machine-specific git config |
| `~/.claude/settings.local.json` | work plugins, machine-specific Claude Code settings |
| `~/.codex/config.toml` | tool-managed (trust prompts); deliberately not tracked |

## Bootstrap

- `run_once_before_install-brew.sh` — installs Homebrew if absent
- `run_once_after_brew-bundle.sh.tmpl` — runs `brew bundle`
