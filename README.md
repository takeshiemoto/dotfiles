# Dotfiles

> Personal development environment configuration for macOS

## Features

- **Automated Setup** - One-command installation for all configurations
- **Package Management** - Homebrew bundle for consistent tool installation
- **Editor Configuration** - Neovim setup with custom configurations
- **Claude Integration** - Synchronized Claude Code settings across machines
- **Version Control** - Git-managed configurations for easy backup and sync

## What's Included

- `Brewfile` - Essential packages and applications
- `init.vim` - Neovim configuration
- `ignore` - Global ignore patterns for various tools
- `claude/` - Claude Code configurations and custom commands

## Installation

Clone this repository and run the installation script:

```bash
git clone https://github.com/takeshiemoto/dotfiles.git ~/projects/github.com/takeshiemoto/dotfiles
cd ~/projects/github.com/takeshiemoto/dotfiles
./install.sh
```

The script will:
1. Install Homebrew (if not already installed)
2. Install all packages from Brewfile
3. Create symbolic links for all configuration files
4. Set up Claude Code integration

## Structure

```
.
├── Brewfile           # Homebrew packages
├── claude/            # Claude Code settings
│   ├── CLAUDE.md     # Development guidelines
│   ├── commands/     # Custom commands
│   └── settings.json # Claude configuration
├── ignore            # Global ignore patterns
├── init.vim          # Neovim configuration
└── install.sh        # Installation script
```

## Updating

To update your configuration:

```bash
cd ~/projects/github.com/takeshiemoto/dotfiles
git pull
./install.sh
```