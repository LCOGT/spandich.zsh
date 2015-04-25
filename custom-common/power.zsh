#!/usr/bin/env zsh

power_command_state='1.3.6.1.4.1.318.1.1.12.3.3.1.1.4'
power_command_list='iso.3.6.1.4.1.318.1.1.12.3.5.1.1.2'

typeset -A POWER_OUTLETS
export POWER_OUTLETS

typeset -A POWER_DEVICES
export POWER_DEVICES

function vipower() {
  SELF=${ZSH_CUSTOM_COMMON_DIR}/power.zsh
  vi "${SELF}" && source "${SELF}"
}

function _power_reset() {
    POWER_OUTLETS=()
    POWER_DEVICES=()
}

function _power_init() {
    if [ -z "${POWER_ADDRESS}" ] || [ -z "${POWER_COMMUNITY}" ]; then
        echo "Error: both POWER_ADDRESS and POWER_COMMUNITY must be defined to us the power commands." > /dev/stderr
        return
    fi

    if [ "${#POWER_OUTLETS}" -ne 0 ]; then
        return
    fi

    local ifs_save="${IFS}"
    IFS=$'\n'

    _power_reset
    for line in $(snmpwalk -v 1 -c "${POWER_COMMUNITY}" "${POWER_ADDRESS}" "${power_command_list}" | sed s'/^.\+\.\([0-9]\+\) = STRING: "\(.\+\)"$/\1 \2/'); do
        local outlet="$(echo "${line}" | cut -d' ' -f1)"
        local device="$(echo "${line}" | cut -d' ' -f2-)"
        POWER_OUTLETS+=("${outlet}" "${device}")
        POWER_DEVICES+=("${device}" "${outlet}")
    done

    IFS=$"{$ifs_save}"
}

function _power_print_state() {
    local outlet="${1}"; shift
    local device="${1}"; shift
    local state_name="${1}"; shift
    printf "[%.2d] %-20s: %s\n" "${outlet}" "${device}" "${state_name}"
}

function power_lookup_device() {
    _power_init

    if [ $# -ne 1 ]; then
        echo "Usage: ${0} outlet_number"
        return
    fi

    local outlet="${1}"; shift
    local device="${POWER_OUTLETS[${outlet}]}"

    echo "${device}"
}

function power_lookup_outlet() {
    _power_init

    if [ $# -ne 1 ]; then
        echo "Usage: ${0} device_name"
        return
    fi

    local device="${1}"; shift
    local outlet="${POWER_DEVICES[${device}]}"

    echo "${outlet}"
}

function _power_device_list() {
    _power_init

    for outlet in ${(@k)POWER_OUTLETS}; do
        local device="${POWER_OUTLETS[${outlet}]}"
        printf "%0.2d:%s\n" "${outlet}" "${device}"
    done | sort -n | cut -d: -f2
}

function power_device_get_state() {
    _power_init

    local devices
    typeset -a devices
    if [ $# -eq 0 ]; then
        devices=()
        local ifs_save=$"${IFS}"
        IFS=$'\n'
        for device in $(_power_device_list); do
            devices+=("${device}")
        done
        IFS=$"${ifs_save}"
    else
        devices=( $@ )
    fi

    for device in ${devices[@]}; do
        outlet="$(power_lookup_outlet "${device}")"
         if [ -z "${outlet}" ]; then
            state_name='UNKNOWN'
        else
            local state=$(snmpget -v 1 -c "${POWER_COMMUNITY}" "${POWER_ADDRESS}" "${power_command_state}.${outlet}" | sed 's/^.\+INTEGER: //')

            state_name='OFF'
            [ "${state}" -eq 2 ] || state_name='ON'
        fi

        _power_print_state "${outlet}" "${device}" "${state_name}"
    done
}

function power_device_set_state() {
    _power_init

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
    
    snmpset -v 1 -c "${POWER_COMMUNITY}" "${POWER_ADDRESS}" "${power_command_state}.${outlet}" i "${state}" > /dev/null

    local state_name='OFF'
    [ "${state}" -eq 2 ] || state_name='ON'
    _power_print_state "${outlet}" "${device}" "${state_name}"
}

functon power() {
    _power_init

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

alias power_state=power_device_get_state
alias outlet=power_lookup_outlet
