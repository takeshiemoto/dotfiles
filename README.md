# dotfiles

<img width="2816" height="1536" alt="Gemini_Generated_Image_t3zn2pt3zn2pt3zn" src="https://github.com/user-attachments/assets/4e7240e1-ea61-470c-a34e-5f0bf4491b55" />

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
| `dot_codex/` | `~/.codex/` |
| `dot_claude/` | `~/.claude/` — settings.json, user-scope skills |

## Local overrides

| File | For |
|---|---|
| `~/.gitconfig.local` | work email, machine-specific git config |
| `~/.codex/config.toml` | tool-managed (trust prompts); deliberately not tracked |

## Claude Code

User-scope Claude config (`~/.claude/`) is managed here. Track new files as you create them:

```bash
chezmoi add ~/.claude/settings.json          # settings
chezmoi add ~/.claude/skills/<name>          # a user-scope skill
```

Only config is tracked — sessions, cache, history, and auth state stay untracked.

## Bootstrap

- `run_once_before_install-brew.sh` — installs Homebrew if absent
- `run_once_after_brew-bundle.sh.tmpl` — runs `brew bundle`
