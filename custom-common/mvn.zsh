#!/usr/bin/env zsh

function vimvn() {
  SELF=${ZSH_CUSTOM_COMMON_DIR}/mvn.zsh
  vi "${SELF}" && source "${SELF}"
}

# Formatting constants
export BOLD=`tput bold`
export UNDERLINE_ON=`tput smul`
export UNDERLINE_OFF=`tput rmul`
export TEXT_BLACK=`tput setaf 0`
export TEXT_RED=`tput setaf 1`
export TEXT_GREEN=`tput setaf 2`
export TEXT_YELLOW=`tput setaf 3`
export TEXT_BLUE=`tput setaf 4`
export TEXT_MAGENTA=`tput setaf 5`
export TEXT_CYAN=`tput setaf 6`
export TEXT_WHITE=`tput setaf 7`
export BACKGROUND_BLACK=`tput setab 0`
export BACKGROUND_RED=`tput setab 1`
export BACKGROUND_GREEN=`tput setab 2`
export BACKGROUND_YELLOW=`tput setab 3`
export BACKGROUND_BLUE=`tput setab 4`
export BACKGROUND_MAGENTA=`tput setab 5`
export BACKGROUND_CYAN=`tput setab 6`
export BACKGROUND_WHITE=`tput setab 7`
export RESET_FORMATTING=`tput sgr0`

alias deptree='mvn dependency:tree'

function _mvn-chunk() {
    mvn help:effective-pom | grep -A100 -E '< */parent>' | grep "<${1}>" | head -n 1 | cut -d'>' -f2 | cut -d'<' -f1
}

function mvn-group() {
    _mvn-chunk 'groupId'
}

function mvn-artifact() {
    _mvn-chunk 'artifactId'
}

function mvn-version() {
    _mvn-chunk 'version'
}

function deptreeml() {
    local mlfile=$(mktemp --tmpdir --suffix='.graphml' dependency-tree-XXXX)
    echo ${mlfile}
    deptree -DoutputType=graphml -DoutputFile="${mlfile}"
}
 
# Wrapper function for Maven's mvn command.
function mvn-color() {
  local retval

  # Filter mvn output using sed
  =mvn $@ | sed -e "s/\(\[INFO\]\ \-.*\)/${TEXT_BLUE}${BOLD}\1/g" \
               -e "s/\(\[INFO\]\ \[.*\)/${RESET_FORMATTING}${BOLD}\1${RESET_FORMATTING}/g" \
               -e "s/\(\[INFO\]\ BUILD SUCCESSFUL\)/${BOLD}${TEXT_GREEN}\1${RESET_FORMATTING}/g" \
               -e "s/\(\[WARNING\].*\)/${BOLD}${TEXT_YELLOW}\1${RESET_FORMATTING}/g" \
               -e "s/\(\[ERROR\].*\)/${BOLD}${TEXT_RED}\1${RESET_FORMATTING}/g" \
               -e "s/Tests run: \([^,]*\), Failures: \([^,]*\), Errors: \([^,]*\), Skipped: \([^,]*\)/${BOLD}${TEXT_GREEN}Tests run: \1${RESET_FORMATTING}, Failures: ${BOLD}${TEXT_RED}\2${RESET_FORMATTING}, Errors: ${BOLD}${TEXT_RED}\3${RESET_FORMATTING}, Skipped: ${BOLD}${TEXT_YELLOW}\4${RESET_FORMATTING}/g"
  local mvn_status=$(echo ${pipestatus} | awk '{ print $1 }')
 
  # Make sure formatting is reset
  echo -ne ${RESET_FORMATTING}
  return ${mvn_status}
}
 
# Override the mvn command with the colorized one.
alias mvn=mvn-color

function mvnmkdir() {
  if [ $# -ne 1 ] && [ $# -ne 2 ]; then
    echo "Usage: ${0} type [ package ]"
    return
  fi

  local dir_type=${1}; shift
  local package=${1}

  if [ -n "${package}" ]; then
    package=$(echo "${package}" | sed 's/\./\//g')
  fi

  local dir_path=${dir_type}/${package}
  
  mkdir -vp src/main/${dir_path}
  mkdir -vp src/test/${dir_path}
}

function mvnmkdirgroovy() {
  if [ $# -gt 1 ]; then
    echo "Usage: ${0} [ package ]"
    return
  fi

  local package=${1}; shift

  for name in groovy resources ; do
    mvnmkdir ${name} ${package}
  done
}
