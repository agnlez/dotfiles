# Dotfiles

Personal dotfiles for macOS (Apple Silicon).

## What's included

| Directory | Contents |
|-----------|----------|
| `zsh/` | Zsh config with zinit, fzf, zoxide, starship |
| `git/` | Git config with GPG signing, delta pager, aliases |
| `starship/` | Starship prompt preset (bracket style) |
| `ghostty/` | Ghostty terminal config (Catppuccin theme, Monaspace font) |
| `homebrew/` | Brewfile with formulas, casks, and fonts |

## Install

```sh
mkdir -p ~/Developer
git clone git@github.com:agnlez/dotfiles.git ~/Developer/dotfiles
cd ~/Developer/dotfiles
./install.sh
```

The install script will:
1. Install Xcode Command Line Tools (if missing)
2. Install Homebrew (if missing)
3. Install all packages from the Brewfile
4. Symlink config files to their expected locations
5. Back up any existing files to `~/.dotfiles-backup/`

## Manual steps after install

- Sign into 1Password and enable the SSH agent
- Sign into apps (Slack, Discord, Spotify, etc.)