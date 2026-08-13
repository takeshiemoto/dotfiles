<img width="2816" height="1536" alt="dotfiles hero" src="https://github.com/user-attachments/assets/4e7240e1-ea61-470c-a34e-5f0bf4491b55" />

# dotfiles

A blank Mac becomes a fully configured daily driver with one command. macOS dotfiles managed with [chezmoi](https://www.chezmoi.io/) — shell, terminal, editor, keyboard, and the AI agents that work alongside them.

[![macOS](https://img.shields.io/badge/macOS-Apple%20Silicon-000000?logo=apple&logoColor=white&style=flat-square)](https://www.apple.com/macos/)
[![chezmoi](https://img.shields.io/badge/managed%20with-chezmoi-1D89C8?style=flat-square)](https://www.chezmoi.io/)
[![zsh](https://img.shields.io/badge/shell-zsh-F15A24?style=flat-square)](https://www.zsh.org/)
[![Neovim](https://img.shields.io/badge/editor-LazyVim-57A143?logo=neovim&logoColor=white&style=flat-square)](https://www.lazyvim.org/)
[![WezTerm](https://img.shields.io/badge/terminal-WezTerm-4E49EE?style=flat-square)](https://wezterm.org/)

## Quick start

On a blank Mac:

```sh
curl -fsSL https://raw.githubusercontent.com/takeshiemoto/dotfiles/main/bootstrap.sh -o /tmp/bootstrap.sh && bash /tmp/bootstrap.sh
```

One command caches sudo, installs chezmoi and Homebrew, writes every config into place, installs every tool in the Brewfile plus mise-managed runtimes, installs Claude Code, wires the herdr agent hooks, and signs into GitHub CLI. Already have chezmoi?

```sh
chezmoi init --apply takeshiemoto
```

On a machine with an existing setup, preview first with `chezmoi diff`.

## First boot checklist

What bootstrap cannot do for you, in order:

1. Karabiner-Elements: allow the driver extension and input monitoring in System Settings
2. Sign in: `claude` then `/login` (Claude Code then prompts to install the plugins and marketplaces listed in settings), `codex`, Slack, Rancher Desktop
3. Restore external skills into `~/.agents/skills` — the tracked symlinks under `~/.claude/skills` point there:

   ```sh
   npx -y skills add mattpocock/skills -g --skill grill-me --skill grill-with-docs -y
   npx -y skills add iKora128/stop-ai-slop-jp -g -y
   ```

4. Git identity for this machine: put overrides in `~/.gitconfig.local`, or edit `[data]` in `~/.config/chezmoi/chezmoi.toml` and re-apply
5. Langfuse (optional): agent tracing points at a self-hosted instance on `http://localhost:3000`; start it and set that project's public key in `pluginConfigs` in `~/.claude/settings.json` (a fresh instance generates new keys), or disable the `langfuse-observability` plugin
6. ghq-managed source (optional): `ghq get takeshiemoto/dotfiles`, then set `sourceDir` at the top level of `~/.config/chezmoi/chezmoi.toml` — above the `[data]` section, or it silently becomes a data value — and confirm with `chezmoi source-path`:

   ```toml
   sourceDir = "/Users/<you>/ghq/github.com/takeshiemoto/dotfiles"
   ```

## Design

- Universal config only. Machine-specific and work-specific values live in gitignored local overrides, never in this repo.
- Tools own their runtime state. Managed keys are enforced; whatever a tool writes at runtime passes through untouched, so `chezmoi apply` never fights an app.
- Reproducible by construction. `brew bundle` re-runs whenever the Brewfile changes, `mise install` re-runs whenever its config changes, taps are pre-trusted, and fonts install from the Brewfile.

## What's inside

| Source | Target | What |
|---|---|---|
| `dot_zshrc`, `dot_zshenv` | `~/.zshrc`, `~/.zshenv` | zsh with abbr, autosuggestions, peco history and ghq repo jumping |
| `dot_config/wezterm/` | `~/.config/wezterm/` | WezTerm: vague palette, leader-key panes, JetBrains Mono with UDEV Gothic NF fallback |
| `dot_config/nvim/` | `~/.config/nvim/` | Neovim (LazyVim): vague colorscheme, TypeScript, Go, Rust, PHP extras, JetBrains-style autosave |
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

External skills installed with [skills.sh](https://skills.sh) live in `~/.agents/skills`; only the symlinks under `~/.claude/skills` are tracked here, so restore the targets on a new machine (see the checklist).

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
| `~/.config/chezmoi/chezmoi.toml` | git identity data, `sourceDir` when the source repo lives under ghq |

## Bootstrap

- `bootstrap.sh` is the blank-Mac entry point: sudo keepalive, chezmoi init, Claude Code install, herdr integrations, GitHub CLI login
- `run_once_before_install-brew.sh` installs Homebrew if absent
- `run_onchange_after_brew-bundle.sh.tmpl` runs `brew bundle --no-upgrade` whenever the Brewfile changes
- `run_onchange_after_mise-install.sh.tmpl` runs `mise install` whenever the mise config changes
- `run_onchange_after_macos-defaults.sh` bakes macOS keyboard settings via `defaults write` — fastest key repeat, no press-and-hold accent popup, Caps Lock as Control on the built-in keyboard and HHKB; re-login to take effect

## Fonts

JetBrains Mono is the primary font and UDEV Gothic NF the fallback; both install from the Brewfile, so a fresh machine needs no manual font steps.
