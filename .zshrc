export EDITOR=vim
export TERM=xterm-256color

# ヒストリー設定
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt hist_ignore_dups
setopt share_history

# 補完
autoload -U compinit && compinit -C
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' menu select

# プロンプト
PROMPT='%F{cyan}%1~%f %# '
RPROMPT='%F{241}%*%f'

# 単語で移動
bindkey '[C' forward-word
bindkey '[D' backward-word

setopt no_beep
setopt no_flow_control
setopt ignore_eof

alias vi="nvim"
alias vim="nvim"
alias zz='lazygit'

# GitをAppleからHomebrewに変更する
export PATH="/opt/homebrew/bin:$PATH"

# peco
function peco-history-selection() {
    BUFFER=$(fc -lnr 1 | awk '!a[$0]++' | peco)
    CURSOR=$#BUFFER
    zle reset-prompt
}
zle -N peco-history-selection

function peco-src() {
  local cache_file="/tmp/ghq_cache_$$"
  local cache_time=300  # 5分間キャッシュ
  
  if [[ ! -f $cache_file ]] || [[ $(find $cache_file -mmin +5 2>/dev/null) ]]; then
    ghq list -p > $cache_file
  fi
  
  local selected_dir=$(cat $cache_file | peco --query "$LBUFFER")
  if [ -n "$selected_dir" ]; then
    BUFFER="cd ${selected_dir}"
    zle accept-line
  fi
  zle clear-screen
}
zle -N peco-src

bindkey '^R' peco-history-selection
bindkey '^]' peco-src

# GithubのPRチェックアウト
function ghp() {
  gh pr checkout "$1"
}

# lazygitの設定ファイルの場所を変更する
export XDG_CONFIG_HOME="$HOME/.config"

# zsh-autosuggestionsを有効にする
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# miseを有効にする
# miseが必要な時だけ読み込み
[[ -x ~/.local/bin/mise ]] && eval "$(~/.local/bin/mise activate zsh)"

# Homebrewを有効にする
# brewのパスを最初に一度だけ設定
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
  export PATH="/opt/homebrew/bin:$PATH"
fi

# 起動時にtmuxを起動する
if command -v tmux > /dev/null && [ -z "$TMUX" ] && [ "$TERMINAL_EMULATOR" != "JetBrains-JediTerm" ]; then
  tmux
fi
