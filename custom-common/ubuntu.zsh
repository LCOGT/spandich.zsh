#!/usr/bin/evn zsh

alias pbcopy='xclip -selection clipboard'
alias pbpaste='xclip -selection clipboard -o'

alias espeak='espeak -a 200 -v mb-us3'
alias say=espeak

function ai3() {
  if [ $# -ne 2 ]; then
    echo "Usage: ${0} repostitory package"
    return
  fi

  repository=$1; shift
  package=$1; shift

  sudo add-apt-repository ${repository} && sudo apt-get update && sudo apt-get install ${package}
}
