# Dotfiles

Personal dotfiles for macOS (Apple Silicon).

## What's included

| Directory   | Contents                                                                   |
| ----------- | -------------------------------------------------------------------------- |
| `zsh/`      | Zsh config with zinit, fzf (with `fd`), zoxide, atuin history              |
| `git/`      | Git config with SSH signing (1Password), delta pager, trunk-based defaults |
| `starship/` | Custom two-line prompt (directory, git, nodejs, docker, duration)          |
| `ghostty/`  | Ghostty terminal config (Catppuccin Macchiato, Monaspice Nerd Font)        |
| `atuin/`    | Atuin shell history config (daemon, directory-scoped up-arrow)             |
| `claude/`   | Claude Code global settings, rules, skills, and hooks                      |
| `homebrew/` | Brewfile with formulas, casks, and fonts                                   |
| `bin/`      | User scripts symlinked into `~/.local/bin`                                 |

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
- Add your SSH key to 1Password and register the public key on GitHub as **both** an authentication key _and_ a signing key
- The gitconfig uses `op-ssh-sign` at the default macOS path (`/Applications/1Password.app/...`) — override in `~/.gitconfig.local` under `[gpg "ssh"]` if installed elsewhere

### Apps

Sign into the rest (Slack, Discord, Spotify, etc.)

### Logitech mouse

When using a Logitech mouse, manage it with [Mouser](https://github.com/TomBadash/Mouser) — a lightweight, fully local, open-source alternative to Logitech Options+ — instead of the official Logitech app. There is no official Homebrew cask; download `Mouser-macOS.zip` (Apple Silicon) from the [releases page](https://github.com/TomBadash/Mouser/releases), extract, and move `Mouser.app` to `/Applications`.

### Project tooling (prek + oxfmt + oxlint)

Pre-commit formatting and linting are managed by [prek](https://github.com/j178/prek) (a Rust-based, drop-in pre-commit alternative) with [oxfmt](https://oxc.rs/docs/guide/usage/formatter.html), [oxlint](https://oxc.rs/docs/guide/usage/linter), and the standard [pre-commit-hooks](https://github.com/pre-commit/pre-commit-hooks). pnpm 11 manages prek itself; oxc and pre-commit-hooks are pinned in `.pre-commit-config.yaml`.

After cloning, in `~/Developer/dotfiles`:

```sh
corepack enable                                            # one-time per Node install
pnpm install                                               # installs prek; prepare hook wires .git/hooks/pre-commit
git config blame.ignoreRevsFile .git-blame-ignore-revs     # skip the bulk-format commit in git blame
```

`fnm` reads `.node-version` (Node 24) and Corepack reads `packageManager` in `package.json` (pnpm 11).
