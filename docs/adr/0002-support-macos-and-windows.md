# 0002. Support macOS and Windows

- **Status**: accepted
- **Date**: 2026-11-08

## Context

The dotfiles were macOS-only: Homebrew, zsh, Ghostty, and install paths under `/Applications` and `/opt`. They now also need to set up a Windows machine, where the shell is PowerShell, packages come from winget, symlinks need Developer Mode, and Git for Windows checks files out with CRLF by default. Most of the config (git, starship, atuin, Claude Code, editorconfig) is the same on both.

## Decision

Keep one directory per tool, each scoped to shared, macOS or Windows, with one installer per OS (`install.sh`, `install.ps1`). Values that differ per OS inside a shared config go in a `<file>.macos` / `<file>.windows` file that only that OS's installer links. Details in `docs/structure.md`.

## Alternatives considered

- **chezmoi** (templates and per-OS conditionals): handles this natively, but means renaming every file into its source-state layout, learning its template language, and replacing an installer that already works.
- **Top-level `common/`, `macos/`, `windows/` trees**: splits each tool's files across directories and churns every existing path for little gain over a scope table.
- **A separate repo or branch for Windows**: shared config would drift between the two.

## Consequences

- **Positive**: existing paths and the macOS installer stay as they are; shared files are edited once.
- **Trade-offs**: two installers keep their own link lists, which have to be kept in step for shared configs; files are checked out with LF on Windows.
- **Follow-ups**: split OS-specific values out of `git/.gitconfig`, make `claude/settings.json` work on both, add the Windows configs and `install.ps1`, and split the README per OS.
