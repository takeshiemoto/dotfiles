# dotfiles

<img width="2816" height="1536" alt="Gemini_Generated_Image_t3zn2pt3zn2pt3zn" src="https://github.com/user-attachments/assets/4e7240e1-ea61-470c-a34e-5f0bf4491b55" />

macOS dotfiles managed with [chezmoi](https://www.chezmoi.io/).
Universal config only — machine- and project-specific values stay in gitignored local overrides.

## Install

```bash
brew install chezmoi
chezmoi init https://github.com/takeshiemoto/dotfiles.git
chezmoi apply
```

## Bootstrap

- `run_once_before_install-brew.sh` — installs Homebrew if absent
- `run_once_after_brew-bundle.sh.tmpl` — runs `brew bundle`
