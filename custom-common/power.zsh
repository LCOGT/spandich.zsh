#!/usr/bin/env zsh

outlet_command='1.3.6.1.4.1.318.1.1.12.3.3.1.1.4'

function vipower() {
  SELF=${ZSH_CUSTOM_COMMON_DIR}/power.zsh
  vi "${SELF}" && source "${SELF}"
}

function _power_print_state() {
    local outlet="${1}"; shift
    local device="${1}"; shift
    local state_name="${1}"; shift
    printf "[%.2d] %-20s: %s\n" "${outlet}" "${device}" "${state_name}"
}

function power_device_list() {

    for device in ${(@k)POWER_DEVICES}; do; printf "%.2d %s\n" "${POWER_DEVICES[${device}]}" "${device}"; done | sort -n | cut -d' ' -f2
}

function power_lookup_device() {
    source "${ZSH_CUSTOM_COMMON_DIR}/../power_env.zsh"

    if [ $# -ne 1 ]; then
        echo "Usage: ${0} outlet_number"
        return
    fi

    local outlet="${1}"; shift
    local device="${POWER_OUTLETS[${outlet}]}"

    echo "${device}"
}

function power_lookup_outlet() {
    source "${ZSH_CUSTOM_COMMON_DIR}/../power_env.zsh"

    if [ $# -ne 1 ]; then
        echo "Usage: ${0} device_name"
        return
    fi

    local device="${1}"; shift
    local outlet="${POWER_DEVICES[${device}]}"

    echo "${outlet}"
}

function power_device_get_state() {
    source "${ZSH_CUSTOM_COMMON_DIR}/../power_env.zsh"

    local devices
    typeset -a devices
    if [ $# -eq 0 ]; then
        devices=( $(power_device_list) )
    else
        devices=( $@ )
    fi

    for device in ${devices}; do
        outlet="$(power_lookup_outlet "${device}")"
         if [ -z "${outlet}" ]; then
            state_name='UNKNOWN'
        else
            local state=$(snmpget -v 1 -c "${POWER_USER}" "${POWER_ADDRESS}" "${outlet_command}.${outlet}" | sed 's/^.\+INTEGER: //')

            state_name='OFF'
            [ "${state}" -eq 2 ] || state_name='ON'
        fi

        _power_print_state "${outlet}" "${device}" "${state_name}"
    done
}

function power_state() {
    source "${ZSH_CUSTOM_COMMON_DIR}/../power_env.zsh"

    if [ $# -ne 2 ]; then
        echo "Usage: ${0} device_name (on|off)"
        return
    fi

    local device="${1}"; shift
    local state_name="${1}"; shift
    if [ "${state_name}" != 'on' ] && [ "${state_name}" != 'off' ]; then
        echo "Error: invalid state '${state_name}'. Must be one of 'off', 'on'."
        return
    fi

    local state=2
    [ "${state_name}" == 'off' ] || state=1

    local outlet="$(power_lookup_outlet ${device})"
    if [ -z "${outlet}" ]; then
        echo "Error: no such device '${device}'."
        return
    fi
    
    snmpset -v 1 -c "${POWER_USER}" "${POWER_ADDRESS}" "${outlet_command}.${outlet}" i "${state}" > /dev/null

    local state_name='OFF'
    [ "${state}" -eq 2 ] || state_name='ON'
    _power_print_state "${outlet}" "${device}" "${state_name}"
}

functon power() {
    source "${ZSH_CUSTOM_COMMON_DIR}/../power_env.zsh"

    if [ $# -ne 1 ] && [ $# -ne 2 ]; then
        echo "Usage: ${0} device_name [on|off]"
        return
    fi

    local device="${1}"; shift

    if [ $# -eq 0 ]; then
        power_device_get_state "${device}"
        return
    fi

    local state_name="${1}"; shift
    power_device_set_state "${device}" "${state_name}"
}

