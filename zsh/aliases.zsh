# Personal aliases
# When this file grows past ~50 entries, split into zsh/aliases/{system,nav,git,cli}.zsh
# and source each from .zshrc.

# --- Config editors ---
alias zshsource="source $ZDOTDIR/.zshrc"
alias zshconfig="webstorm $ZDOTDIR/.zshrc"
alias sshconfig="webstorm ~/.ssh/config"
alias gitconfig="webstorm ~/.gitconfig"
alias gitignore="webstorm ~/.gitignore"

# --- Navigation (zoxide) ---
alias zi='__zoxide_zi'         # Override zinit's zi alias
alias zz='z -'                 # Quick back navigation
alias zh='z ~'                 # Quick home
alias zl='zoxide query -l -s'  # List with scores

# --- Git ---
alias gl="git lg"
alias gla="git lga"

# --- Modern CLI replacements ---
# grep/find aliases apply only to interactive shells — scripts (#!/bin/bash, etc.) still get the real binaries.
# Bypass with `\grep`, `command grep`, or `/usr/bin/grep` when you need the original (e.g. `grep -P`, `find -maxdepth`).
alias grep="rg"
alias find="fd"
alias cat="bat --paging=never"
alias ls="eza --icons --group-directories-first"
alias ll="eza --icons --group-directories-first -la --git --group"
alias lt="eza --icons --tree --level=2"
alias lta="eza --icons --tree --level=2 -a --ignore-glob='.git|node_modules'"
