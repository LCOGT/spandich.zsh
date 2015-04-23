#!/usr/bin/env zsh

function vipower() {
  SELF=${ZSH_CUSTOM_COMMON_DIR}/power.zsh
  vi "${SELF}" && source "${SELF}"
}

function power_get_device() {
    source "${ZSH_CUSTOM_COMMON_DIR}/../power_env.zsh"

    if [ $# -ne 1 ]; then
        echo "Usage: ${0} outlet_number"
    fi

    local outlet="${1}"; shift
    local device="${POWER_OUTLETS[${outlet}]}"

    echo "${device}"
}

function power_get_outlet() {
    source "${ZSH_CUSTOM_COMMON_DIR}/../power_env.zsh"

    if [ $# -ne 1 ]; then
        echo "Usage: ${0} device_name"
    fi

    local device="${1}"; shift
    local outlet="${POWER_DEVICES[${device}]}"

    echo "${outlet}"
}
