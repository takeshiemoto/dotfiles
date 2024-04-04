#!/bin/zsh

# 設定ファイルを移動
cp .tmux.conf ~/
cp .ideavimrc ~/
cp .zshrc ~/

# 設定を反映
tmux source-file ~/.tmux.conf
source ~/.zshrc