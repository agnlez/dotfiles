# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [2.0.0] - 2026-04-18
### Added
- `.zshenv` setting `ZDOTDIR` to `~/.config/zsh`
- `.zprofile` for Homebrew shell environment setup
- `aliases.zsh` with personal aliases, zoxide shortcuts, and modern CLI replacements
- `git/.gitconfig` with GPG signing, delta pager, custom aliases, rebase workflow, rerere, histogram diffs
- `git/.gitconfig.local` include pattern for personal identity (not tracked)
- `git/.gitignore_global` for system-wide git ignores
- `ghostty/config` with Catppuccin theme, Monaspace font, window padding, and clipboard settings
- `starship/starship.toml` prompt configuration (bracket preset)
- `install.sh` bootstrap script with symlink management and backup
- `.gitignore` for the repo itself
- Brewfile formulas: `bat`, `eza`, `fd`, `fzf`, `git-delta`, `ripgrep`, `starship`, `zoxide`
- Brewfile casks: `brave-browser`, `claude`, `claude-code`, `dbeaver-community`, `ghostty`, `signal`
- Brewfile fonts: `font-intel-one-mono`, `font-monaspace`
- `CLAUDE.md` with project structure conventions and changelog instructions
- `claude/` directory with Claude Code configuration merged from `agnlez/claude-setup`
- `claude/CLAUDE.md` global Claude instructions (symlinked to `~/.claude/CLAUDE.md`)
- `claude/rules/` with `context7.md`, `documentation-driven-development.md`, `esm-exports.md`
- `claude/skills/fix-vulnerabilities/` vulnerability audit and fix skill
- `claude/hooks/optimize-images/` pre-commit image optimization hook
- `claude/settings.json` with sandbox, plugins, hooks, and `acceptEdits` default mode
- `gpg.ssh.program` pointing to 1Password's `op-ssh-sign` for commit signing inside sandbox
- 1Password SSH agent socket to sandbox `allowUnixSockets` for git SSH access inside sandbox
- Auto-allow permissions for safe tools: `Read`, `Edit`, `Write`, `Glob`, `Grep`, `WebFetch`, `WebSearch`
- Auto-allow permissions for git operations: `add`, `commit`, `fetch`, `pull`, `push`, `branch`, `branch -d`, `checkout`, `merge`, `stash`, `tag`, `config`, `log`, `diff`, `show`, `rebase`, `cherry-pick`, `revert`
- Auto-allow permissions for CLI tools: `pnpm`, `npm`, `npx`, `node`, `curl`, `gh`, `jq`, `bat`, `lsof`
- Auto-allow permissions for MCP servers: Context7, Figma, Playwright, Next.js devtools, Atlassian
- Ask-before-run rules for destructive git operations: `push --force`, `push --delete`, `reset --hard`, `clean -f`, `branch -D`, `checkout --`
- Ask-before-run rules for destructive GitHub CLI operations: `pr close`, `pr merge`, `issue close`, `issue delete`, `repo delete`
- Ask-before-run rules for Atlassian write operations: create/edit/transition issues, worklogs, comments, Confluence pages

### Changed
- Renamed `oh-my-zsh/` folder to `zsh/`
- Replaced old oh-my-zsh `.zshrc` with current zinit-based configuration
- Replaced `warp` cask with `ghostty`
- Renamed `docker` cask to `docker-desktop`
- Rewrote `README.md` with install instructions and project overview

### Removed
- Legacy oh-my-zsh configuration (NVM, steeef theme)
- Brewfile casks: `1password-cli`, `notion-calendar`, `postman`, `proton-mail-bridge`, `protonvpn`, `warp`, `zoom`
- Legacy scripts: `power-management.sh`, `update.sh`
- Stale git branches: `develop`, `delete-me`
- Deprecated Homebrew taps: `homebrew/bundle`, `homebrew/services`
- Redundant `context7-mcp` skill (covered by `context7.md` rule)
- Duplicate "Docs Fetching" section from global `claude/CLAUDE.md`
- Duplicate optimize-images hook entry from settings
- `effortLevel` and `skipDangerousModePermissionPrompt` from settings (unnecessary defaults)
- `autoAllowBashIfSandboxed` from sandbox config (replaced by explicit per-command permissions)
- Vizzhub MCP from permissions (unused)

## [1.0.0] - 2019-02-01
### Added
- Changelog file 🎉
- More logs during the process informing the user what is going on 💬

### Removed
- `brew prune` command. Deprecated in [Homebrew 1.9](https://brew.sh/2019/01/09/homebrew-1.9.0/). Now it is included in `brew cleanup`
  [(https://github.com/Homebrew/brew/pull/5467)](https://github.com/Homebrew/brew/pull/5467).
