#!/usr/bin/env zsh
  
function vitst() {
  SELF=${ZSH_CUSTOM}/site_tst.zsh
  vi "${SELF}" && source "${SELF}"
}

typeset -a PACKAGES
PACKAGES=(
  libccd
  instrument-agent
)

alias hibernate='mysql --user=hibernate --password=hibernate hibernate'
alias harvest='mysql --user=hibernate --password=hibernate harvest'

export LCO_HOME=/lco
export SITE_TST_HOME=${LCO_HOME}/etc/tcs/tst

alias tst-site-start="${SITE_TST_HOME}/run/runSite.sh"
alias tst-site-stop="${SITE_TST_HOME}/run/runSite.sh -s"
alias tst-inst-start="${SITE_TST_HOME}/run/runInstruments.sh -u heaterpower-SNAPSHOT doma 1m0a"
alias tst-inst-restart="pkill -f Instrument ; =rm -rf ${LCO_HOME}/log/*; clear ; tst-inst-start"

function tst-diag-tt-status-core() {
  watch "curl --silent http://tt/cgi-bin/status\?out\=json | python -mjson.tool | grep -v original | grep -E -A 8  '(CCD|Cryo).*(Temperature|Heater)' | grep -E '"(name|value)"' | grep -E -A1 'CCD|Cryo' | awk '1;!(NR%2){print \"\";}'"
}

alias tst-diag-inst-usb="sudo tshark -i usbmon1 -V -R 'usb.idVendor == 0x04b4 && usb.idProduct == 0x1000'"

function tst-tail() {
  multitail --follow-all --retry-all --mergeall ${LCO_HOME}/log/*
}

function tst-tmux() {
  if [ $# -ne 1 ]; then
    echo "Usage: ${0} session-name"
    return
  fi
  local session_name=${1} ; shift

  local exists=$(tmux list-sessions | grep ${session_name} | wc -l )
  if [ ${exists} -eq 0 ]; then
    ${ZSH_CUSTOM}/support/tmux/${session_name}.tmux
  else
    tmux a -t ${session_name}
  fi
}

alias tst-tmux-bottom='tst-tmux tst-bottom'
alias tst-tmux-top='tst-tmux tst-top'

function tst-build() {
  withFeedback 'z ccd && mvn clean install && z ia && mvn clean install' 
}

function tst-tail-dbhost-value() {
  if [ $# -ne 1 ]; then
    echo "Usage: ${0} name"
    return
  fi

  local name=${1}; shift

  local identifier=$(echo "select IDENTIFIER from PROPERTY where ADDRESS_DATUM = '${name}'" | mysql --silent --host=dbhost --user=hibernate --password=hibernate hibernate)

  if [ -z "${identifier}" ]; then
    echo "Error: no identifier found for: '${name}'"
    return
  fi

  echo "${name} -> ${identifier}"
  
  ssh dbhost sudo "tail -F /tmp/mysql_query.log | grep ${identifier} | sed 's/[ ]\+/ /g' | cut -d' ' -f4- |  python -c 'import sys;import sqlparse;print sqlparse.format(sys.stdin.read(),  reindent=True)' | grep -A 10 ${identifier} | paste -d' ' -s | cut -d, -f5 | cut -d\' -f2"
}

function _tst-build-64() {
  if [ $# -gt 1 ]; then
    echo "Usage: ${0} [ branch ]"
    return
  fi

  local subpath
  if [ $# -eq 1 ]; then
    subpath="branches/${1}"
  else
    subpath="trunk"
  fi

  for package in ${PACKAGES}; do
    ssh-command-login build64 \
        cd ${USER} '&&' \
        rm -rf ${package} '&&' \
        svn co http://versionsba/svn/telsoft/Lco/${package}/${subpath} ${package} '&&' \
        cd ${package} '&&' \
        mvn clean deploy
  done
}

function tst-build-64() {
  withFeedback _tst-build-64 $@
}

alias tst-build-all='tst-build && tst-build-63'
