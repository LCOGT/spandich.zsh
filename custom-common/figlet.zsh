#!/bin/zsh

if [ "$(which figlet)" ]; then

function vifiglet() {
  SELF=${ZSH_CUSTOM_COMMON_DIR}/figlet.zsh
  vi "${SELF}" && source "${SELF}"
}


function figlet {
    =figlet -f standard -w 255 -k $@
}

function fontbook {
  local directory='/usr/share/figlet'
  if [[ $# -eq 0 || "${1}" == '-d' && $# -lt 3 ]]; then
    echo "Usage: $0 [-d directory] message ..."
    return 1
  fi

  if [ "${1}" == '-d' ]; then
    shift
    directory="$(readlink -f ${1})"; shift
  fi

  echo "Directory=${directory}"
  echo
  echo
  for font in $(figlist -d "${directory}" | grep -v ' '| sort); do
    echo "Font: ${font}"
    echo
    figlet -d "${directory}" -tf $font $*
    echo ""
    echo ""
  done | less
}

function figcom {
    echo '/**'
    figlet $* | sed 's|^| *   |'

    echo " *  $*"
    echo ' */'
}

function figxml {
  echo '<!--'
  figlet $*
  echo '-->'
}

function figpaste {
  figcom $* | pbcopy
}

function figpastexml {
  figxml $* | pbcopy
}


fi
