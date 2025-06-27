#!/bin/bash

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

info() {
    echo "$(tput setaf 2)✓$(tput sgr0) $1"
}

error() {
    echo "$(tput setaf 1)✗$(tput sgr0) $1" >&2
}

create_symlink() {
    local source="$1"
    local target="$2"
    
    if [ -L "$target" ]; then
        local current_link=$(readlink "$target")
        if [ "$current_link" = "$source" ]; then
            info "$target already linked correctly"
            return
        else
            info "Updating symlink: $target"
            rm "$target"
        fi
    elif [ -e "$target" ]; then
        error "$target already exists and is not a symlink. Please back up and remove it manually."
        return 1
    fi
    
    ln -s "$source" "$target"
    info "Created symlink: $target -> $source"
}

if ! command -v brew &> /dev/null; then
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    info "Homebrew already installed"
fi

info "Installing packages from Brewfile..."
brew bundle --file="$DOTFILES_DIR/Brewfile"

info "Creating symlinks..."
create_symlink "$DOTFILES_DIR/init.vim" "$HOME/.config/nvim/init.vim"
create_symlink "$DOTFILES_DIR/ignore" "$HOME/.ignore"
create_symlink "$DOTFILES_DIR/claude" "$HOME/.claude"

info "Installation completed!"