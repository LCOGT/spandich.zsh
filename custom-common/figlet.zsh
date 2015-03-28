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
  for font in $(figlist | grep -B100 'Figlet control files in this directory:' | tail -n +1 | grep -Ev '^Figlet\ control' | sort); do
    echo "figlet -tf $font $*"
    echo ""
    figlet -w 132 -f $font $*
    echo ""
    echo ""
  done
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
