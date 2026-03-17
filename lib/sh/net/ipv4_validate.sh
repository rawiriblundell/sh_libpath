# shellcheck shell=bash

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

[ -n "${_SHELLAC_LOADED_net_ipv4_validate+x}" ] && return 0
_SHELLAC_LOADED_net_ipv4_validate=1

# @description Validate that a string is a well-formed IPv4 address. Strips optional
#   CIDR notation and double quotes before checking. Runs in a subshell.
#
# @arg $1 string IPv4 address to validate, optionally with CIDR (e.g. 192.168.1.1/24)
#
# @example
#   ipv4_validate_addr 192.168.1.1    # => exit 0
#   ipv4_validate_addr 999.1.1.1      # => exit 1
#
# @exitcode 0 Valid IPv4 address
# @exitcode 1 Invalid or malformed address
ipv4_validate_addr() {
  # Disable SC2086 for 'set -- ${*%/*}' as we require this to be word split
  # shellcheck disable=SC2086
  (
    IFS=.; set -f; set -- ${*//\"/}; set -- ${*%/*}
    local octet count errcount
    count=0
    errcount=0
    if (( "${#}" == 4 )); then
      for octet in "${@}"; do
        (( ++count ))
        case "${octet}" in
          (""|*[!0-9]*)
            printf -- '%s\n' "Octet ${count} appears to be empty or non-numeric" >&2
            (( ++errcount ))
          ;;
          (*)
            if (( octet > 255 )); then
              printf -- '%s\n' "Octet ${count} appears to be invalid (>255)" >&2
              (( ++errcount ))
            fi
          ;;
        esac
      done
      (( errcount > 0 )) && return 1
    else
      printf -- '%s\n' "Input does not appear to be a valid IPv4 address" >&2
      return 1
    fi
    # If we get to this point, then all should be ok
    return 0
  )
}
