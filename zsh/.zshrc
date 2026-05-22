# --- Zinit ---
ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"
[ ! -d "$ZINIT_HOME" ] && mkdir -p "$(dirname $ZINIT_HOME)" && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

# Turbo-loaded plugins (deferred until after first prompt)
zinit wait lucid for \
    atinit"zicompinit; zicdreplay" \
        zdharma-continuum/fast-syntax-highlighting \
    atload"_zsh_autosuggest_start" \
        zsh-users/zsh-autosuggestions \
    blockf atpull'zinit creinstall -q .' \
        zsh-users/zsh-completions \
    OMZP::git

# Personal aliases
source "$ZDOTDIR/aliases.zsh"

export ARCHFLAGS="-arch $(uname -m)"

# fnm completions
command -v fnm >/dev/null && eval "$(fnm env --use-on-cd --version-file-strategy=recursive --shell zsh)"

# Set up fzf key bindings and fuzzy completion, then move the file picker
# off ^T (claimed by zellij's Tab mode) to Alt+T.
if command -v fzf >/dev/null; then
  source <(fzf --zsh)
  for keymap in emacs viins vicmd; do
    bindkey -M $keymap -r '^T'
    bindkey -M $keymap '^[t' fzf-file-widget
  done
  unset keymap
fi

# Global fzf defaults (UI + keybindings)
export FZF_DEFAULT_OPTS="--height 50% --layout=reverse --border \
  --bind 'ctrl-/:toggle-preview,ctrl-u:preview-half-page-up,ctrl-d:preview-half-page-down,shift-up:preview-up,shift-down:preview-down'"

# Use fd for standalone fzf and the file-picker widget (Alt+T)
export FZF_DEFAULT_COMMAND='fd --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

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

# Local user binaries (e.g. Claude Code native installer)
export PATH="$HOME/.local/bin:$PATH"

# zoxide
command -v zoxide >/dev/null && eval "$(zoxide init zsh)"

# atuin (shell history)
command -v atuin >/dev/null && eval "$(atuin init zsh)"

# starship
command -v starship >/dev/null && eval "$(starship init zsh)"

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac
# pnpm end

# zellij — auto-attach in normal terminals; skip inside Claude Code agent shells
if [[ -z "$ZELLIJ" && -z "$CLAUDECODE" ]] && (( $+commands[zellij] )); then
  export ZELLIJ_AUTO_EXIT=true
  eval "$(zellij setup --generate-auto-start zsh)"
fi
