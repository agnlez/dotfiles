# Dotfiles

## Structure

Each tool gets a top-level directory (`git/`, `zsh/`, `starship/`, `homebrew/`).
Files are symlinked to their target locations by `install.sh`.

The `zsh/.zshenv` file is special: it symlinks to `~/.zshenv` (not `~/.config/zsh/`), because it's the bootstrap file that sets `ZDOTDIR`.

## Adding a new config

1. Create a directory: `tool-name/`
2. Add the config file(s)
3. Add symlink entries to `install.sh`
4. Update `CHANGELOG.md`

## Changelog

When making changes to any configuration file, update `CHANGELOG.md` following the [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) format. Add entries under an `## [Unreleased]` section at the top, using the appropriate subsection (`Added`, `Changed`, `Removed`, `Fixed`).
