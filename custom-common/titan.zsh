#!/usr/bin/env zsh

_include wine

function vititan() {
  SELF=${ZSH_CUSTOM_COMMON_DIR}/titan.zsh
  vi "${SELF}" && source "${SELF}"
}

export PYTHON_INCLUDE_DIR=${WINE_DRIVE_C}/Python2.6/include

export ARTEMIS_SDK_DIR=${WINE_PROGRAMS}/ArtemisCCD/SDK
export ARTEMIS_INCLUDE=ArtemisHscAPI.h
export ARTEMIS_PYTHON_MODULE=artemis_hsc


function build_titan_python() {
  local artemis_include_cpp="${ARTEMIS_INCLUDE:r}_cpp.h"

  local swig_arguments
  typeset -a swig_arguments
  swig_arguments=(
    -v
    -c++
    -python
    -Fmicrosoft
    -module ${ARTEMIS_PYTHON_MODULE}
    ${artemis_include_cpp:r}.i
  )

  local module=artemis
  local swig_command="\
      cd ${ARTEMIS_SDK_DIR} && \
      cpp -I. -w -x c ${ARTEMIS_INCLUDE} > ${artemis_include_cpp}
      swigwin ${swig_arguments} \
    "

  local swing_interface
  read -d '' swig_interface <<"EOF"
%module ${ARTEMIS_PYTHON_MODULE}
%{
#include "${ARTEMIS_INCLUDE}"
%}
 
%include "${ARTEMIS_INCLUDE}"
EOF
  echo "${(e)swig_interface}" > ${artemis_include_cpp:r}.i
  local compile_module_command="c++win -w -c ${ARTEMIS_PYTHON_MODULE}_wrap.c -I ${PYTHON_INCLUDE_DIR}"
  local shared_lib_command="c++win -shared ${ARTEMIS_PYTHON_MODULE}_wrap.o _pair.so"

  clear 

  echo "${swig_command}" && \
  eval "${swig_command}" && rm ${artemis_include_cpp} && \

  echo "${compile_module_command}" && \
  eval "${compile_module_command}" && \

  echo "${share_lib_command}"
  eval "${share_lib_command}"
}

