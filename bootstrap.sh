#!/usr/bin/env bash
set -eu

echo "[bootstrap] Caching sudo credentials..."
sudo -v
(while true; do
  sudo -n true
  sleep 60
done) 2>/dev/null &
SUDO_KEEPALIVE_PID=$!
trap 'kill "$SUDO_KEEPALIVE_PID" 2>/dev/null' EXIT

cd "$HOME"

echo "[bootstrap] Installing chezmoi and applying dotfiles..."
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply --promptDefaults takeshiemoto

if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

if ! gh auth status >/dev/null 2>&1; then
  echo "[bootstrap] Logging in to GitHub CLI..."
  gh auth login
fi

echo "[bootstrap] Launching Karabiner-Elements for permission prompts..."
open -a "Karabiner-Elements"

echo "[bootstrap] Done. Remaining manual steps:"
echo "  1. Karabiner-Elements のドライバ拡張と入力監視をシステム設定で許可する"
echo "  2. Slack など各アプリにサインインする"
echo "  3. Git の email をこのマシン用に変える場合: chezmoi init --data=false を再実行するか ~/.config/chezmoi/chezmoi.toml を編集して chezmoi apply"
