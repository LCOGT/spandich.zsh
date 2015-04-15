#!/usr/bin/env zsh

export PAGER=most

export LCOGT_DOMAIN=lco.gtn
export LCO_ROOT=/lco
export LCO_CONFIG_ROOT="${LCO_ROOT}/etc/tcs"
alias tcs="cd ${LCO_CONFIG_ROOT}"

export SITE_BPL="${LCO_CONFIG_ROOT}/bpl"
export SITE_NAME_BPL="Back Parking Lot (Santa Barbara)"
alias bpl="cd ${SITE_BPL}"

export SITE_COJ="${LCO_CONFIG_ROOT}/coj"
export SITE_NAME_COJ="Siding Spring (Australia)"
alias coj="cd ${SITE_COJ}"

export SITE_CPT="${LCO_CONFIG_ROOT}/cpt"
export SITE_NAME_CPT="Sutherland (Capetown)"
alias cpt="cd ${SITE_CPT}"

export SITE_ELP="${LCO_CONFIG_ROOT}/elp"
export SITE_NAME_ELP="McDonald (El Paso)"
alias elp="cd ${SITE_ELP}"

export SITE_LSC="${LCO_CONFIG_ROOT}/lsc"
export SITE_LSC="Cerro Tololo (Chile)"
alias lsc="cd ${SITE_LSC}"

export SITE_OGG="${LCO_CONFIG_ROOT}/ogg"
export SITE_NAME_OGG="Haleakala (Hawaii)"
alias ogg="cd ${SITE_OGG}"

export SITE_SQA="${LCO_CONFIG_ROOT}/sqa"
export SITE_NAME_SQA="Sedgewick Reserve (Santa Ynez)"
alias sqa="cd ${SITE_SQA}"

export SITE_TUS="${LCO_CONFIG_ROOT}/tus"
export SITE_NAME_TUS="Tuscon"
alias tus="cd ${SITE_TUS}"

alias vihosts='sudo vi /etc/hosts'

alias cr='crucible.py'

function vilcogt() {
  SELF=${ZSH_CUSTOM_COMMON_DIR}/_lcogt.zsh
  vi "${SELF}" && source "${SELF}"
}

function reset-taskbar() {
  killall -9 unity-panel-service
  nohup unit-panel-service &> /dev/null &
}

alias more=most
alias srv='sudo service'
alias dfc='dfc -T -ug -W -t ext,ext2,ext3,ext4,nfs'
alias mysqladmin='sudo mysqladmin'
alias virc='vi ~/.zshrc'
alias vienv='vi ~/.zshenv'
alias mkdir='mkdir -p'

function pkill() {
    =pkill $@
    echo $?
}


function kindkill() {
    if [ $# -eq 0 ]; then
        echo "Usage: ${0} arguments"
    fi
    echo SIGTERM
    pgrep $@ && pkill --signal SIGTERM $@
    sleep 1
    echo SIGKILL
    pgrep $@ &&  pkill --signal SIGKILL $@
}

function dpkg-list() {
    COLUMNS=$(tput cols) dpkg -l | less
}

function pslist() {
    ps -f --pid $(pgrep "$@" | sort -n | paste -d, -s) | awk '{ s = sprintf("%6d", $3); s = s " -> " sprintf("%6d", $2); s = s " " sprintf("%9s    ", $1); for (i = 8; i <= NF; i++) s = s " " $i; print s "\n" }' | less --clear-screen --quit-at-eof --quit-if-one-screen --pattern="$@" --silent --window=-2 --tilde --hilite-search --max-back-scroll=1000 --long-prompt --hilite-unread
}


function listeners() {
    if [ $# -gt 1 ]; then
        echo "Usage: $0 [ pattern ]"
        return
    fi

    if [ $# -eq 1 ]; then
        local pattern=$1
        local process=$(pgrep -f "${pattern}" | head -n 1)
        if [ -n "${process}" ]; then
            lsof -p ${process} -P -a -sTCP:LISTEN -iTCP
        fi
    else
        lsof -nP -iTCP -sTCP:LISTEN
    fi
}

function _include() {
  if [ $# -eq 0 ]; then
    echo "Usage: ${0} package ..."
    return
  fi

  for package in $@; do
    source ${ZSH_CUSTOM_COMMON_DIR}/${package}.zsh
  done
}
function find-latest() {
  find ${1:=.} -type f | xargs stat --format '%Y :%y %n' | sort -nr | cut -d: -f2- | head -n ${2:=25}
}

function ssh-command-login() {
  if [ $# -lt 2 ]; then
    echo "Usage: ${0} hostname command ..."
    return
  fi
  host=$1; shift

  ssh ${host} -t '${SHELL} -l -c "'${@}'"'
}

function psgrep() {
  ps -ef | grep -iE $@ | grep -v grep -i -E
}

function feedbackIndicator() {
  if [ $# -ne 3 ]; then
    echo "Usage: ${0} message color blink_count"
    return
  fi
  local message=${1}; shift
  local color=${1}; shift
  local blink_count=${1}; shift

  blink1-tool ${color} --blink ${blink_count} &> /dev/null &
  say "${message}"
}

function withFeedback() {
  ((eval $@) && (feedbackIndicator success --green 5)) || (feedbackIndicator failure --red 5)
}

alias md2mw='pandoc --from=markdown --to=mediawiki'

function md2mwpb() {
    md2mw $@ | xclip -selection clipboard
}

function own() {
    sudo chown --dereference -HR ${USER}:10000 $@
}

function speak() {
    [ "${SPEAK-0}" -ne 0 ] || return 0
    say "$@"
}

alias docker=docker.io

function lssbig() {
    ls -l $(lsusb | grep 'SBIG' | cut -d: -f1 | awk '{ print "/dev/bus/usb/"$2"/"$4 }')
}

function zshnew() {
    if [ $# -ne 1 ]; then
        echo "Usage: ${0} script_name" > /dev/stderr
        return
    fi

    local script="${1}"; shift
    
    if [ -a "${script}" ]; then
        echo "Error: ${script} already exists." > /dev/stderr
        return
    fi

    echo "#!/usr/bin/env zsh\n\n" > "${script}"
    chmod u+x "${script}"
    vi +$ "${script}"
}

function taillco() {
    multitail --mergeall --no-repeat --mark-interval 60 --follow-all -T -du -mb 10MB --mark-change --retry-all --basename -Q 5 "/lco/log/*"
    stty sane
}

function vifiles() {
    vi *(.) *(@)
}

alias ports='sudo netstat -nlutp'
