#!/usr/bin/env zsh


function vigit() {
  SELF=${ZSH_CUSTOM_COMMON_DIR}/git.zsh
  vi "${SELF}" && source "${SELF}"
}


alias gits='git status'
alias gitp='git push'
