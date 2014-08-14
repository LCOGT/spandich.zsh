#!/usr/bin/env zsh

SELF=${0:a}

LCOGT_DOMAIN=lco.gtn

function vilcogt() {
  vi "${SELF}" && source "${SELF}"
}
