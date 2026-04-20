# Dotfiles

Personal dotfiles for macOS (Apple Silicon).

## What's included

| Directory | Contents |
|-----------|----------|
| `zsh/` | Zsh config with zinit, fzf (with `fd`), zoxide, atuin history |
| `git/` | Git config with SSH signing (1Password), delta pager, trunk-based defaults |
| `starship/` | Custom two-line prompt (directory, git, nodejs, docker, duration) |
| `ghostty/` | Ghostty terminal config (Catppuccin Macchiato, Monaspice Nerd Font) |
| `atuin/` | Atuin shell history config (daemon, directory-scoped up-arrow) |
| `claude/` | Claude Code global settings, rules, skills, and hooks |
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
4. Install Claude Code via the native installer (self-contained, auto-updating)
5. Symlink config files to their expected locations
6. Back up any existing files to `~/.dotfiles-backup/`

## Manual steps after install

### Git identity

`install.sh` creates `~/.gitconfig.local` from `git/.gitconfig.local.example` on first run. Edit it with your name, email, and SSH signing key path. It's loaded via `[include]` and **overrides** the tracked gitconfig, so machine-specific values (e.g. a non-default 1Password path) belong here too.

### 1Password

- Sign into 1Password and enable the SSH agent
- Add your SSH key to 1Password and register the public key on GitHub as **both** an authentication key *and* a signing key
- The gitconfig uses `op-ssh-sign` at the default macOS path (`/Applications/1Password.app/...`) — override in `~/.gitconfig.local` under `[gpg "ssh"]` if installed elsewhere

### Apps

Sign into the rest (Slack, Discord, Spotify, etc.)
