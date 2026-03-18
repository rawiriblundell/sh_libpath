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
# IPv6 validator adapted from labbots/bash-utility (MIT)
#   https://github.com/labbots/bash-utility

[ -n "${_SHELLAC_LOADED_net_validate+x}" ] && return 0
_SHELLAC_LOADED_net_validate=1

# @internal Validate an IPv4 address string.
#   Strips optional CIDR notation and double quotes before checking.
#   Runs in a subshell so IFS/set manipulation does not leak.
_net_validate_ipv4() {
  # Disable SC2086: word splitting on ${*%/*} is intentional here
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
    return 0
  )
}

# @internal Validate an IPv6 address string via regex.
#   Handles full, compressed (::), link-local, IPv4-mapped, and zone-ID (%eth0) forms.
_net_validate_ipv6() {
  local re
  re="^(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|"
  re+="([0-9a-fA-F]{1,4}:){1,7}:|"
  re+="([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|"
  re+="([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|"
  re+="([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|"
  re+="([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|"
  re+="([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|"
  re+="[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|"
  re+=":((:[0-9a-fA-F]{1,4}){1,7}|:)|"
  re+="fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|"
  re+="::(ffff(:0{1,4}){0,1}:){0,1}"
  re+="((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}"
  re+="(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|"
  re+="([0-9a-fA-F]{1,4}:){1,4}:"
  re+="((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}"
  re+="(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))$"
  [[ "${1}" =~ ${re} ]]
}

# @description Validate a string as an IPv4 or IPv6 address.
#   Without a flag, the type is detected heuristically:
#     ':' in input  →  IPv6
#     otherwise     →  IPv4
#   Use -4 or -6 to force a specific validator.
#   IPv4 accepts optional CIDR notation and strips double quotes before checking.
#   IPv6 handles full, compressed (::), link-local, IPv4-mapped, and zone-ID (%eth0) forms.
#   For email address validation, use str_is_email (text/predicates).
#
# @arg $1 string Flag (optional): -4 (force IPv4) or -6 (force IPv6)
# @arg $@ string Value to validate
#
# @example
#   net_validate 192.168.1.1      # auto-detects IPv4 => exit 0
#   net_validate 192.168.1.1/24   # IPv4 with CIDR    => exit 0
#   net_validate 2001:db8::1      # auto-detects IPv6 => exit 0
#   net_validate -4 192.168.1.1   # explicit IPv4     => exit 0
#   net_validate -6 ::1           # explicit IPv6     => exit 0
#
# @exitcode 0 Valid
# @exitcode 1 Invalid
# @exitcode 2 Missing argument or unknown flag
net_validate() {
  local _mode _input
  _mode=""

  while (( $# > 0 )); do
    case "${1}" in
      (-4) _mode=ipv4; shift ;;
      (-6) _mode=ipv6; shift ;;
      (--) shift; break ;;
      (-*)
        printf -- 'net_validate: unknown option: %s\n' "${1}" >&2
        return 2
      ;;
      (*) break ;;
    esac
  done

  if (( $# == 0 )); then
    printf -- '%s\n' "net_validate: missing argument" >&2
    return 2
  fi

  _input="${1}"

  if [[ -z "${_mode}" ]]; then
    case "${_input}" in
      (*:*) _mode=ipv6 ;;
      (*)   _mode=ipv4 ;;
    esac
  fi

  case "${_mode}" in
    (ipv4) _net_validate_ipv4 "${_input}" ;;
    (ipv6) _net_validate_ipv6 "${_input}" ;;
  esac
}

# Backward-compat aliases
net_validate_ipv4()    { net_validate -4 "${@}"; }
net_validate_ipv6()    { net_validate -6 "${@}"; }
net_validate_address() { net_validate -4 "${@}"; }
