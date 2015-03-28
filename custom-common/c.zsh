#!/usr/bin/env zsh

function vic() {
  SELF=${ZSH_CUSTOM_COMMON_DIR}/c.zsh
  vi "${SELF}" && source "${SELF}"
}
