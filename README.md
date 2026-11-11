# Dotfiles

Personal dotfiles for macOS (Apple Silicon) and Windows 11. `install.sh` sets up macOS and `install.ps1` sets up Windows; see [docs/structure.md](docs/structure.md) for which files each one links.

## What's included

| Directory           | OS      | Contents                                                                     |
| ------------------- | ------- | ---------------------------------------------------------------------------- |
| `zsh/`              | macOS   | Zsh config with zinit, fzf (with `fd`), zoxide, atuin history                |
| `powershell/`       | Windows | PowerShell 7 profile with PSReadLine, fzf (PSFzf), zoxide, atuin, fnm        |
| `git/`              | Shared  | Git config with SSH signing (1Password), delta pager, trunk-based defaults   |
| `starship/`         | Shared  | Custom two-line prompt (directory, git, nodejs, docker, duration)            |
| `ghostty/`          | macOS   | Terminal config in Ghostty format, read by cmux (Monaspice Nerd Font)        |
| `windows-terminal/` | Windows | Windows Terminal fragment: color schemes and font for the PowerShell profile |
| `atuin/`            | Shared  | Atuin shell history config (daemon, directory-scoped up-arrow)               |
| `claude/`           | Shared  | Claude Code global settings, rules, skills, and templates                    |
| `homebrew/`         | macOS   | Brewfile with formulas, casks, and fonts                                     |
| `winget/`           | Windows | winget import list with CLI tools and apps                                   |
| `scoop/`            | Windows | Scoop import list for what winget lacks (Monaspace Nerd Font, Railway CLI)   |
| `bin/`              | macOS   | User scripts symlinked into `~/.local/bin`                                   |

## Before wiping a machine

These live outside the repo, and nothing recreates them. Copy them somewhere safe, then put them back at the same paths after running the installer:

- `~/.gitconfig.local` and `~/.config/git/allowed_signers`: git identity and signature verification
- `~/.ssh/config`: SSH host aliases
- Uncommitted changes in this repo (`git status`)

## Install

Both installers can be rerun safely: installed packages are skipped and correct links are left alone. Rerun yours after pulling changes too, since new links (such as `~/.gitconfig.os`) only appear when the installer runs.

### macOS

On a fresh Mac, the first `git` call prompts to install the Xcode Command Line Tools. Accept, and run the command again once they're installed.

```sh
mkdir -p ~/dev
git clone https://github.com/agnlez/dotfiles.git ~/dev/dotfiles
cd ~/dev/dotfiles
./install.sh
```

Clone over HTTPS: the SSH key lives in 1Password, which isn't set up yet. Switch the remote to SSH once it is (see [1Password](#1password)).

The install script will:

1. Install Xcode Command Line Tools (if missing)
2. Install Homebrew (if missing)
3. Install all packages from the Brewfile (a failure doesn't stop the linking; rerun the script once it's fixed)
4. Install the Node version pinned in `.node-version` via fnm and make it the default
5. Install Claude Code via the native installer (self-contained, auto-updating)
6. Create `~/dev`, where all projects live
7. Symlink config files to their expected locations
8. Back up any existing files to `~/.dotfiles-backup/`

### Windows

Turn on Developer Mode first (Settings → System → For developers), so symlinks can be created without admin rights. Then install git and PowerShell 7, which the installer itself needs:

```powershell
winget install -e --id Git.Git
winget install -e --id Microsoft.PowerShell
```

In a new PowerShell 7 (`pwsh`) window:

```powershell
git clone https://github.com/agnlez/dotfiles.git $HOME/dev/dotfiles
cd $HOME/dev/dotfiles
./install.ps1
```

Run `./install.ps1 -WhatIf` first to see what it would install, set and link without changing anything. Clone over HTTPS, as on macOS.

The install script will:

1. Check that symlinks can be created (Developer Mode) and that winget is present
2. Install the packages in `winget/packages.json`, with `--no-upgrade` so reruns skip installed ones (upgrade with `winget upgrade --all`)
3. Install scoop (if missing) and the packages in `scoop/scoopfile.json`
4. Install the PSFzf module from the PowerShell Gallery
5. Add `~/.local/bin` and pnpm's bin directory to the user `PATH` and set `PNPM_HOME`, since Windows keeps these as persistent per-user variables rather than in the shell profile
6. Install the Node version pinned in `.node-version` via fnm and make it the default
7. Install Claude Code via the native installer
8. Create `~/dev`, symlink config files to their expected locations, and back up any existing files to `~/.dotfiles-backup/`

As on macOS, a failed package doesn't stop the linking.

## After install

The steps for both OSes come first, then the ones specific to each.

### 1Password

- Sign into 1Password and enable the SSH agent
- Add your SSH key to 1Password and register the public key on GitHub as **both** an authentication key _and_ a signing key
- On Windows, stop and disable the "OpenSSH Authentication Agent" service (Services → Startup type: Disabled). It serves the same named pipe as 1Password's agent
- Switch the dotfiles remote to SSH: `git -C ~/dev/dotfiles remote set-url origin git@github.com:agnlez/dotfiles.git`

