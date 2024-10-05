#!/bin/bash

# スクリプト自身のディレクトリを取得
script_dir=$(cd $(dirname $0); pwd)

# dotfiles ディレクトリ
dotfiles_dir="$script_dir"

# シンボリックリンクを貼るファイルを取得
find "$dotfiles_dir" -type f -name ".*" -print0 | while IFS= read -r -d $'\0' file; do
  # dotfiles ディレクトリからの相対パスを取得
  relative_path="${file#$dotfiles_dir/}"
  # シンボリックリンクを作成
  ln -sf "$file" "$HOME/$relative_path"
  echo "Created a symbolic link: $HOME/$relative_path -> $file"
done
