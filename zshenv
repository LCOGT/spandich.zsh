#!/bin/zsh

export PATH="/opt/intel/bin:/opt/epd/bin:/usr/local/astrometry/bin:/home/spandich/bin:/usr/lib64/qt-3.3/bin:/usr/kerberos/sbin:/usr/kerberos/bin:/opt/intel/bin:/opt/epd/bin:/usr/local/astrometry/bin:/usr/local/bin:/usr/bin:/bin:/home/spandich/bin:/usr/local/sbin:/usr/sbin:/sbin:/opt/wcstools/bin:/opt/wcstools/bin:${HOME}/.gvm/groovy/current/bin"
export PATH="${HOME}/bin:${PATH}"

export ZSH=$HOME/.oh-my-zsh

export EDITOR=vim
export PAGER=most
export LISTMAX=200

export ZSH_THEME='mikeh'
export CASE_SENSITIVE='true'
export COMPLETION_WAITING_DOTS='true'
export DISABLE_AUTO_UPDATE='true'

export GREP_OPTIONS='--color=auto'
export GREP_COLOR='1;31'

LESS_OPTS=()
LESS_OPTS+=('--clear-screen')
LESS_OPTS+=('--quit-at-eof')
LESS_OPTS+=('--quit-if-one-screen')
LESS_OPTS+=('--long-prompt')
LESS_OPTS+=('--hilite-unread')
LESS_OPTS+=('--tilde')
LESS_OPTS+=('--raw-control-chars')
export LESS="${(j: :)LESS_OPTS}"

export HISTCONTROL=erasedups  # Ignore duplicate entries in history
export HISTFILE=~/.histfile
export HISTSIZE=10000         # Increases size of history
export SAVEHIST=10000
export HISTIGNORE='&:ls:ll:la:l.:pwd:exit:clear:clr:[bf]g'

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

export WINEPREFIX=~/.wine
export WINEARCH=win64
export WORKSPACE=~/workspace

export JAVA_HOME="${JAVA7_HOME}"
export PATH="${JAVA_HOME}/bin:${PATH}"

export MAVEN_HOME=/opt/maven3
export PATH="${PATH}:${MAVEN_HOME}/bin"

export PATH="/opt/epd/bin:${PATH}"

export SWIG3_HOME=/opt/swig3
export PATH="${SWIG3_HOME}/bin:${PATH}"

export JPROFILER_HOME=/opt/jprofiler
export PATH="${PATH}:${JPROFILER_HOME}/bin"

export PATH="${PATH}:~/.cabal/bin"

export pdu_ip=power
