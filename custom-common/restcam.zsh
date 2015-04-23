#!/usr/bin/env zsh

function virestcam() {
    SELF=${ZSH_CUSTOM_COMMON_DIR}/restcam.zsh
    vi "${SELF}" && source "${SELF}"
}

function rc-tail() {
    clear && tail -n 100 -F /lco/log/restcam.log
}

function rc-tail-metrics() {
    clear && rc-tail | grep -E metrics
}

function rc-fetch-fits() {
    local fits_file=/tmp/temp.fits
    local url="http://localhost:8080/api/Imager.FIT?Duration=${1:=0.6}"
    echo "URL=${url}"
    wget "${url}" -O ${fits_file} \
    && (clear ; fitsverify ${fits_file} ; echo -e '\n\n########\n\n' ; fitscheck ${fits_file}) \
    && read \
    && ds9 "${fits_file}"
}

function rc-config-iptables() {
    sudo iptables --flush
    for interface in eth0 lo; do
        sudo iptables -A INPUT -i ${interface} -p tcp --dport 80 -j ACCEPT
        sudo iptables -A INPUT -i ${interface} -p tcp --dport 8080 -j ACCEPT
        sudo iptables -A PREROUTING -t nat -i ${interface} -p tcp --dport 80 -j REDIRECT --to-port 8080
    done
}

function rc-start() {
    local camera=${1:='dummy'}
    z rc && \
    mvn clean install -Dmaven.test.skip && \
    java \
        -Drestcam.initializationLogLevel=DEBUG \
        -Dlogback.configurationFile=common/src/main/assembly/logback.xml \
        -jar ${camera}/target/${camera}-*-SNAPSHOT.jar server ${camera}/src/main/assembly/restcam.yaml
}

function rc-push() {
    if [ $# -ne 6 ]; then
        echo "Usage: ${0} camera site enclosure telescope icc_number jar_alias"
        return
    fi

    local camera=$1; shift
    echo "camera     : ${camera}"

    local site=$1; shift
    echo "site       : ${site}"

    local enclosure=$1; shift
    echo "enclosure  : ${enclosure}"

    local telescope=$1; shift
    echo "telescope  : ${telescope}"

    local icc_number=$1; shift
    echo "icc_number : ${icc_number}"

    local jar_alias=$1; shift
    echo "jar_alias  : ${jar_alias}"

    cd ~/workspace/restcam || (speak failed ; false) || return
    mvn clean install -Dmaven.test.skip -pl common,api-sbig,${camera} || (speak failed ; false) || return
    scp ${camera}/target/${camera}*.jar ${site}-icc${icc_number}:/lco/restcam/lib/restcam.jar.${jar_alias} || (speak failed ; false) || return
    speak done
}

function rc-push-sbig-32() {
    if [ $# -ne 1 ]; then
        echo "Usage: ${0} icc_server"
        return
    fi

    local icc="${1}"; shift
    local lib="libsbigrestcam.so"
    local lib_deploy="/lco/restcam/lib/${lib}"

    z rc
    if ! sbig/build_swig.sh; then
        echo "Error: failed to build library locally: ${lib}"
        return
    fi

    if ! ssh restcam32 cd workspace/restcam \&\& git pull \&\& sbig/build_swig.sh; then
        echo "Error: failed to build library remotely: ${lib}"
        return
    fi

    ssh "${icc}" "${lib_deploy}" "${lib_deploy}.$$"

    scp restcam32:workspace/restcam/sbig/src/main/assembly/root/lib/32/libsbigrestcam.so /tmp/
    scp "/tmp/${lib}" ${icc}:"${lib_deploy}"
    rm "/tmp/${lib}"

    ssh ${icc} sha256sum "${lib_deploy}"
}

function dump_camera_usb() {
  if [ $# -ne 1 ]; then
    echo "Usage: ${0} usb_vendor_id"
    return
  fi

  local vendor_id="${1}"; shift
  
  local bus_id="$(lsusb -d "${vendor_id}:" | cut -d' ' -f2 | sed 's/^0*//')"
  if [ -z "${bus_id}" ]; then
    echo "Error: camera not found." > /dev/stderr
    return
  fi

  local device_id="$(lsusb -s "${bus_id}:" -d "${vendor_id}:" | cut -d' ' -f4 | sed 's/:$//')"
  if [ -z "${device_id}" ]; then
    echo "Error: camera not found." > /dev/stderr
    return
  fi

  local filter=":${bus_id}:${device_id}:"

  local log_file="$(mktemp --suffix=.mon "/tmp/${0}.${bus_id}.${device_id}.XXX")"
  echo "log_file=${log_file}"

  local usb_stream="/sys/kernel/debug/usb/usbmon/${bus_id}u"

  grep -E "${filter}" "${usb_stream}" > "${log_file}" &
  local grep_pid="${1}"

  echo -n 'Hit [enter] when complete: '
  read

  kill "${grep_pid}"

  if [ ! -f "${log_file}" ]; then
    echo "Error: log file does not exist." > /dev/stderr
    return
  fi

  ls -lh "${log_file}"
  wc -l "${log_file}"

  vusb-analyzer "${log_file}" &> /dev/null
}

function find_usb_port() {
    if [ $# -ne 1 ] && [ $# -ne 2 ]; then
        echo "Usage: ${0} vendor_id [ device_id ]"
        return
    fi

    local vendor_id="${1}"; shift
    local device_id=''
    if [ $# -ne 0 ]; then
        device_id="${1}"; shift
    fi

    local bus_and_device="$(lsusb -d "${vendor_id}:${device_id}" | awk '{ print $2" "$4 }' | sed 's/:$//')"
    local bus_id="$(echo "${bus_and_device}" | cut -d' ' -f1 | sed s'/^0//')"
    local device_id="$(echo "${bus_and_device}" | cut -d' ' -f2 | sed 's/^0*//')"
    local port_id="$(lsusb -t | grep -A100 "Bus ${bus_id}" | grep "Dev ${device_id}" | sed 's/^.\+Port \+\([0-9]\+\).*$/\1/')"

    echo "$(echo "${bus_id}" | sed 's/^0*//') ${device_id} ${port_id}"
}

function usb_power_toggle() {
    if [ $# -ne 1 ] && [ $# -ne 2 ]; then
        echo "Usage: ${0} vendor_id [ device_id ]"
        return
    fi

    local result="$(find_usb_port $@)"
    local bus_id="$(echo "${result}" | cut -d' ' -f1)"
    local device_id="$(echo "${result}" | cut -d' ' -f2)"
    local port_id="$(echo "${result}" | cut -d' ' -f3)"

}
