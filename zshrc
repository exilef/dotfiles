#
# Executes commands at the start of an interactive session.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

# detect os
if [[ `uname` == 'Linux' ]]; then
  export OS=linux
elif [[ `uname` == 'Darwin' ]]; then
  export OS=osx
fi

# source prezto
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# post prezto

# linux
if [[ $OS == 'linux' ]]; then
fi

# macos
if [[ $OS == 'osx' ]]; then
  test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

  # macos alt + arrows
  bindkey "^[[1;9D" backward-word # alt + <-
  bindkey "^[[1;9C" forward-word # alt+ ->

  zstyle ':prezto:module:tmux:iterm' integrate 'yes'
fi

# local zshrc
test -e "${HOME}/.zshrc.local" && source "${HOME}/.zshrc_local"
