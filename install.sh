#!/bin/bash
set -eu

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

link() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [ -L "$dst" ]; then
    rm "$dst"
  elif [ -e "$dst" ]; then
    echo "  WARNING: $dst exists and is not a symlink, skipping"
    return
  fi
  ln -sf "$src" "$dst"
  echo "  $dst -> $src"
}

echo "=== Cleanup ==="
[ -L "$HOME/.zprofile" ] && [ ! -e "$HOME/.zprofile" ] && rm "$HOME/.zprofile" && echo "  Removed broken symlink: ~/.zprofile"

echo "=== Zsh ==="
link "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
link "$DOTFILES_DIR/zsh/.zshenv" "$HOME/.zshenv"

echo "=== WezTerm ==="
link "$DOTFILES_DIR/wezterm/wezterm.lua" "$HOME/.config/wezterm/wezterm.lua"

echo "=== Neovim (LazyVim) ==="
link "$DOTFILES_DIR/nvim/init.lua" "$HOME/.config/nvim/init.lua"
link "$DOTFILES_DIR/nvim/stylua.toml" "$HOME/.config/nvim/stylua.toml"
link "$DOTFILES_DIR/nvim/lazyvim.json" "$HOME/.config/nvim/lazyvim.json"
link "$DOTFILES_DIR/nvim/.neoconf.json" "$HOME/.config/nvim/.neoconf.json"
link "$DOTFILES_DIR/nvim/lua" "$HOME/.config/nvim/lua"

echo "=== Lazygit ==="
link "$DOTFILES_DIR/lazygit/config.yml" "$HOME/.config/lazygit/config.yml"

echo "=== Claude Code ==="
link "$DOTFILES_DIR/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
link "$DOTFILES_DIR/claude/settings.json" "$HOME/.claude/settings.json"
link "$DOTFILES_DIR/claude/keybindings.json" "$HOME/.claude/keybindings.json"

echo "=== Agents ==="
link "$DOTFILES_DIR/agents" "$HOME/.agents"

echo "=== Codex ==="
mkdir -p "$HOME/.codex"
link "$DOTFILES_DIR/codex/AGENTS.md" "$HOME/.codex/AGENTS.md"

echo "=== Git ==="
link "$DOTFILES_DIR/git/.gitconfig" "$HOME/.gitconfig"
link "$DOTFILES_DIR/git/ignore" "$HOME/.config/git/ignore"

echo "=== zsh-abbr ==="
link "$DOTFILES_DIR/zsh-abbr/user-abbreviations" "$HOME/.config/zsh-abbr/user-abbreviations"

echo ""
echo "Done."
