#!/bin/bash

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# シンボリックリンクを貼るファイルのリスト
files=(".ideavimrc" ".tmux.conf" ".zshrc")

# シンボリックリンクを作成
for file in "${files[@]}"; do
    ln -sf "$DOTFILES_DIR/$file" "$HOME/$file"
    echo "Created a symbolic link: $HOME/$file -> $DOTFILES_DIR/$file"
done

# ignoreを$HOME/.config/git/ディレクトリにシンボリックリンクで配置
mkdir -p "$HOME/.config/git"
ln -sf "$DOTFILES_DIR/ignore" "$HOME/.config/git/ignore"
