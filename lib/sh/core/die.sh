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

[ -n "${_SHELLAC_LOADED_core_die+x}" ] && return 0
_SHELLAC_LOADED_core_die=1

# Get the top level PID and setup a trap so that we can call die() within subshells
trap "exit 1" TERM
_self_pid="${$}"
export _self_pid

# @description Print a formatted error message and terminate the script by
#   sending SIGTERM to the top-level PID. Safe to call from subshells.
#   Uses colour when stderr is a terminal.
#
# @arg $@ string Error message text
#
# @stderr Formatted error message prefixed with script name and line number
# @exitcode 1 Always (via SIGTERM trap)
die() {
    if [ -t 2 ]; then
        printf '\e[31;1m====>%s\e[0m\n' "${0}:(${LINENO}): ${*}" >&2
    else
        printf -- '====>%s\n' "${0}:(${LINENO}): ${*}" >&2
    fi
    kill -s TERM "${_self_pid}"
}

# @description Run a command and die with a descriptive message if it fails.
#   A lightweight alternative to exec_cmd() for critical one-liners.
#
# @arg $@ string The command and its arguments to execute
#
# @exitcode 0 Command succeeded
# @exitcode 1 Command failed (via die())
try() {
    "${@}" || die "cannot ${*}"
}
