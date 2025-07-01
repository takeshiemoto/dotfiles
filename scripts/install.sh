#!/bin/bash
set -e  # エラーで終了
set -u  # 未定義変数でエラー

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

echo "Starting dotfiles installation..."
echo "Dotfiles directory: $DOTFILES_DIR"

# create_symlink関数を改善
create_symlink() {
    local source="$1"
    local target="$2"

    # ターゲットのディレクトリが存在することを確認
    local target_dir=$(dirname "$target")
    mkdir -p "$target_dir"

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

# Claude configuration
create_symlink "$DOTFILES_DIR/claude" "$HOME/.claude"

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

# Source zshrc
echo ""
echo "Installation complete!"
echo "Please restart your terminal or run: source ~/.zshrc"

# Display what was installed
echo ""
echo "Installed configurations:"
echo "✓ Zsh configuration"
echo "✓ Git configuration (~/.config/git/ignore)"
echo "✓ IdeaVim configuration"
echo "✓ Tmux configuration"
echo "✓ Neovim configuration"
echo "✓ Claude configuration"
[ -f "$DOTFILES_DIR/Brewfile" ] && echo "✓ Homebrew packages"
[ -d "$DOTFILES_DIR/iterm2" ] && echo "✓ iTerm2 preferences sync"
