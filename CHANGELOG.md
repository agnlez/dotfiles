# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Added
- `.zshenv` setting `ZDOTDIR` to `~/.config/zsh`
- `.zprofile` for Homebrew shell environment setup
- `aliases.zsh` with personal aliases, zoxide shortcuts, and modern CLI replacements
- Brewfile formulas: `bat`, `eza`, `fd`, `fzf`, `ripgrep`, `starship`, `zoxide`
- Brewfile casks: `brave-browser`, `claude`, `claude-code`, `ghostty`, `signal`
- Brewfile fonts: `font-intel-one-mono`, `font-monaspace`
- `CLAUDE.md` with project instructions

### Changed
- Renamed `oh-my-zsh/` folder to `zsh/`
- Replaced old oh-my-zsh `.zshrc` with current zinit-based configuration
- Replaced `warp` cask with `ghostty`

### Removed
- Legacy oh-my-zsh configuration (NVM, steeef theme)
- Brewfile casks: `1password-cli`, `notion-calendar`, `postman`, `proton-mail-bridge`, `protonvpn`, `warp`, `zoom`
- Legacy scripts: `power-management.sh`, `update.sh`

## [1.0.0] - 2019-02-01
### Added
- Changelog file 🎉
- More logs during the process informing the user what is going on 💬

### Removed
- `brew prune` command. Deprecated in [Homebrew 1.9](https://brew.sh/2019/01/09/homebrew-1.9.0/). Now it is included in `brew cleanup`
  [(https://github.com/Homebrew/brew/pull/5467)](https://github.com/Homebrew/brew/pull/5467).
