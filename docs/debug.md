# FUNCTION_NAME

## Description

## Synopsis

## Options

## Examples

## Output
# shellcheck shell=ksh

# Copyright 2022 Rawiri Blundell
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
################################################################################
# Provenance: https://github.com/rawiriblundell/sh_libpath
# SPDX-License-Identifier: Apache-2.0

# https://www.reddit.com/r/bash/comments/g1yjfo/debugging_bash_scripts/
# https://johannes.truschnigg.info/writing/2021-12_colodebug/

debug_trap_err() {
  set -o errtrace
  trap 'err_handler ${?}' ERR
}

debug_err_handler() {
  trap - ERR
  i=0
  printf -- '%s\n' "Aborting on error ${1}:" \
    "--------------------" >&2
  while caller $i; do
    ((i++))
  done
  exit "${?}"
}

debug() {
  [[ "${debug_mode}" = "true" ]] || return 0
  : [DEBUG] "${*}"
  : ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
}

# As above but with a pause 
step() {
  [[ "${debug_mode}" = "true" ]] || return 0
  : [DEBUG] "${*}"
  : ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  read -n 1 -s -r -p "Press any key to continue"
}

case "${1}" in
  (-d|--debug)
    set -xv
    export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
    readonly debug_mode=true
    trap 'set +x' EXIT
  ;;
esac

breakpoint(){
    local REPLY
    echo 'Breakpoint hit. [opaAxXq]'
    while read -r -k1; do case $REPLY in
        o) shopt -s; set -o ;;   # list options
        p) declare -p | less ;;  # list parameters
        a) declare -a ;;
        A) declare -A ;;
        x) set -x ;;             # toggle xtrace
        X) set +x ;;
        q) return ;;             # quit
    esac; done
}

# Make Ctrl+C a no-op to prevent it killing the script
no_ctrl_c() {
  _no_ctrl_c() { :; }
  trap _no_ctrl_c INT
}

# Sometimes there may be a need to remove the current directory from PATH
# in order to prevent an infinite recursion
prevent_path_recursion() {
  curdir=$(realpath $(dirname ${BASH_SOURCE}))
  export PATH=$(echo $PATH | tr ':' '\n' | \
      awk '$0!="'${curdir}'"' | tr '\n' ':')
}
