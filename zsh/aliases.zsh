# Personal aliases
alias zshsource="source $ZDOTDIR/.zshrc"
alias zshconfig="webstorm $ZDOTDIR/.zshrc"
alias sshconfig="webstorm ~/.ssh/config"
alias gitconfig="webstorm ~/.gitconfig"
alias gitignore="webstorm ~/.gitignore"

# Zoxide shortcuts
alias zi='__zoxide_zi'   # Override zinit's zi alias
alias zz='z -'           # Quick back navigation
alias zh='z ~'           # Quick home
alias zl='zoxide query -l -s'  # List with scores

# Modern CLI replacements
alias grep="rg"
alias find="fd"
alias cat="bat"
alias ls="eza"