The signing program comes from the per-OS file linked to `~/.gitconfig.os`. On macOS, `git/.gitconfig.macos` uses `op-ssh-sign` at 1Password's default path (`/Applications/1Password.app/...`). On Windows, `git/.gitconfig.windows` calls `op-ssh-sign.exe` from `PATH`, and points git at Windows' OpenSSH, the only ssh that can reach 1Password's pipe. If 1Password is installed elsewhere, override `program` in `~/.gitconfig.local` under `[gpg "ssh"]`.

### Git identity

The installer creates `~/.gitconfig.local` from `git/.gitconfig.local.example` on first run. It's loaded via `[include]` after `~/.gitconfig.os` and **overrides** both, so machine-specific values (e.g. a non-default 1Password path) belong here too. Fill in:

- `name` and `email`
- `signingkey`: the private key stays in 1Password, so there's no key file to point at. Use the public key itself, prefixed with `key::` (`key::ssh-ed25519 AAAA…`). Copy it from the key's item in 1Password, or list the agent's keys:
  - macOS: `SSH_AUTH_SOCK=~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock ssh-add -L`. A plain `ssh-add -L` asks the macOS agent, which doesn't have it.
  - Windows: `C:\Windows\System32\OpenSSH\ssh-add.exe -L`, once the OpenSSH service is disabled. The `ssh-add` that ships with Git for Windows can't reach 1Password's pipe.

Then create `~/.config/git/allowed_signers` with a `you@example.com ssh-ed25519 AAAA…` line per key you trust, so git can verify signatures. Check with a commit and `git log --show-signature -1`.

### Claude Code MCP servers

User-scope MCP servers live in `~/.claude.json`, which isn't tracked: it's Claude Code's runtime state, holding caches, account details and server credentials. The servers themselves are listed in `claude/mcp-servers.json`, and both installers register each one with `claude mcp`, replacing any existing server of the same name. To add or change a server, edit that file and rerun the installer.

- `${HOME}` in the file is replaced with your home directory at install time.
- Servers started with `npx` pass `--prefix ${HOME}`. Claude Code starts MCP servers from the project root, and npm refuses to run when that project's `devEngines.packageManager` names another package manager (`EBADDEVENGINES`). `--prefix` makes npm read your home directory instead, which has no `package.json`.
- The Playwright server is registered here instead of through the `playwright` plugin, which is disabled in `settings.json`: the plugin starts `npx` without `--prefix`, and its config can't be changed.
- `install.ps1` passes `command` and `args` to `claude mcp add`, so only `stdio` servers work on Windows.
- Servers that need credentials, such as SonarQube, aren't in the file. Add them by hand with `claude mcp add -s user`.

### Apps

Sign into the rest (Slack, Spotify, etc.)

### macOS only

#### Podman

The `podman-desktop` cask installs only the app. Open Podman Desktop and complete its onboarding to install the `podman` CLI (into `/opt/podman`) and start a machine. The zsh `docker` alias and the `bin/docker` shim both forward to it.

#### Logitech mouse

When using a Logitech mouse, manage it with [Mouser](https://github.com/TomBadash/Mouser) — a lightweight, fully local, open-source alternative to Logitech Options+ — instead of the official Logitech app. There is no official Homebrew cask; download `Mouser-macOS.zip` (Apple Silicon) from the [releases page](https://github.com/TomBadash/Mouser/releases), extract, and move `Mouser.app` to `/Applications`.

### Windows only

#### Windows Terminal

The dotfiles fragment styles the PowerShell profile, but `profiles.defaults` in Windows Terminal's `settings.json` overrides it. Remove `colorScheme` and `font` from the defaults if they're there; `install.ps1` warns when they are. Set PowerShell (not Windows PowerShell) as the default profile, which a fragment can't do.

## Project tooling (prek + oxfmt + oxlint)

Pre-commit formatting and linting are managed by [prek](https://github.com/j178/prek) (a Rust-based, drop-in pre-commit alternative) with [oxfmt](https://oxc.rs/docs/guide/usage/formatter.html), [oxlint](https://oxc.rs/docs/guide/usage/linter), and the standard [pre-commit-hooks](https://github.com/pre-commit/pre-commit-hooks). pnpm manages prek itself; oxc and pre-commit-hooks are pinned in `.pre-commit-config.yaml`.

After cloning, in `~/dev/dotfiles`:

```sh
pnpm install                                               # installs prek; prepare hook wires .git/hooks/pre-commit
git config blame.ignoreRevsFile .git-blame-ignore-revs     # skip the bulk-format commit in git blame
```

The same hooks run in CI on every push to `main` and every PR (`.github/workflows/lint.yml`), using the prek version pinned in `package.json`. Two more CI jobs lint the scripts that no test runs: PSScriptAnalyzer for the PowerShell (settings in `PSScriptAnalyzerSettings.psd1`) and shellcheck for `install.sh`, `claude/statusline.sh` and `bin/docker`. Since commits go straight to `main`, CI flags a problem after the push rather than blocking it; the local hook is still the first line of defence.

`fnm` reads `.node-version` (Node 24); the standalone pnpm binary (Homebrew on macOS, winget on Windows) reads `devEngines.packageManager` in `package.json` (pnpm 12) and auto-switches to the pinned version.
