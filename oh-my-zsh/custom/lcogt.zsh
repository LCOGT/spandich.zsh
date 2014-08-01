#!/usr/bin/env zsh

SELF=${0:a}

LCOGT_DOMAIN=lco.gtn

WORKSPACE=~/workspace

function vilcogt() {
  vi "${SELF}" && source "${SELF}"
}

alias root='sudo su -'
alias z=wd

alias pbcopy='xclip -selection clipboard'
alias pbpaste='xclip -selection clipboard -o'

function hgrep() {
  history | grep $@
}
