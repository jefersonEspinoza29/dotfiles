#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '
export PATH="/home/jheff/flutter/bin/:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/flutter-sdk/bin:$PATH"
export PATH="$HOME/Android/Sdk/platform-tools:$PATH"
alias infosistem="fastfetch"
alias i="sudo pacman -S "
alias updatep="sudo pacman -Syy && sudo pacman -Syu"
alias updatey="yay -Syy && yay -Syu"