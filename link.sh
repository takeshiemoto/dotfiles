#!/bin/bash

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# シンボリックリンクを貼るファイルのリスト
files=(".ideavimrc" ".tmux.conf" ".zshrc")

# シンボリックリンクを作成
for file in "${files[@]}"; do
    ln -sf "$DOTFILES_DIR/$file" "$HOME/$file"
    echo "Created a symbolic link: $HOME/$file -> $DOTFILES_DIR/$file"
done

DOTFILES_CONFIG_DIR="$DOTFILES_DIR/.config"
TARGET_CONFIG_DIR="$HOME/.config"

# .config ディレクトリが存在しない場合は作成
if [ ! -d "$TARGET_CONFIG_DIR" ]; then
    mkdir -p "$TARGET_CONFIG_DIR"
fi

# シンボリックリンクを作成する関数
link_file() {
    src="$1"
    dest="$2"

    if [ -e "$dest" ]; then
        echo "$dest が存在するため、削除してシンボリックリンクを作成します。"
        rm -rf "$dest"
    fi
    ln -s "$src" "$dest"
    echo "シンボリックリンクを作成しました: $dest -> $src"
}

# dotfiles/.config 内のファイル・ディレクトリをすべてシンボリックリンク
for item in "$DOTFILES_CONFIG_DIR"/*; do
    basename=$(basename "$item")
    link_file "$item" "$TARGET_CONFIG_DIR/$basename"
done
