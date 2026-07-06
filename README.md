<img width="2816" height="1536" alt="dotfiles hero" src="https://github.com/user-attachments/assets/4e7240e1-ea61-470c-a34e-5f0bf4491b55" />

# dotfiles

A blank Mac becomes a fully configured daily driver with one command. macOS dotfiles managed with [chezmoi](https://www.chezmoi.io/) — shell, terminal, editor, keyboard, and the AI agents that work alongside them.

[![macOS](https://img.shields.io/badge/macOS-Apple%20Silicon-000000?logo=apple&logoColor=white&style=flat-square)](https://www.apple.com/macos/)
[![chezmoi](https://img.shields.io/badge/managed%20with-chezmoi-1D89C8?style=flat-square)](https://www.chezmoi.io/)
[![zsh](https://img.shields.io/badge/shell-zsh-F15A24?style=flat-square)](https://www.zsh.org/)
[![Neovim](https://img.shields.io/badge/editor-LazyVim-57A143?logo=neovim&logoColor=white&style=flat-square)](https://www.lazyvim.org/)
[![WezTerm](https://img.shields.io/badge/terminal-WezTerm-4E49EE?style=flat-square)](https://wezterm.org/)

## Quick start

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply takeshiemoto
```

One command installs chezmoi, clones this repo, bootstraps Homebrew, installs every tool in the Brewfile, and writes every config into place. Already have chezmoi?

```sh
chezmoi init --apply takeshiemoto
```

On a machine with an existing setup, preview first with `chezmoi diff`.

## Design

- Universal config only. Machine-specific and work-specific values live in gitignored local overrides, never in this repo.
- Tools own their runtime state. Managed keys are enforced; whatever a tool writes at runtime passes through untouched, so `chezmoi apply` never fights an app.
- Reproducible by construction. `brew bundle` re-runs whenever the Brewfile changes, taps are pre-trusted, and fonts have Brewfile-managed fallbacks.

## What's inside

| Source | Target | What |
|---|---|---|
| `dot_zshrc`, `dot_zshenv` | `~/.zshrc`, `~/.zshenv` | zsh with abbr, autosuggestions, peco history and ghq repo jumping |
| `dot_config/wezterm/` | `~/.config/wezterm/` | WezTerm: Tokyo Night, leader-key panes, MonoLisa with UDEV Gothic NF fallback |
| `dot_config/nvim/` | `~/.config/nvim/` | Neovim (LazyVim): TypeScript, Go, Rust, PHP extras, JetBrains-style autosave |
| `dot_config/lazygit/` | `~/.config/lazygit/` | lazygit |
| `dot_config/private_karabiner/` | `~/.config/karabiner/` | Karabiner-Elements: Esc also sends Eisu for vim, lone Cmd keys switch IME |
| `dot_config/zsh-abbr/` | `~/.config/zsh-abbr/` | shell abbreviations |
| `dot_config/mise/` | `~/.config/mise/` | mise runtime manager |
| `dot_config/herdr/` | `~/.config/herdr/` | herdr agent multiplexer |
| `dot_config/private_homebrew/` | `~/.config/homebrew/` | tap trust list so `brew bundle` runs unattended |
| `dot_config/git/ignore`, `dot_gitconfig.tmpl` | `~/.config/git/`, `~/.gitconfig` | git defaults, global ignore, `~/.gitconfig.local` include |
| `dot_claude/` | `~/.claude/` | Claude Code: settings, rules, user-scope skills |
| `dot_codex/` | `~/.codex/` | Codex: AGENTS.md and config via a modify script |
| `dot_config/ccstatusline/` | `~/.config/ccstatusline/` | Claude Code status line |

## AI agents as first-class dotfiles

Claude Code and Codex are configured here like any other tool. User-scope settings, rules, and hand-written skills (commit and PR workflows, chezmoi ops, plan grilling) are tracked; sessions, caches, and auth state are not. Track new files as you create them:

```sh
chezmoi add ~/.claude/settings.json
chezmoi add ~/.claude/skills/<name>
```

## Tool-rewritten configs

Codex rewrites `~/.codex/config.toml` at runtime, and what it writes grows with every release. A chezmoi `modify_` script enforces only the managed keys (model, reasoning effort, MCP servers) and passes everything else through verbatim — the diff stays empty no matter what the app does.

## Daily workflow

```sh
chezmoi diff          # what would change
chezmoi add <file>    # pull a live edit back into the repo
chezmoi apply         # push the repo state out
chezmoi cd            # jump into the source repo
```

## Local overrides

| File | For |
|---|---|
| `~/.gitconfig.local` | work email, machine-specific git config |

## Bootstrap

- `run_once_before_install-brew.sh` installs Homebrew if absent
- `run_onchange_after_brew-bundle.sh.tmpl` runs `brew bundle --no-upgrade` whenever the Brewfile changes

## Fonts

WezTerm uses MonoLisa Trial, which is a manual install (EULA); UDEV Gothic NF from the Brewfile is the fallback, so a fresh machine works without it.
