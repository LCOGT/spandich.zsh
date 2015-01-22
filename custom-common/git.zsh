#!/usr/bin/env zsh


function vigit() {
  SELF=${ZSH_CUSTOM_COMMON_DIR}/git.zsh
  vi "${SELF}" && source "${SELF}"
}


alias gits='git status'
alias gitp='git push'

function gitco() {
    for project in $@; do
        cd ~/workspace && git clone git@github.com:LCOGT/${project}.git
    done
}

function gitdiff() {
    git diff $@ | vimdiff -R -
}

function gitca() {
    git add --all && git commit $@
}
