#!/bin/zsh

alias ls='ls -bGh --color=auto'
alias gist='gist --private --shorten --open'
alias rscp='rsync -Pazv -e ssh'
alias z=wd
alias l='ls -lah'           # Long view, show hidden
alias la='ls -AF'           # Compact view, show hidden
alias ll='ls -lFh'          # Long view, no hidden
alias visc='vi ~/.ssh/config'

function root() {
  [ ${UID} -ne 0 ] || return
  sudo su -
}

function lw {
  for f in $@; do
    ls -l $(which $f)
  done
}

alias history='history 100'
alias h='history'
function hgrep { history | grep $* }

alias grep='grep --color=auto'

alias df='df -h'
alias du='du -h -c'

alias vi='vim -lN'

alias lines='find $(ls -d **/src/main) \( -name \*.groovy -o -name \*.java \) -type f | xargs wc -l | tail -n 1'

alias vifail='vi $(=grep -sZl FAILURE **/(surefire|failsafe)-reports/*.txt)'

function extract () {
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2)        tar xjf $1        ;;
            *.tar.gz)         tar xzf $1        ;;
            *.bz2)            bunzip2 $1        ;;
            *.rar)            unrar x $1        ;;
            *.gz)             gunzip $1         ;;
            *.tar)            tar xf $1         ;;
            *.tbz2)           tar xjf $1        ;;
            *.tgz)            tar xzf $1        ;;
            *.zip)            unzip $1          ;;
            *.Z)              uncompress $1     ;;
            *)                echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

function mcd () {
  mkdir -p "$@" && cd "$@"
}


function sshah {
  if [[ "$1" =~ '@' ]]; then
   user=${1%%@*}
   host=${1##*@}
  else
   user=$USER
   host=$1
  fi

  if [ ! -f ~/.ssh/id_rsa.pub ]; then
    ssh-keygen -t rsa
  fi

  if [ ! -f ~/.ssh/id_rsa.pub ]; then
    die 'could not find public key'
  fi

  cat ~/.ssh/id_rsa.pub | ssh "${user}@${host}" 'mkdir -p .ssh && cd .ssh && touch authorized_keys && chmod 600 authorized_keys && cat >> authorized_keys'
}

function check-status-dir {
  for dir in $@; do
    [ -d ${dir}/.hg ] || return
    echo ${dir}:
    (cd ${dir} && cd $(hg root) && hg status && hg out)
    echo
  done
}

function check-status-basedir {
  basedir=$1; shift
  (
    cd ${basedir}
    for dir  in *(^.); do;
      check-status-dir ${dir}
    done
  )
}

function check-status {
  for basedir in $@; do
    check-status-basedir ${basedir}
  done
}
