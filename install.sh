#!/bin/bash
set -eu

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

link() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  [ -e "$dst" ] || [ -L "$dst" ] && rm -rf "$dst"
  ln -sf "$src" "$dst"
  echo "  $dst -> $src"
}

echo "=== Zsh ==="
link "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"

echo "=== WezTerm ==="
link "$DOTFILES_DIR/wezterm/wezterm.lua" "$HOME/.config/wezterm/wezterm.lua"
link "$DOTFILES_DIR/wezterm/lua" "$HOME/.config/wezterm/lua"

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

echo "=== Codex ==="
mkdir -p "$HOME/.codex"
link "$DOTFILES_DIR/codex/AGENTS.md" "$HOME/.codex/AGENTS.md"

echo ""
echo "Done."
