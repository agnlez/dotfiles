# Dotfiles

Personal dotfiles for macOS (Apple Silicon).

## What's included

| Directory   | Contents                                                                   |
| ----------- | -------------------------------------------------------------------------- |
| `zsh/`      | Zsh config with zinit, fzf (with `fd`), zoxide, atuin history              |
| `git/`      | Git config with SSH signing (1Password), delta pager, trunk-based defaults |
| `starship/` | Custom two-line prompt (directory, git, nodejs, docker, duration)          |
| `ghostty/`  | Terminal config in Ghostty format, read by cmux (Monaspice Nerd Font)      |
| `atuin/`    | Atuin shell history config (daemon, directory-scoped up-arrow)             |
| `claude/`   | Claude Code global settings, rules, skills, and templates                  |
| `homebrew/` | Brewfile with formulas, casks, and fonts                                   |
| `bin/`      | User scripts symlinked into `~/.local/bin`                                 |

## Before wiping a machine

These live outside the repo, and nothing recreates them. Copy them somewhere safe, then put them back at the same paths after `install.sh`:

- `~/.gitconfig.local` and `~/.config/git/allowed_signers`: git identity and signature verification
- `~/.ssh/config`: SSH host aliases
- Uncommitted changes in this repo (`git status`)

## Install

On a fresh Mac, the first `git` call prompts to install the Xcode Command Line Tools. Accept, and run the command again once they're installed.

```sh
mkdir -p ~/Developer
git clone https://github.com/agnlez/dotfiles.git ~/Developer/dotfiles
cd ~/Developer/dotfiles
./install.sh
```

Clone over HTTPS: the SSH key lives in 1Password, which isn't set up yet. Switch the remote to SSH once it is (see [1Password](#1password)).

The install script will:

1. Install Xcode Command Line Tools (if missing)
2. Install Homebrew (if missing)
3. Install all packages from the Brewfile (a failure doesn't stop the linking; rerun the script once it's fixed)
4. Install the Node version pinned in `.node-version` via fnm and make it the default
5. Install Claude Code via the native installer (self-contained, auto-updating)
6. Symlink config files to their expected locations
7. Back up any existing files to `~/.dotfiles-backup/`

## Manual steps after install

### Git identity

`install.sh` creates `~/.gitconfig.local` from `git/.gitconfig.local.example` on first run. Edit it with your name, email, and SSH signing key path, and create `~/.config/git/allowed_signers` with a `you@example.com ssh-ed25519 AAAA…` line per key you trust, so git can verify signatures. It's loaded via `[include]` and **overrides** the tracked gitconfig, so machine-specific values (e.g. a non-default 1Password path) belong here too.

### 1Password

- Sign into 1Password and enable the SSH agent
- Add your SSH key to 1Password and register the public key on GitHub as **both** an authentication key _and_ a signing key
- Switch the dotfiles remote to SSH: `git -C ~/Developer/dotfiles remote set-url origin git@github.com:agnlez/dotfiles.git`
- The gitconfig uses `op-ssh-sign` at the default macOS path (`/Applications/1Password.app/...`) — override in `~/.gitconfig.local` under `[gpg "ssh"]` if installed elsewhere

### Apps

Sign into the rest (Slack, Spotify, etc.)

### Podman

The `podman-desktop` cask installs only the app. Open Podman Desktop and complete its onboarding to install the `podman` CLI (into `/opt/podman`) and start a machine. The zsh `docker` alias and the `bin/docker` shim both forward to it.

### Claude Code MCP servers

User-scope MCP servers live in `~/.claude.json`, which isn't tracked. Re-add them after install:

```sh
claude mcp add -s user chrome-devtools -- npx chrome-devtools-mcp@latest
claude mcp add -s user next-devtools -- npx next-devtools-mcp@latest
```

### Logitech mouse

When using a Logitech mouse, manage it with [Mouser](https://github.com/TomBadash/Mouser) — a lightweight, fully local, open-source alternative to Logitech Options+ — instead of the official Logitech app. There is no official Homebrew cask; download `Mouser-macOS.zip` (Apple Silicon) from the [releases page](https://github.com/TomBadash/Mouser/releases), extract, and move `Mouser.app` to `/Applications`.

### Project tooling (prek + oxfmt + oxlint)

Pre-commit formatting and linting are managed by [prek](https://github.com/j178/prek) (a Rust-based, drop-in pre-commit alternative) with [oxfmt](https://oxc.rs/docs/guide/usage/formatter.html), [oxlint](https://oxc.rs/docs/guide/usage/linter), and the standard [pre-commit-hooks](https://github.com/pre-commit/pre-commit-hooks). pnpm manages prek itself; oxc and pre-commit-hooks are pinned in `.pre-commit-config.yaml`.

After cloning, in `~/Developer/dotfiles`:

```sh
pnpm install                                               # installs prek; prepare hook wires .git/hooks/pre-commit
git config blame.ignoreRevsFile .git-blame-ignore-revs     # skip the bulk-format commit in git blame
```

`fnm` reads `.node-version` (Node 24); the standalone pnpm binary (Homebrew) reads `devEngines.packageManager` in `package.json` (pnpm 12) and auto-switches to the pinned version.
