# プロンプトを簡略化
PROMPT='%c %# '

# 単語で移動
bindkey '[C' forward-word
bindkey '[D' backward-word

# 履歴を共有する
setopt inc_append_history
setopt share_history

# ヒープ音を消す
setopt no_beep

# VimはNeoVimを開く
alias vi="nvim"
alias vim="nvim"

# GitをAppleからHomebrewに変更する
export PATH="/opt/homebrew/bin:$PATH"

# peco
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

# lazygitはzzで起動する
alias zz='lazygit'

# lazygitの設定ファイルの場所を変更する
export XDG_CONFIG_HOME="$HOME/.config"

# zsh-autosuggestionsを有効にする
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# miseを有効にする
eval "$(~/.local/bin/mise activate zsh)"

# Homebrewを有効にする
eval "$(/opt/homebrew/bin/brew shellenv)"

# 起動時にtmuxを起動する
if command -v tmux > /dev/null && [ -z "$TMUX" ]; then
  tmux
fi
