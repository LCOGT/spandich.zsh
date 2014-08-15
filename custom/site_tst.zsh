#!/usr/bin/env zsh
  
function vitst() {
  SELF=${ZSH_CUSTOM}/site_tst.zsh
  vi "${SELF}" && source "${SELF}"
}

typeset -a PACKAGES
PACKAGES=(
  instrument-agent
  libccd
)

alias hibernate='mysql --user=hibernate --password=hibernate hibernate'
alias harvest='mysql --user=hibernate --password=hibernate harvest'

export LCO_HOME=/lco
export SITE_TST_HOME=${LCO_HOME}/etc/tcs/tst

alias tst-site-start="${SITE_TST_HOME}/run/runSite.sh"
alias tst-site-stop="${SITE_TST_HOME}/run/runSite.sh -s"
alias tst-inst-start="${SITE_TST_HOME}/run/runInstruments.sh -u heaterpower-SNAPSHOT doma 1m0a"

function tst-diag-tt-status-core() {
  watch "curl --silent http://tt/cgi-bin/status\?out\=json | python -mjson.tool | grep -v original | grep -E -A 8  '(CCD|Cryo).*(Temperature|Heater)' | grep -E '"(name|value)"' | grep -E -A1 'CCD|Cryo' | awk '1;!(NR%2){print \"\";}'"
}

alias tst-diag-inst-usb="sudo tshark -i usbmon1 -V -R 'usb.idVendor == 0x04b4 && usb.idProduct == 0x1000'"

function tst-tail() {
  multitail --mergeall $(ls -1 ${LCO_HOME}/log/*(.) ${LCO_HOME}/log/*(@))
}

function tst-tmux-bottom() {
  local exists=$(tmux list-sessions | grep tst-bottom | wc -l )
  if [ ${exists} -eq 0 ]; then
    ${ZSH_CUSTOM}/support/tmux/tst-bottom.tmux
  else
    tmux a -t tst-bottom
  fi
}

function tst-build() {
  (
    z ccd && mvn clean install &&
    z ia && mvn clean install &&
    z ssb && mvn clean install &&
    z ssb && mvn clean install &&
    z gwt && mvn clean install &&
    say done
  ) || say failed
}

function tst-build-64() {
  cd ${WORKSPACE} && rscp --exclude target/ ${PACKAGES} build64:${USER}/ || return 1

  for package in ${PACKAGES}; do
    ssh-command-login build64 cd ${USER}/${package} '&&' mvn clean deploy
  done
}
