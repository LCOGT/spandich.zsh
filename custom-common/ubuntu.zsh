#!/usr/bin/evn zsh

function viubuntu() {
  SELF=${ZSH_CUSTOM_COMMON_DIR}/ubuntu.zsh
  vi "${SELF}" && source "${SELF}"
}

alias pbcopy='xclip -selection clipboard'
alias pbpaste='xclip -selection clipboard -o'

alias espeak='espeak -a 200 -v mb-us3'
alias say=espeak
alias dlltool=x86_64-w64-mingw32-dlltool
alias lart='ls -lart'
alias al='dpkg -L'

function a

function dlldump() {
  if [ $# -ne 1 ]; then
    echo "Usage: ${0} dll"
    return
  fi

  export dll=$1; shift

  objdump --all-headers ${dll}| grep -A1000 'Ordinal/Name Pointer' | grep -E -B1000 'Base Relocations' | grep -E '\[[[:space:]]*[[:digit:]]+\]' | cut -d] -f2 | sed 's/[[:space:]]//g' | LC_COLLATE=c sort -u
}

function dlldump-gist() {
  if [ $# -ne 1 ]; then
    echo "Usage: ${0} dll"
    return
  fi

  dlldump "${dll}" | gist --private --description "dlldump of ${dll}" --copy --open
}

function ai() {
  sudo apt-get install $@
  rehash
}

function ai3() {
  if [ $# -ne 2 ]; then
    echo "Usage: ${0} repostitory package"
    return
  fi

  repository=$1; shift
  package=$1; shift

  sudo add-apt-repository --yes ${repository} && sudo apt-get update ; sudo apt-get install ${package}
}
