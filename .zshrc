fpath+=(/Users/nozomeme/.zsh/pure)
autoload -U promptinit; promptinit
prompt pure

if [ "$(uname -m)" = "arm64" ]; then
    export PATH="/Users/nozomeme/opt/anaconda3/bin:$PATH" 
    eval "$(/opt/homebrew/bin/brew shellenv)"
    export "PATH=“/opt/homebrew/bin:$PATH"
else 
    eval "$(/usr/local/bin/brew shellenv)"
    export PATH="/usr/local/bin:$PATH"
fi

eval "$(rbenv init - zsh)"

source ~/.zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source ~/.zsh-autosuggestions/zsh-autosuggestions.zsh
PATH=$HOME/.nodebrew/current/bin:$PATH

alias mduch='sh $HOME/shellfiles/touch_mkdir.sh'

export ANDROID_HOME=$HOME/Library/Android/sdk 
export PATH=$PATH:$ANDROID_HOME/emulator 
export PATH=$PATH:$ANDROID_HOME/platform-tools

export PATH="$PATH:`yarn global bin`"

export PATH="$PATH:$HOME/development/flutter/bin"
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"
export RUBY_CONFIGURE_OPTS="--with-openssl-dir=$(brew --prefix openssl@1.1)"

# aliases
alias g='git'
alias ls='eza'
alias ll='ls -l'
alias cat='bat'
alias gl='g log --oneline'

## [Completion]
## Completion scripts setup. Remove the following line to uninstall
[[ -f /Users/nozomeme/.dart-cli-completion/zsh-config.zsh ]] && . /Users/nozomeme/.dart-cli-completion/zsh-config.zsh || true
## [/Completion]

