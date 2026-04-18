# --- Zinit ---
ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"
[ ! -d "$ZINIT_HOME" ] && mkdir -p "$(dirname $ZINIT_HOME)" && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

# OMZ git plugin (same aliases: ga, gco, gst, etc.)
zinit snippet OMZP::git

# Turbo-loaded plugins (deferred until after first prompt)
zinit wait lucid for \
    atinit"zicompinit; zicdreplay" \
        zdharma-continuum/fast-syntax-highlighting \
    atload"_zsh_autosuggest_start" \
        zsh-users/zsh-autosuggestions \
    blockf atpull'zinit creinstall -q .' \
        zsh-users/zsh-completions

# Personal aliases
source "$ZDOTDIR/aliases.zsh"

# Git wrapper — redirects `git log` to the fancy `git lg` alias
git() {
  if [[ "$1" == "log" ]]; then
    command git lg "${@:2}"
  else
    command git "$@"
  fi
}

export ARCHFLAGS="-arch $(uname -m)"

# fnm completions
eval "$(fnm env --use-on-cd --version-file-strategy=recursive --shell zsh)"

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)

# fzf completion options
export FZF_COMPLETION_OPTS='--border --info=inline'
export FZF_COMPLETION_PATH_OPTS='--walker file,dir,follow,hidden'

# Use fd instead of the default find for path/dir completion
_fzf_compgen_path() {
  fd --hidden --follow --exclude ".git" . "$1"
}
_fzf_compgen_dir() {
  fd --type d --hidden --follow --exclude ".git" . "$1"
}

# Command-specific fzf options via _fzf_comprun
_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
    export|unset) fzf --preview "eval 'echo \${}'"                        "$@" ;;
    ssh)          fzf --preview 'dig {}'                                   "$@" ;;
    *)            fzf --preview 'bat -n --color=always {}'                 "$@" ;;
  esac
}

. "$HOME/.local/bin/env"

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# zoxide
eval "$(zoxide init zsh)"

# starship
eval "$(starship init zsh)"
