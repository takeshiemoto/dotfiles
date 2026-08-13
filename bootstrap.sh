#!/usr/bin/env bash
set -euo pipefail

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
chezmoi_installer="$(curl -fsLS get.chezmoi.io)"
sh -c "$chezmoi_installer" -- init --apply --promptDefaults takeshiemoto

if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

if ! command -v claude >/dev/null 2>&1; then
  echo "[bootstrap] Installing Claude Code..."
  claude_installer="$(curl -fsSL https://claude.ai/install.sh)"
  bash -c "$claude_installer"
fi

echo "[bootstrap] Installing herdr agent integrations..."
herdr integration install claude
herdr integration install codex

if ! gh auth status >/dev/null 2>&1; then
  echo "[bootstrap] Logging in to GitHub CLI..."
  gh auth login </dev/tty || echo "[bootstrap] gh auth login をスキップしました。後で gh auth login を実行してください"
fi

echo "[bootstrap] Launching Karabiner-Elements for permission prompts..."
open -a "Karabiner-Elements" || echo "[bootstrap] Karabiner-Elements を起動できませんでした。手動で一度起動してください"

echo "[bootstrap] Done. Remaining manual steps (詳細は README の First boot checklist):"
echo "  1. Karabiner-Elements のドライバ拡張と入力監視をシステム設定で許可する"
echo "  2. claude で /login、codex・Slack など各アプリにサインインする"
echo "  3. 外部スキルを復元する: npx -y skills add mattpocock/skills -g ほか"
echo "  4. Git の email をこのマシン用に変える場合: ~/.config/chezmoi/chezmoi.toml の [data] を編集して chezmoi apply"
