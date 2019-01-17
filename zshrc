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

  alias o='open'
  alias dotshow="defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder"
  alias dothide="defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder"

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

inline-ls() {
    zle push-line
    BUFFER=" ls"
    zle accept-line
}
zle -N inline-ls
bindkey '^l' inline-ls

# automatically escape parsed urls
autoload -U url-quote-magic
if [[ $+functions[_zsh_highlight] == 1 ]]; then
    function _url-quote-magic() { url-quote-magic; _zsh_highlight }
    zle -N self-insert _url-quote-magic
else
    zle -N self-insert url-quote-magic
fi


# alt + arrows
bindkey "^[[1;9C" forward-word # alt+ ->
bindkey "^[[1;9D" backward-word # alt + <-

# line magic
bindkey '^a' beginning-of-line
bindkey '^e' end-of-line
bindkey '^k' kill-line
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

alias sha1='openssl sha1'

ialias h='history'
ialias hs='history | grep'
ialias j='jobs -l'

ialias path='echo -e ${PATH//:/\\n}'
alias now='date +"%T"'
alias nowtime=now
alias nowdate='date +"%d-%m-%Y"'


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
alias cd..='cd ..'
alias cd~='cd ..'

ialias rd='rmdir'
ialias md='mkdir'

ialias cpu='htop -o cpu'
ialias mem='htop -o rsize'

ialias tmp='cd /tmp'


# apt
alias apt-get='sudo apt-get'
alias apt='sudo apt'
alias update='sudo apt-get update && sudo apt-get upgrade'

# reboot / halt / poweroff
alias reboot='sudo reboot'
alias poweroff='sudo poweroff'
alias halt='sudo halt'
alias shutdown='sudo shutdown'

## pass options to free ##
alias meminfo='free -m -l -t'
 
## get top process eating memory
alias psmem='ps auxf | sort -nr -k 4'
alias psmem10='ps auxf | sort -nr -k 4 | head -10'
 
## get top process eating cpu ##
alias pscpu='ps auxf | sort -nr -k 3'
alias pscpu10='ps auxf | sort -nr -k 3 | head -10'
 
# wget -c(ontinue)
alias wget='wget -c'

alias dirsize='du -Sh | sort -rh'
alias filesize='find -type f -exec du -Sh {} + | sort -rh'
alias partusage='df -hlT --exclude-type=tmpfs --exclude-type=devtmpfs'


alias c='clear'
alias x='exit'

# get random BOFH excuse
function bofh() {
    telnet towel.blinkenlights.nl 666
}

alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# tmux
alias tn='tmux new-session -s'
alias ta='tmux attach -t'
alias tl='tmux ls'
alias tk='tmux kill-session -s'


extract () {
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)  tar xjf $1    ;;
      *.tar.gz) tar xzf $1    ;;
      *.bz2)    bunzip2 $1    ;;
      *.rar)    rar x $1    ;;
      *.gz)   gunzip $1   ;;
      *.tar)    tar xf $1   ;;
      *.tbz2)   tar xjf $1    ;;
      *.tgz)    tar xzf $1    ;;
      *.zip)    unzip $1    ;;
      *.Z)    uncompress $1 ;;
      *)      echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}


alias ip="ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p'"
alias ippub='curl ipinfo.io/ip'
alias dnspub='curl ipinfo.io/hostname'

ialias rank="sort | uniq -c | sort -n"

ialias chrome="open -a \"Google Chrome\""


setopt CORRECT




ialias find='noglob find'
ialias history='noglob history'
ialias locate='noglob locate'
ialias rsync='noglob rsync'
ialias scp='noglob scp'


ialias cp='nocorrect cp'
ialias mv='nocorrect mv'



# ls
if is-callable 'dircolors'; then
  # GNU Core Utilities

  if zstyle -T ':prezto:module:utility:ls' dirs-first; then
    alias ls="${aliases[ls]:-ls} --group-directories-first"
  fi

  if zstyle -t ':prezto:module:utility:ls' color; then
    # Call dircolors to define colors if they're missing
    if [[ -z "$LS_COLORS" ]]; then
      if [[ -s "$HOME/.dir_colors" ]]; then
        eval "$(dircolors --sh "$HOME/.dir_colors")"
      else
        eval "$(dircolors --sh)"
      fi
    fi

    alias ls="${aliases[ls]:-ls} --color=auto"
  else
    alias ls="${aliases[ls]:-ls} -F"
  fi
else
  # BSD Core Utilities
  if zstyle -t ':prezto:module:utility:ls' color; then
    # Define colors for BSD ls if they're not already defined
    if [[ -z "$LSCOLORS" ]]; then
      export LSCOLORS='exfxcxdxbxGxDxabagacad'
    fi

    # Define colors for the completion system if they're not already defined
    if [[ -z "$LS_COLORS" ]]; then
      export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=36;01:cd=33;01:su=31;40;07:sg=36;40;07:tw=32;40;07:ow=33;40;07:'
    fi

    alias ls="${aliases[ls]:-ls} -G"
  else
    alias ls="${aliases[ls]:-ls} -F"
  fi
fi

# alias
ialias ls='ls --color=auto'
ialias ll='ls -al --color=auto'
ialias ltr='ls -altr --color=auto'
alias l.='ls -d .* --color=auto'


alias l='ls -1A'         # Lists in one column, hidden files.
alias ll='ls -lh'        # Lists human readable sizes.
alias lr='ll -R'         # Lists human readable sizes, recursively.
alias la='ll -A'         # Lists human readable sizes, hidden files.
alias lm='la | "$PAGER"' # Lists human readable sizes, hidden files through pager.
alias lx='ll -XB'        # Lists sorted by extension (GNU only).
alias lk='ll -Sr'        # Lists sorted by size, largest last.
alias lt='ll -tr'        # Lists sorted by date, most recent last.
alias lc='lt -c'         # Lists sorted by date, most recent last, shows change time.
alias lu='lt -u'         # Lists sorted by date, most recent last, shows access time.
ialias sl='ls'            # I often screw this up.


# color grep
export GREP_COLOR='37;45'           # BSD.
export GREP_COLORS="mt=$GREP_COLOR" # GNU.

ialias grep="${aliases[grep]:-grep} --color=auto"

# Resource Usage
alias df='df -kh'
alias du='du -kh'




# local zshrc
test -e "${HOME}/.zshrc.local" && source "${HOME}/.zshrc.local"


