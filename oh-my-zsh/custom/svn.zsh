#!/usr/bin/env zsh

SELF=${0:a}

SVN_SERVER=versionsba.${LCOGT_DOMAIN}
SVN_ROOT=/svn/telsoft/Lco

function ai() {
  sudo apt-get install $@
}

alias h=history

function visvn() {
  vi "${SELF}" && source "${SELF}"
} 

function svndiff() {
  svn diff --git $@ | vimdiff -R -
}

function svnco() {
  if [ $# -ne 1 ] && [ $# -ne 2 ]; then
    echo "Usage: ${0} project_name [ branch ]"
    return
  fi

  local project=${1}; shift
  local branch=${1:=trunk}; shift
  svn co http://${SVN_SERVER}${SVN_ROOT}/${project}/${branch} ${project}
}

alias svns='svn status'

function svnlogme() {
  svn log $@ | grep -B2 ${USER} | sed '/^-\+/d' | paste - - -d:
}

function setmvn() {
  if [ $# -ne 1 ]; then
    echo "Usage: ${0} ( 2 | 3 )"
    return
  fi

  local version="${1}"; shift

  case "${version}" in
    2)
      cd /opt && sudo rm -f maven && sudo ln -s maven2 maven
      ;;

    3)
      cd /opt && sudo rm -f maven && sudo ln -s maven3 maven
      ;;

    *)
      echo "Version must be 2 or 3"
      ;;
  esac

  ls -ld /opt/maven
  echo
  mvn -version
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
 
# Wrapper function for Maven's mvn command.
function mvn-color() {
  # Filter mvn output using sed
  mvn $@ | sed -e "s/\(\[INFO\]\ \-.*\)/${TEXT_BLUE}${BOLD}\1/g" \
               -e "s/\(\[INFO\]\ \[.*\)/${RESET_FORMATTING}${BOLD}\1${RESET_FORMATTING}/g" \
               -e "s/\(\[INFO\]\ BUILD SUCCESSFUL\)/${BOLD}${TEXT_GREEN}\1${RESET_FORMATTING}/g" \
               -e "s/\(\[WARNING\].*\)/${BOLD}${TEXT_YELLOW}\1${RESET_FORMATTING}/g" \
               -e "s/\(\[ERROR\].*\)/${BOLD}${TEXT_RED}\1${RESET_FORMATTING}/g" \
               -e "s/Tests run: \([^,]*\), Failures: \([^,]*\), Errors: \([^,]*\), Skipped: \([^,]*\)/${BOLD}${TEXT_GREEN}Tests run: \1${RESET_FORMATTING}, Failures: ${BOLD}${TEXT_RED}\2${RESET_FORMATTING}, Errors: ${BOLD}${TEXT_RED}\3${RESET_FORMATTING}, Skipped: ${BOLD}${TEXT_YELLOW}\4${RESET_FORMATTING}/g"
 
  # Make sure formatting is reset
  echo -ne ${RESET_FORMATTING}
}
 
# Override the mvn command with the colorized one.
alias mvn=mvn-color
