#!/usr/bin/env zsh

function vidocker() {
  SELF=${ZSH_CUSTOM_COMMON_DIR}/docker.zsh
  vi "${SELF}" && source "${SELF}"
} 

function list_all_volumes() {
    docker ps \
        | awk '{ print $1 }' \
        | grep -v CONTAINER \
        | xargs docker inspect \
        | pcregrep -M '"Volumes": *{[^}]+}' \
        | grep -vE '{|}' \
        | cut -d: -f2- \
        | sed 's/^ *"\(.\+\)",\?$/\1/' \
        | sort -u
}

function docker() {
    local sudo
    [ $EUID -eq 0 ] || sudo='sudo'

    ${sudo} =docker $@
}

function docker-compose() {
    local sudo
    [ $EUID -eq 0 ] || sudo='sudo'

    ${sudo} =docker-compose $@
}

alias dps='docker ps'
alias dpsa='docker ps -a'

function dr() {
    if [ $# -eq 0 ]; then
        echo "Usage: $0 image_name"
        return
    fi

    local image_name="${1}"; shift

    docker run --rm -it $@ registry.lcogt.net/"${image_name}"
}

function drs() {
    if [ $# -eq 0 ]; then
        echo "Usage: $0 image_name"
        return
    fi

    local image_name="${1}"; shift

    docker run --rm -it --entrypoint=/bin/bash $@ registry.lcogt.net/"${image_name}"
}

function docker-discard-all() {
    for c in $(docker ps --all --quiet); do
        docker stop ${c}
        docker rm ${c}
    done
}
