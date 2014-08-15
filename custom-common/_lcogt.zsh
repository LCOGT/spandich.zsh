#!/usr/bin/env zsh

LCOGT_DOMAIN=lco.gtn

function vilcogt() {
  SELF=${ZSH_CUSTOM_COMMON_DIR}/_lcogt.zsh
  vi "${SELF}" && source "${SELF}"
}

alias reset-taskbar='killall unity-panel-service'

function find-latest() {
  find ${1:=.} -type f | xargs stat --format '%Y :%y %n' | sort -nr | cut -d: -f2- | head -n ${2:=25}
}

alias mci='maven clean install'

function svnignore-all() {
  if [ $# -ne 1 ]; then
    echo "Usage: ${0} fitler"
    return
  fi

  local filter="${1}"; shift

  for dir in $(find . -name "${filter}" | xargs -L1 dirname); do
    figlet "${dir}"
    (svn propget svn:ignore ${dir} | grep -v "${filter}" | awk NF ; echo "${filter}") |  svn propset  --non-interactive -F - svn:ignore ${dir}
    svn propget svn:ignore ${dir}
    echo
    echo
  done
}

function ssh-command-login() {
  if [ $# -lt 2 ]; then
    echo "Usage: ${0} hostname command ..."
    return
  fi
  host=$1; shift

  ssh ${host} -t '${SHELL} -l -c "'${@}'"'
}
