export VISUAL="nvim"
export EDITOR="nvim"

# ---- helpers ----
path_prepend() { [[ -d "$1" ]] && path=("$1" $path); }
path_append()  { [[ -d "$1" ]] && path+=("$1"); }

# homebrew
[[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"

# zsh's path array: unique
typeset -U path PATH

# ---- aliases (common) ----
alias g='git'
alias ls='eza'
alias ll='ls -l'
alias gl='g log --oneline'
alias gss='g status -sb'
alias cz='chezmoi'
alias cat='bat'
alias ccdang="claude --dangerously-skip-permissions"

# pure
fpath+=("$(brew --prefix)/share/zsh/site-functions")
autoload -U promptinit; promptinit
prompt pure

# bind fix
bindkey '^R' history-incremental-search-backward
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line

# auto suggestions
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
# syntax highlighting
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# rbenv
eval "$(rbenv init - zsh)"

# asdf
export ASDF_DATA_DIR="$HOME/.asdf"
path_prepend "$ASDF_DATA_DIR/shims"

# cargo
path_prepend "$HOME/.cargo/bin"

# java
path_prepend "$(brew --prefix)/opt/openjdk/bin"

# claude
path_prepend "$HOME/.local/bin"

# zoxide
eval "$(zoxide init zsh)"

# conf.d loader
for _f in "${HOME}/.config/.zsh/conf.d/"*.zsh(N); do
  source "$_f"
done
unset _f
