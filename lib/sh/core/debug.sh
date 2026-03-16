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

[ -n "${_SHELLAC_LOADED_core_debug+x}" ] && return 0
_SHELLAC_LOADED_core_debug=1

# https://www.reddit.com/r/bash/comments/g1yjfo/debugging_bash_scripts/
# https://johannes.truschnigg.info/writing/2021-12_colodebug/

# @description Enable ERR trap to call debug_err_handler on any error.
#
# @exitcode 0 Always
debug_trap_err() {
    set -o errtrace
    trap 'debug_err_handler ${?}' ERR
}

# @description Handle ERR trap: print a stack trace and exit.
#
# @arg $1 int The exit code from the failing command
#
# @stderr Stack trace and error exit code
# @exitcode Propagates the original error exit code
debug_err_handler() {
    local i
    local _exit_code
    trap - ERR
    i=0
    _exit_code="${1}"
    printf -- '%s\n' "Aborting on error ${_exit_code}:" \
        "--------------------" >&2
    while caller "${i}" >&2; do
        : $(( i += 1 ))
    done
    exit "${_exit_code}"
}

# @description Emit a debug trace when debug_mode is true.
#   Uses the no-op colon builtin so output appears only in xtrace (-x) output.
#
# @exitcode 0 Always
debug() {
    [[ "${debug_mode}" = "true" ]] || return 0
    : [DEBUG] "${*}"
    : ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
}

# @description Like debug(), but pauses for a keypress before continuing.
#
# @exitcode 0 Always
step() {
    [[ "${debug_mode}" = "true" ]] || return 0
    : [DEBUG] "${*}"
    : ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    read -n 1 -s -r -p "Press any key to continue"
}

# Check whether the sourcing script was invoked with -d/--debug and enable
# debug mode if so. Intentionally runs at source time.
case "${1}" in
    (-d|--debug)
        set -xv
        export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
        readonly debug_mode=true
        trap 'set +x' EXIT
    ;;
esac

# @description Drop into an interactive debug REPL at the call site.
#   Keys: o=options, p=parameters, a=indexed arrays, A=assoc arrays,
#   x=enable xtrace, X=disable xtrace, q=quit.
#
# @exitcode 0 Always
breakpoint() {
    local REPLY
    printf -- '%s\n' 'Breakpoint hit. [opaAxXq]'
    while read -r -n 1 REPLY; do
        case "${REPLY}" in
            (o) shopt -s; set -o ;;
            (p) declare -p | less ;;
            (a) declare -a ;;
            (A) declare -A ;;
            (x) set -x ;;
            (X) set +x ;;
            (q) return ;;
            (*) ;;
        esac
    done
}

# @description Make Ctrl+C a no-op to prevent it killing the script.
#
# @exitcode 0 Always
no_ctrl_c() {
    # @internal
    _no_ctrl_c() { :; }
    trap _no_ctrl_c INT
}

# @description Remove the directory containing the current script from PATH
#   to prevent infinite recursion when a script shadows a system command.
#
# @exitcode 0 Always
prevent_path_recursion() {
    local curdir
    local _element
    local _new_path
    local _old_ifs
    curdir=$(realpath "$(dirname "${BASH_SOURCE[0]}")")
    _new_path=
    _old_ifs="${IFS}"
    IFS=:
    for _element in ${PATH}; do
        [ "${_element}" = "${curdir}" ] && continue
        _new_path="${_new_path:+${_new_path}:}${_element}"
    done
    IFS="${_old_ifs}"
    export PATH="${_new_path}"
}
