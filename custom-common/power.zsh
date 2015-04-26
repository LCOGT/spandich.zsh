#!/usr/bin/env zsh

power_command_state='1.3.6.1.4.1.318.1.1.12.3.3.1.1.4'
power_command_list='iso.3.6.1.4.1.318.1.1.12.3.5.1.1.2'

typeset -A POWER_OUTLETS
export POWER_OUTLETS

typeset -A POWER_DEVICES
export POWER_DEVICES

typeset -a POWER_DEVICE_NAMES
export POWER_DEVICE_NAMES

if [ -n "${ZSH_CUSTOM_COMMON_DIR}" ]; then
function vipower() {
  SELF=${ZSH_CUSTOM_COMMON_DIR}/power.zsh
  vi "${SELF}" && source "${SELF}"
}
fi

function power_reset() {
    POWER_OUTLETS=()
    POWER_DEVICES=()
    POWER_DEVICE_NAMES=()
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

    power_reset
    for line in $(snmpwalk -v 1 -c "${POWER_COMMUNITY}" "${POWER_ADDRESS}" "${power_command_list}" | sed s'/^.\+\.\([0-9]\+\) = STRING: "\(.\+\)"$/\1 \2/'); do
        local outlet="$(echo "${line}" | cut -d' ' -f1)"
        local device="$(echo "${line}" | cut -d' ' -f2-)"
        POWER_OUTLETS+=("${outlet}" "${device}")
        POWER_DEVICES+=("${device}" "${outlet}")
        POWER_DEVICE_NAMES+=("${device}")
    done

    IFS=$"{$ifs_save}"
}

function _power_print_state() {
    local outlet="${1}"; shift
    local device="${1}"; shift
    local state_name="${1}"; shift
    printf "[%.2d] %-20s: %s\n" "${outlet}" "${device}" "${state_name}"
}

function power_help() {
    echo "APC PDU Power Commands"
    echo
    echo "Commands:"
    echo "  power_reset                                     -- clear the device/outlet cache"
    echo "  power_lookup_device outlet_number               -- lookup device by outlet number"
    echo "  power_lookup_outlet device_name                 -- lookup outlet by device name"
    echo "  power_device_get_state [ device_name ... ]      -- get the ON/OFF state of one or more devices (default = ALL)"
    echo "  power_device_set_state device_name (on|off)     -- set the (immediate) power state of a device"
    echo
    echo "Shortcuts:"
    echo "  power device_name                               -- equivalent to: power_device_get_state device_name"
    echo "  power device_name (on|off)                      -- equivalent to: power_device_set_state device_name (on|off)"
    echo "  outlet device_name                              -- equivalent to: power_lookup_outlet device_name"
    echo
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

function power_device_get_state() {
    _power_init

    local devices
    typeset -a devices
    if [ $# -eq 0 ]; then
        devices=()
        local ifs_save=$"${IFS}"
        IFS=$'\n'
        for device in ${POWER_DEVICE_NAMES}; do
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

alias outlet=power_lookup_outlet
