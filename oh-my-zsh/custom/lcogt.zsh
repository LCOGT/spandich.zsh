#!/usr/bin/env zsh

SELF=${0:a}

LCOGT_DOMAIN=lco.gtn

SVN_SERVER=versionsba.${LCOGT_DOMAIN}
SVN_ROOT=/svn/telsoft/Lco

WORKSPACE=~/workspace

function vilcogt() {
  vi "${SELF}" && source "${SELF}"
}

alias root='sudo su -'
alias z=wd

alias pbcopy='xclip -selection clipboard'
alias pbpaste='xclip -selection clipboard -o'

function svnco() {
  if [ $# -ne 1 ]; then
    echo "Usage: ${0} project_name"
    return
  fi

  local project=${1}; shift
  cd "${WORKSPACE}" && svn co http://${SVN_SERVER}${SVN_ROOT}/${project}/trunk ${project}
}


function hgrep() {
  history | grep $@
}
