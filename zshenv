#!/bin/zsh

export PATH="/opt/intel/bin:/opt/epd/bin:/usr/local/astrometry/bin:/home/spandich/bin:/usr/lib64/qt-3.3/bin:/usr/kerberos/sbin:/usr/kerberos/bin:/opt/intel/bin:/opt/epd/bin:/usr/local/astrometry/bin:/usr/local/bin:/usr/bin:/bin:/home/spandich/bin:/usr/local/sbin:/usr/sbin:/sbin:/opt/wcstools/bin:/opt/wcstools/bin"
export PATH="${HOME}/bin:${PATH}"
export PATH="${PATH}:/opt/maven/bin"

export JAVA_OPTS="-Xms2048m -Xmx2048m -XX:MaxPermSize=384m -Djava.io.tmpdir='${HOME}/tmp'"
export MAVEN_OPTS="${MAVEN_OPTS} ${JAVA_OPTS} -XX:NewRatio=1"
export M2_HOME=/opt/maven

export ZSH=$HOME/.oh-my-zsh

export EDITOR=vim
export LISTMAX=200

export ZSH_THEME='mikeh'
export CASE_SENSITIVE="true"
export COMPLETION_WAITING_DOTS="true"
export DISABLE_AUTO_UPDATE="true"

export GREP_OPTIONS='--color=auto'
export GREP_COLOR='1;31'

export LESS="-R"

export HISTCONTROL=erasedups  # Ignore duplicate entries in history
export HISTFILE=~/.histfile
export HISTSIZE=10000         # Increases size of history
export SAVEHIST=10000
export HISTIGNORE="&:ls:ll:la:l.:pwd:exit:clear:clr:[bf]g"

RED="\[\033[0;31m\]"
PINK="\[\033[1;31m\]"
YELLOW="\[\033[1;33m\]"
GREEN="\[\033[0;32m\]"
LT_GREEN="\[\033[1;32m\]"
BLUE="\[\033[0;34m\]"
WHITE="\[\033[1;37m\]"
PURPLE="\[\033[1;35m\]"
CYAN="\[\033[1;36m\]"
BROWN="\[\033[0;33m\]"
COLOR_NONE="\[\033[0m\]"

export WORKSPACE=~/workspace
