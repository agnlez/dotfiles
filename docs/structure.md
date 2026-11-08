# Structure

The dotfiles support macOS and Windows (see [ADR-0002](adr/0002-support-macos-and-windows.md)).

Each tool gets a top-level directory. Files are symlinked to their target locations by the installer for the current OS: `install.sh` on macOS, `install.ps1` on Windows. Each directory belongs to one scope:

| Scope   | Directories                                               | Linked by                     |
| ------- | --------------------------------------------------------- | ----------------------------- |
| Shared  | `atuin/`, `claude/`, `git/`, `starship/`, `.editorconfig` | both installers               |
| macOS   | `ghostty/`, `homebrew/`, `zsh/`                           | `install.sh`                  |
| Windows | `powershell/`, `scoop/`, `windows-terminal/`, `winget/`   | `install.ps1` (not yet added) |

When a shared config needs a value that differs per OS (an install path, a binary name), that value goes in a per-OS file next to it, named `<file>.macos` or `<file>.windows`, and each installer links only its own. The shared file stays free of OS-specific values. For example, `git/.gitconfig` includes `~/.gitconfig.os`, which `install.sh` links to `git/.gitconfig.macos` and `install.ps1` to `git/.gitconfig.windows`.

When a shared config can't include another file, it holds the settings for both OSes side by side. `claude/settings.json` is one: it has matching `Bash(...)` and `PowerShell(...)` permission rules, because Bash rules don't apply to commands Claude Code runs through its PowerShell tool on Windows.

Single-file root configs live at the repo root (e.g. `.editorconfig` → `~/.editorconfig`).

User scripts live in `bin/`; the installer symlinks each entry into `~/.local/bin/`. POSIX scripts (no extension) are macOS-only; `.cmd` and `.ps1` scripts are Windows-only.

The `zsh/.zshenv` file is special: it symlinks to `~/.zshenv` (not `~/.config/zsh/`), because it's the bootstrap file that sets `ZDOTDIR`.

The `claude/` directory contains Claude Code configuration (global CLAUDE.md, settings, rules, skills, templates) symlinked to `~/.claude/`.

## Windows

The Windows directories map to these targets:

- `powershell/profile.ps1` → `$PROFILE.CurrentUserAllHosts` (`Documents\PowerShell\profile.ps1`), so every PowerShell 7 host loads it, IDE terminals included. `powershell/aliases.ps1` is linked next to it, where the profile dot-sources it from. The profile exits early in non-interactive sessions, so its aliases never shadow built-ins in scripts.
- `windows-terminal/dotfiles.json` → `%LOCALAPPDATA%\Microsoft\Windows Terminal\Fragments\dotfiles\`. It's a [JSON fragment](https://learn.microsoft.com/en-us/windows/terminal/json-fragment-extensions) rather than a linked `settings.json`, because Windows Terminal rewrites its settings file whenever it's changed from the UI. A fragment can't set global settings, and `profiles.defaults` in `settings.json` overrides it, so keep `colorScheme` and `font` out of the defaults.
- `winget/packages.json` and `scoop/scoopfile.json` aren't linked: `winget import` and `scoop import` read them. They mirror `homebrew/Brewfile` minus macOS-only entries. Scoop covers only what winget lacks.

## Line endings

`.gitattributes` checks every file out with LF on both OSes, overriding Git for Windows' system-wide `core.autocrlf=true`: the files are symlinked into place and read by bash, zsh and git, which break on CRLF. `.cmd` and `.bat` files are the exception and use CRLF, which `cmd.exe` needs.

## Adding a new config

1. Create a directory: `tool-name/`
2. Add the config file(s)
3. Decide its scope (shared, macOS or Windows) and add it to the table above
4. Add symlink entries to the installer of each OS it applies to
5. Update `CHANGELOG.md`
