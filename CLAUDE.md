# Dotfiles

## Claude Code configuration

All Claude Code global configuration is managed through this repository and symlinked to `~/.claude/`. Never modify the following files directly — edit them here instead:

- `claude/settings.json` → `~/.claude/settings.json`
- `claude/CLAUDE.md` → `~/.claude/CLAUDE.md`
- `claude/rules/` → `~/.claude/rules/`
- `claude/skills/` → `~/.claude/skills/`
- `claude/hooks/` → `~/.claude/hooks/`

## Changelog

When making changes to any configuration file, update `CHANGELOG.md` following the [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) format. Add entries under an `## [Unreleased]` section at the top, using the appropriate subsection (`Added`, `Changed`, `Removed`, `Fixed`).
