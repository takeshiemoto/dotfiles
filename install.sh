#!/bin/bash

# Homebrewをインストール
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# link.shを実行
chmod +x link.sh
./link.sh

# Homebrew をアップデート
brew update

# アプリケーションをインストール
brew install --cask raycast ghq peco iterm2 jetbrains-toolbox google-chrome 1password brave-browser docker
brew install tmux neovim

echo "Installation is complete!"
