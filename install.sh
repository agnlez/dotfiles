#!/bin/bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d_%H%M%S)"

info() { printf "\033[1;34m→\033[0m %s\n" "$1"; }
success() { printf "\033[1;32m✓\033[0m %s\n" "$1"; }
warn() { printf "\033[1;33m!\033[0m %s\n" "$1"; }

link_file() {
  local src="$1" dst="$2"

  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    return
  fi

  if [ -L "$dst" ]; then
    ln -sfn "$src" "$dst"
    success "Updated symlink: $dst → $src"
  elif [ -e "$dst" ]; then
    mkdir -p "$BACKUP_DIR"
    mv "$dst" "$BACKUP_DIR/$(basename "$dst")"
    warn "Backed up $dst → $BACKUP_DIR/$(basename "$dst")"
    ln -s "$src" "$dst"
    success "Linked: $dst → $src"
  else
    mkdir -p "$(dirname "$dst")"
    ln -s "$src" "$dst"
    success "Linked: $dst → $src"
  fi
}

# Xcode Command Line Tools
if ! xcode-select -p &>/dev/null; then
  info "Installing Xcode Command Line Tools..."
  xcode-select --install
  echo "Press any key after installation completes."
  read -rn 1
fi

# Homebrew
if ! command -v brew &>/dev/null; then
  info "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Packages
info "Installing Homebrew packages..."
brew bundle --file="$DOTFILES/homebrew/Brewfile"

# Claude Code (native installer — self-contained, auto-updating)
if ! command -v claude &>/dev/null; then
  info "Installing Claude Code (native)..."
  curl -fsSL https://claude.ai/install.sh | bash
fi

# Directories
mkdir -p "$HOME/Developer"

# Symlinks
info "Linking config files..."

# zsh
link_file "$DOTFILES/zsh/.zshenv" "$HOME/.zshenv"
mkdir -p "$HOME/.config/zsh"
link_file "$DOTFILES/zsh/.zprofile" "$HOME/.config/zsh/.zprofile"
link_file "$DOTFILES/zsh/.zshrc" "$HOME/.config/zsh/.zshrc"
link_file "$DOTFILES/zsh/aliases.zsh" "$HOME/.config/zsh/aliases.zsh"

# git
link_file "$DOTFILES/git/.gitconfig" "$HOME/.gitconfig"
link_file "$DOTFILES/git/.gitignore_global" "$HOME/.gitignore"
if [ ! -e "$HOME/.gitconfig.local" ]; then
  cp "$DOTFILES/git/.gitconfig.local.example" "$HOME/.gitconfig.local"
  success "Created $HOME/.gitconfig.local from template"
fi

# starship
mkdir -p "$HOME/.config"
link_file "$DOTFILES/starship/starship.toml" "$HOME/.config/starship.toml"

# ghostty
mkdir -p "$HOME/Library/Application Support/com.mitchellh.ghostty"
link_file "$DOTFILES/ghostty/config" "$HOME/Library/Application Support/com.mitchellh.ghostty/config"

# atuin
mkdir -p "$HOME/.config/atuin"
link_file "$DOTFILES/atuin/config.toml" "$HOME/.config/atuin/config.toml"

# editorconfig
link_file "$DOTFILES/.editorconfig" "$HOME/.editorconfig"

# claude code
link_file "$DOTFILES/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
link_file "$DOTFILES/claude/settings.json" "$HOME/.claude/settings.json"
link_file "$DOTFILES/claude/rules" "$HOME/.claude/rules"
link_file "$DOTFILES/claude/skills" "$HOME/.claude/skills"
link_file "$DOTFILES/claude/hooks" "$HOME/.claude/hooks"

echo ""
success "Done! Open a new terminal to load the updated config."
echo ""
warn "Edit ~/.gitconfig.local with your git identity and signing key."
