export VISUAL="nvim"
export EDITOR="nvim"

# ---- helpers ----
path_prepend() { [[ -d "$1" ]] && path=("$1" $path); }
path_append()  { [[ -d "$1" ]] && path+=("$1"); }

# zsh's path array: unique
typeset -U path PATH

# ---- aliases (common) ----
alias g='git'
alias ls='eza'
alias ll='ls -l'
alias gl='g log --oneline'
alias cz='chezmoi'
alias cat='bat'

# pure
fpath+=("$(brew --prefix)/share/zsh/site-functions")
autoload -U promptinit; promptinit
prompt pure
