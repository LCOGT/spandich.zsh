#!/usr/bin/env zsh

SELF=${0:a}

SVN_SERVER=versionsba.${LCOGT_DOMAIN}
SVN_ROOT=/svn/telsoft/Lco

function ai() {
  sudo apt-get install $@
}

function visvn() {
  vi "${SELF}" && source "${SELF}"
} 

function svndiff() {
  svn diff --git $@ | vimdiff -R -
}

function svnco() {
  if [ $# -ne 1 ] && [ $# -ne 2 ]; then
    echo "Usage: ${0} project_name [ branch ]"
    return
  fi

  local project=${1}; shift
  local branch=${1:=trunk}; shift
  svn co http://${SVN_SERVER}${SVN_ROOT}/${project}/${branch} ${project}
}

alias svns='svn status'

function svnlogme() {
  svn log $@ | grep -B2 ${USER} | sed '/^-\+/d' | paste - - -d:
}
