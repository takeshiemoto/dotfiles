#!/usr/bin/env bash
set -eu

echo "[chezmoi] Applying macOS defaults..."

defaults write com.apple.dock autohide -bool true
killall Dock || true

defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

caps_lock_to_control='<dict><key>HIDKeyboardModifierMappingSrc</key><integer>30064771129</integer><key>HIDKeyboardModifierMappingDst</key><integer>30064771300</integer></dict>'
builtin_keyboard="com.apple.keyboard.modifiermapping.0-0-0"
hhkb="com.apple.keyboard.modifiermapping.1278-33-0"
defaults -currentHost write -g "$builtin_keyboard" -array "$caps_lock_to_control"
defaults -currentHost write -g "$hhkb" -array "$caps_lock_to_control"
