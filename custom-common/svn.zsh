#!/usr/bin/env zsh

SVN_SERVER=versionsba.${LCOGT_DOMAIN}
SVN_ROOT=/svn/telsoft/Lco

function ai() {
  SELF=${ZSH_CUSTOM_COMMON_DIR}/svn.zsh
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
  [ "${branch}" == 'trunk' ] || branch="branches/${branch}"
  svn co http://${SVN_SERVER}${SVN_ROOT}/${project}/${branch} ${project}
}

alias svns='svn status'

function svnlogme() {
  svn log $@ | grep -B2 ${USER} | sed '/^-\+/d' | paste - - -d:
}

function svnmerge() {
  if [ $# -lt 1 ]; then
    echo "Usage: ${0} target_revision [ path ... ]"
    return
  fi
  revision=${1}; shift
  svn merge -r${revision}:$(svn info | grep '^Revision' | cut -d' ' -f2) $(svn info | grep '^URL' | cut -d' ' -f2) $@
}
