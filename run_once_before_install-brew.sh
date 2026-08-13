#!/usr/bin/env bash
set -eu

if command -v brew >/dev/null 2>&1; then
  exit 0
fi

echo "[chezmoi] Installing Homebrew..."
brew_installer="$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
NONINTERACTIVE=1 /bin/bash -c "$brew_installer"
