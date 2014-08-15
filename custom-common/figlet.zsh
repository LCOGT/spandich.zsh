#!/bin/zsh

if [ "$(which figlet)" ]; then

alias figlet='figlet -f nancyj -w 255'

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
  figlet $* | sed 's|^|//  |'
  echo "// $*"
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
