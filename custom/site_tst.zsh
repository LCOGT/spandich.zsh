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

function tst-tail() {
  multitail --mergeall $(ls -1 ${LCO_HOME}/log/*(.) ${LCO_HOME}/log/*(@))
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
