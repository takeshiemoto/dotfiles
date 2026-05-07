export EDITOR=nvim

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

PROMPT='%1~ %% '

# 単語で移動
bindkey '[C' forward-word
bindkey '[D' backward-word

setopt no_beep
setopt no_flow_control
setopt ignore_eof

# zsh-abbr（Homebrew初期化後に読み込み）

# peco
function peco-history-selection() {
    BUFFER=$(fc -lnr 1 | awk '!a[$0]++' | peco)
    CURSOR=$#BUFFER
    zle reset-prompt
}
zle -N peco-history-selection

function peco-src() {
  local cache_file="/tmp/ghq_cache"

  if [[ ! -f $cache_file ]] || [[ $(find "$cache_file" -mmin +5 2>/dev/null) ]]; then
    ghq list -p > "$cache_file"
  fi

  local selected_dir=$(peco --query "$LBUFFER" < "$cache_file")
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

# Homebrewの警告を無効にする
export HOMEBREW_NO_ENV_HINTS=1

# Homebrewを有効にする
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"

  # zsh-abbr
  source "$(brew --prefix)/share/zsh-abbr@6/zsh-abbr.zsh"

  # zsh-autosuggestionsを有効にする
  source "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

# miseを有効にする
if command -v mise &>/dev/null; then
  eval "$(mise activate zsh)"
fi

# WezTerm shell integration: OSC 7 (current directory tracking)
__wezterm_osc7() {
  printf '\e]7;file://%s%s\e\\' "${HOST}" "${PWD}"
}
chpwd_functions=(${chpwd_functions[@]} "__wezterm_osc7")
__wezterm_osc7

export PATH="$HOME/.local/bin:$PATH"

# bun completions
[ -s "/Users/takeshiemoto/.bun/_bun" ] && source "/Users/takeshiemoto/.bun/_bun"

### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
export PATH="/Users/takeshiemoto/.rd/bin:$PATH"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)
