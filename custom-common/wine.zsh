#!/usr/bin/env zsh


function viwine() {
  SELF=${ZSH_CUSTOM_COMMON_DIR}/wine.zsh
  vi "${SELF}" && source "${SELF}"
}

export WINEARCH=win32
export WINEDEBUG=-all

export WINE_DRIVE_C=~/.wine/drive_c
export WINE_PROGRAMS="${WINE_DRIVE_C}/Program\\ Files"

function swigwin() {
 eval wine "$(eval ls ${WINE_PROGRAMS}/swigwin*/swig.exe)" $@
}

alias pywin="wine ${WINE_DRIVE_C}/Python26/python.exe"
alias c++win="wine c++"
