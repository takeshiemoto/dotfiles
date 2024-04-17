# @see https://qiita.com/ssh0/items/a9956a74bff8254a606a
# Autostart if not already in tmux.
if [[ ! -n $TMUX ]]; then
  tmux new-session
fi

# 履歴共有
setopt inc_append_history
setopt share_history

# ヒープ音削除
setopt no_beep

# 単語移動
bindkey '[C' forward-word
bindkey '[D' backward-word

# Git
source ~/.zsh/git-prompt.sh

# zsh autosuggestions
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# VimはNeoVimを開く
alias vi="nvim"
alias vim="nvim"

# AppleGitからHomebrewGitへ変更
export PATH="/opt/homebrew/bin:$PATH"
# lazygitの設定ファイル場所変更
export XDG_CONFIG_HOME="$HOME/.config"

# ----------------------------
# peco
# ----------------------------
function peco-history-selection() {
    BUFFER=`history -n 1 | tail -r  | awk '!a[$0]++' | peco`
    CURSOR=$#BUFFER
    zle reset-prompt
}
zle -N peco-history-selection

function peco-src () {
  local selected_dir=$(ghq list -p | peco --query "$LBUFFER")
  if [ -n "$selected_dir" ]; then
    BUFFER="cd ${selected_dir}"
    zle accept-line
  fi
  zle clear-screen
}
zle -N peco-src

bindkey '^R' peco-history-selection
bindkey '^]' peco-src

# ----------------------------
# java
# ----------------------------
export JAVA_HOME=/path/to/installed/jdk
export PATH=${JAVA_HOME}/bin:${PATH}

# ----------------------------
# sbt
# ----------------------------
export SBT_OPTS=-Xmx4096m

# ----------------------------
# Git
# ----------------------------
alias gbclean="git branch --merged | egrep -v '^\*|develop' | xargs git branch -d"

eval "$(starship init zsh)"
eval "$(mise activate zsh)"
