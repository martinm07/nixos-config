# Lines configured by zsh-newuser-install
HISTFILE=~/.local/state/zshhist
HISTSIZE=1001
SAVEHIST=1000
setopt autocd extendedglob nomatch notify
unsetopt beep
bindkey -v
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/martinm/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

PS1="%F{#e2f9e0}[%* - %F{#6a7569}%D%F{#e2f9e0}] %B%~%b %% "

export PATH="$HOME/.local/bin:$PATH"
