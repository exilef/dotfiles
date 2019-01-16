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

  zstyle ':prezto:module:tmux:iterm' integrate 'yes'

  export PATH=/usr/local/opt/gnu-sed/libexec/gnubin:/usr/local/bin:${PATH}
fi


function cs() { 
  cd "$1" && ls 
}

function mkcd() { 
  mkdir -p "$1" && cd "$1"
}

insert-root-prefix() {
  BUFFER="sudo $BUFFER"
  CURSOR=$(($CURSOR + 5))
}
zle -N insert-root-prefix
bindkey '^s' insert-root-prefix

# usage: *(o+rand) or *(+rand)
function rand() {
    REPLY=$RANDOM; (( REPLY > 16383 ))
}

function log() {
     echo `date +%Y-%m-%d\ %H:%M:%S`: $*
}

function pass() {
    echo $(cat /dev/urandom | tr -dc '!@#$%^&_?0-9a-zA-Z' | head -c$1)
}

# alt + arrows
bindkey "^[[1;9C" forward-word # alt+ ->
bindkey "^[[1;9D" backward-word # alt + <-

# line magic
bindkey '^a' beginning-of-line
bindkey '^e' end-of-line
bindkey '^k' kill-line
bindkey '^l' inline-ls
bindkey '^o' get-line
bindkey '^p' push-line-or-edit
bindkey "^v" copy-earlier-word
bindkey '^h' run-help
bindkey '^t' undo

# for backward-kill, all but / are word chars (ie, delete word up to last directory)
zstyle ':zle:backward-kill-word*' word-style standard
zstyle ':zle:*kill*' word-chars '*?_-.[]~=&;!#$%^(){}<>'

# word deletion
tcsh-backward-delete-word () {
  local WORDCHARS="${WORDCHARS:s#/#}"
  zle backward-delete-word
}
zle -N tcsh-backward-delete-word

tcsh-forward-delete-word () {
  local WORDCHARS="${WORDCHARS:s#/#}"
  zle delete-word
}
zle -N tcsh-forward-delete-word

bindkey '^q' tcsh-backward-delete-word
bindkey '^w' tcsh-forward-delete-word


# fancy aliases
# https://blog.sebastian-daschner.com/entries/zsh-aliases

# blank aliases
typeset -a baliases
baliases=()

balias() {
  alias $@
  args="$@"
  args=${args%%\=*}
  baliases+=(${args##* })
}

# ignored aliases
typeset -a ialiases
ialiases=()
ialiases+=('cd')

ialias() {
  alias $@
  args="$@"
  args=${args%%\=*}
  ialiases+=(${args##* })
}

# functionality
expand-alias-space() {
  [[ $LBUFFER =~ "\<(${(j:|:)baliases})\$" ]]; insertBlank=$?
  if [[ ! $LBUFFER =~ "\<(${(j:|:)ialiases})\$" ]]; then
    zle _expand_alias
  fi
  zle self-insert
  if [[ "$insertBlank" = "0" ]]; then
    zle backward-delete-char
  fi
}
zle -N expand-alias-space

#bindkey " " expand-alias-space
#bindkey -M isearch " " magic-space

# starts one or multiple args as programs in background
background() {
  for ((i=2;i<=$#;i++)); do
    ${@[1]} ${@[$i]} &> /dev/null &
  done
}


# alias
ialias ll='ls -al'

alias g='git'
alias ga='git add'
alias gr='git rm'
alias gn='git mv'
alias gra='git remote add'
alias gf='git fetch'
alias gs='git status'
alias gc='git commit'
alias gl='git pull'
alias gp='git push'

# git diff
alias gd='git diff'
alias gds='git diff --staged'
alias gdn='git diff --name-only'

# git status
alias gs='git status --short'
alias gss='git show --word-diff=color'

ialias ..='cd ..'
ialias /='cd /'
ialias ~='cd ~'

ialias rd='rmdir'
ialias md='mkdir'

ialias cpu='htop -o cpu'
ialias mem='htop -o rsize'

ialias tmp='cd /tmp'



# local zshrc
test -e "${HOME}/.zshrc.local" && source "${HOME}/.zshrc.local"
