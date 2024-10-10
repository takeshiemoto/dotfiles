#!/bin/bash

# スクリプト自身のディレクトリを取得
script_dir=$(cd $(dirname $0); pwd)

# dotfiles ディレクトリ
dotfiles_dir="$script_dir"

# シンボリックリンクを貼るファイルのリスト
files=(".ideavimrc" ".tmux.conf" ".zshrc")

# シンボリックリンクを作成
for file in "${files[@]}"; do
  ln -sf "$dotfiles_dir/$file" "$HOME/$file"
  echo "Created a symbolic link: $HOME/$file -> $dotfiles_dir/$file"
done
