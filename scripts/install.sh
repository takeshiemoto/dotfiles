#!/bin/bash

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

echo "Starting dotfiles installation..."
echo "Dotfiles directory: $DOTFILES_DIR"

# Function to create symlink
create_symlink() {
    local source="$1"
    local target="$2"

    # Remove existing file/symlink if exists
    if [ -e "$target" ] || [ -L "$target" ]; then
        rm -f "$target"
    fi

    # Create symlink
    ln -sf "$source" "$target"
    echo "Created symlink: $target -> $source"
}

# Create necessary directories
echo ""
echo "Creating necessary directories..."
mkdir -p ~/.config
mkdir -p ~/.config/git
mkdir -p ~/.config/nvim

# Install dotfiles
echo ""
echo "Installing dotfiles..."

# Zsh configuration
create_symlink "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"

# Git configuration
create_symlink "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"
create_symlink "$DOTFILES_DIR/.gitignore" "$HOME/.config/git/ignore"

# IdeaVim configuration (for JetBrains IDEs)
create_symlink "$DOTFILES_DIR/.ideavimrc" "$HOME/.ideavimrc"

# Tmux configuration
create_symlink "$DOTFILES_DIR/.tmux.conf" "$HOME/.tmux.conf"

# Neovim configuration
create_symlink "$DOTFILES_DIR/init.vim" "$HOME/.config/nvim/init.vim"

# VSCode settings (if default.json is for VSCode)
if [ -f "$DOTFILES_DIR/default.json" ]; then
    # macOS VSCode settings location
    VSCODE_DIR="$HOME/Library/Application Support/Code/User"
    if [ -d "$VSCODE_DIR" ]; then
        create_symlink "$DOTFILES_DIR/default.json" "$VSCODE_DIR/settings.json"
    fi
fi

# Install Homebrew if not installed
if ! command -v brew &> /dev/null; then
    echo ""
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH for Apple Silicon Macs
    if [ -f "/opt/homebrew/bin/brew" ]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
else
    echo ""
    echo "Homebrew already installed"
fi

# Install packages from Brewfile
if [ -f "$DOTFILES_DIR/Brewfile" ]; then
    echo ""
    echo "Installing packages from Brewfile..."
    brew bundle --file="$DOTFILES_DIR/Brewfile"
else
    echo "Brewfile not found, skipping package installation"
fi

# Set Zsh as default shell if not already
if [ "$SHELL" != "$(which zsh)" ]; then
    echo ""
    echo "Setting Zsh as default shell..."
    if ! grep -q "$(which zsh)" /etc/shells; then
        echo "$(which zsh)" | sudo tee -a /etc/shells
    fi
    chsh -s "$(which zsh)"
fi

# Install Tmux Plugin Manager
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    echo ""
    echo "Installing Tmux Plugin Manager..."
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

# iTerm2 configuration
echo ""
echo "Setting up iTerm2 preferences sync..."

if [ -d "$DOTFILES_DIR/iterm2" ]; then
    if [ -d "/Applications/iTerm.app" ]; then
        defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$DOTFILES_DIR/iterm2"
        defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true

        echo "iTerm2 configured to sync preferences with: $DOTFILES_DIR/iterm2/"
        echo "NOTE: You may need to restart iTerm2 for changes to take effect"
    else
        echo "iTerm2 not installed. Skipping iTerm2 configuration"
    fi
else
    echo "iTerm2 preferences directory not found. Skipping iTerm2 configuration"
fi

echo "Please restart your terminal or run: source ~/.zshrc"
