# Structure

Each tool gets a top-level directory (`atuin/`, `claude/`, `ghostty/`, `git/`, `homebrew/`, `starship/`, `zellij/`, `zsh/`).
Files are symlinked to their target locations by `install.sh`.

Single-file root configs live at the repo root (e.g. `.editorconfig` → `~/.editorconfig`).

User scripts live in `bin/`; `install.sh` symlinks each entry into `~/.local/bin/`.

The `zsh/.zshenv` file is special: it symlinks to `~/.zshenv` (not `~/.config/zsh/`), because it's the bootstrap file that sets `ZDOTDIR`.

The `claude/` directory contains Claude Code configuration (global CLAUDE.md, settings, rules, skills, hooks, templates) symlinked to `~/.claude/`.

## Adding a new config

1. Create a directory: `tool-name/`
2. Add the config file(s)
3. Add symlink entries to `install.sh`
4. Update `CHANGELOG.md`
