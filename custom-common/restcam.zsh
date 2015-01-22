#!/usr/bin/env zsh

function virestcam() {
    SELF=${ZSH_CUSTOM_COMMON_DIR}/restcam.zsh
    vi "${SELF}" && source "${SELF}"
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

function rc-push-ka05() {
    if [ $# -ne 1 ]; then
        echo "Usage: ${0} jar_alias"
        return
    fi

    local jar_alias=$1; shift
    rc-push apogee bpl aqwa 0m4a 1 ${jar_alias}
}
