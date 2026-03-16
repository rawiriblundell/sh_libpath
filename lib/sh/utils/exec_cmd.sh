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

[ -n "${_SHELLAC_LOADED_utils_exec_cmd+x}" ] && return 0
_SHELLAC_LOADED_utils_exec_cmd=1

# @description Execute a command while logging its timestamp, output and exit code.
#   Uses colour when stdout is a terminal. Pass -e/--exit-on-fail to abort on error.
#
# @arg $1 string Optional: -e or --exit-on-fail to exit on non-zero return
# @arg $@ string The command and its arguments to execute
#
# @stdout Formatted execution log with timestamp, command output and exit code
# @exitcode 0 Command succeeded
# @exitcode 1 Command failed and -e/--exit-on-fail was given
exec_cmd() {
    local _die
    local _output
    local _exit_code

    _die=0
    case "${1}" in
        (-e|--exit-on-fail) _die=1; shift ;;
    esac

    if [ -t 1 ]; then
        printf '\e[7m====>Timestamp:\e[0m %s\n\e[7m====>Executing:\e[0m %s\n' \
            "$(date +%s)" "${*}"
    else
        printf -- '====>Timestamp: %s\n====>Executing: %s\n' \
            "$(date +%s)" "${*}"
    fi

    _output=$("${@}")
    _exit_code="${?}"

    if (( _exit_code == 0 )); then
        if [ -t 1 ]; then
            printf '\e[7m====>Output   :\e[0m\n%s\n\n\e[32;1m====>Exit Code\e[0m: %s\n\e[32;1m====>all be GOOD\e[0m\n' \
                "${_output}" "${_exit_code}"
        else
            printf -- '====>Output: %s\n\n====>Exit Code: %s\n====>all be GOOD\n' \
                "${_output}" "${_exit_code}"
        fi
    else
        if [ -t 1 ]; then
            printf '\e[31;1m====>Output   :\e[0m\n%s\n\e[31;1m====>Exit Code\e[0m: %s\n\e[31;1m====>in ERROR\e[0m\n' \
                "${_output}" "${_exit_code}"
        else
            printf -- '====>Output: %s\n====>Exit Code: %s\n====>in ERROR\n' \
                "${_output}" "${_exit_code}"
        fi
        (( _die )) && exit 1
    fi
}
