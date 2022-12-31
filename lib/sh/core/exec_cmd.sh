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

exec_cmd() {
    case "${1}" in
        (-e|--exit-on-fail) shift 1; die=yes ;;
    esac
    if [ -t 0 ]; then
        inf_fmt='\e[7m====>Timestamp:\e[0m %s\n\e[7m====>Executing:\e[0m %s\n'
        ok_fmt='\e[7m====>Output   :\e[0m\n%s\n\n\e[32;1m====>Exit Code\e[0m: %s\n\e[32;1m====>all be GOOD\e[0m\n'
        err_fmt='\e[7m====>Output   :\e[0m\n%s\n\e[31;1m====>Exit Code\e[0m: %s\n\e[31;1m====>in ERROR\e[0m\n'
    else
        inf_fmt='====>Timestamp: %s\n====>Executing: %s\n'
        ok_fmt='====>Output: %s\n\n====>Exit Code: %s\n====>all be GOOD\n'
        err_fmt='====>Output: %s\n====>Exit Code: %s\n====>in ERROR'
    fi
    # shellcheck disable=SC2059
    printf -- "${inf_fmt}" "$(date +%s)" "${*}"
    output=$("${@}")
    # shellcheck disable=SC2059
    case "${?}" in
        (0)
            printf -- "${ok_fmt}"  "${output}" "${?}"
        ;;
        (*)
            printf -- "${err_fmt}" "${output}" "${?}"
            [[ "${die}" = "yes" ]] && exit 1
        ;;
    esac
}
