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

[ -n "${_SHELLAC_LOADED_net_cidr+x}" ] && return 0
_SHELLAC_LOADED_net_cidr=1

# @description Convert a CIDR prefix length to a dotted-decimal subnet mask.
#   Accepts the prefix with or without a leading slash (e.g. /24 or 24).
#
# @arg $1 string CIDR prefix length, e.g. 24 or /24
#
# @example
#   net_cidr_to_mask 24   # => 255.255.255.0
#   net_cidr_to_mask /16  # => 255.255.0.0
#
# @stdout The subnet mask in dotted-decimal notation
# @exitcode 0 Success
# @exitcode 1 No valid argument supplied
net_cidr_to_mask() {
  local _subnet_mask
  case "${1}" in
    (/32|32)  _subnet_mask="255.255.255.255" ;;
    (/31|31)  _subnet_mask="255.255.255.254" ;;
    (/30|30)  _subnet_mask="255.255.255.252" ;;
    (/29|29)  _subnet_mask="255.255.255.248" ;;
    (/28|28)  _subnet_mask="255.255.255.240" ;;
    (/27|27)  _subnet_mask="255.255.255.224" ;;
    (/26|26)  _subnet_mask="255.255.255.192" ;;
    (/25|25)  _subnet_mask="255.255.255.128" ;;
    (/24|24)  _subnet_mask="255.255.255.0" ;;
    (/23|23)  _subnet_mask="255.255.254.0" ;;
    (/22|22)  _subnet_mask="255.255.252.0" ;;
    (/21|21)  _subnet_mask="255.255.248.0" ;;
    (/20|20)  _subnet_mask="255.255.240.0" ;;
    (/19|19)  _subnet_mask="255.255.224.0" ;;
    (/18|18)  _subnet_mask="255.255.192.0" ;;
    (/17|17)  _subnet_mask="255.255.128.0" ;;
    (/16|16)  _subnet_mask="255.255.0.0" ;;
    (/15|15)  _subnet_mask="255.254.0.0" ;;
    (/14|14)  _subnet_mask="255.252.0.0" ;;
    (/13|13)  _subnet_mask="255.248.0.0" ;;
    (/12|12)  _subnet_mask="255.240.0.0" ;;
    (/11|11)  _subnet_mask="255.224.0.0" ;;
    (/10|10)  _subnet_mask="255.192.0.0" ;;
    (/9|9)    _subnet_mask="255.128.0.0" ;;
    (/8|8)    _subnet_mask="255.0.0.0" ;;
    (/7|7)    _subnet_mask="254.0.0.0" ;;
    (/6|6)    _subnet_mask="252.0.0.0" ;;
    (/5|5)    _subnet_mask="248.0.0.0" ;;
    (/4|4)    _subnet_mask="240.0.0.0" ;;
    (/3|3)    _subnet_mask="224.0.0.0" ;;
    (/2|2)    _subnet_mask="192.0.0.0" ;;
    (/1|1)    _subnet_mask="128.0.0.0" ;;
    (/0|0)    _subnet_mask="0.0.0.0" ;;
    (''|*)
        printf -- 'net_cidr_to_mask: %s\n' "Usage: net_cidr_to_mask [/int|int]" >&2
        return 1
    ;;
  esac
  printf -- '%s\n' "${_subnet_mask}"
  return 0
}

# I found this function in my code attic from 2015!
# Far less readable than the above and not more efficient either...
#
# Function to convert CIDR subnet extensions to octal style e.g.
# 192.1.1.1/{24} = 192.1.1.1 {255.255.255.0}
# cdr2mask () {
#   # Number of args to shift, 255..255, first non-255 byte, zeroes
#   set -- $(( 5 - ($1 / 8) )) 255 255 255 255 $(( (255 << (8 - ($1 % 8))) & 255 )) 0 0 0
#   [ $1 -gt 1 ] && shift $1 || shift
#   echo ${1-0}.${2-0}.${3-0}.${4-0}
# }

# @description Print a table of all CIDR prefix lengths and their corresponding
#   subnet masks, from /32 down to /0.
#
# @stdout Formatted table of prefix lengths and subnet masks
# @exitcode 0 Always
net_cidr_prefix_table() {
  local _prefix_int
  for (( _prefix_int=32; _prefix_int>=0; _prefix_int-- )); do
    printf -- '%s\n' "+-----+-----------------+"
    printf -- '| /%-2s | %-15s |\n' "${_prefix_int}" "$(net_cidr_to_mask "${_prefix_int}")"
  done
  printf -- '%s\n' "+-----+-----------------+"
}

# @description Convert a dotted-decimal subnet mask to a CIDR prefix length.
#   The mask must be a valid contiguous subnet mask (e.g. 255.255.255.0).
#   Non-contiguous masks (e.g. 255.255.1.0) are rejected.
#
# @arg $1 string Dotted-decimal subnet mask, e.g. 255.255.255.0
#
# @example
#   net_mask_to_cidr 255.255.255.0   # => 24
#   net_mask_to_cidr 255.255.0.0     # => 16
#
# @stdout The CIDR prefix length as a plain integer
# @exitcode 0 Success
# @exitcode 1 Invalid or non-contiguous mask supplied
net_mask_to_cidr() {
  local _o1 _o2 _o3 _o4 _mask _inv _host_bits
  if [[ -z "${1}" ]]; then
    printf -- 'net_mask_to_cidr: %s\n' "Usage: net_mask_to_cidr <dotted-decimal-mask>" >&2
    return 1
  fi
  IFS=. read -r _o1 _o2 _o3 _o4 <<< "${1%%/*}"
  # Validate each octet is numeric and in range
  local _octet
  for _octet in "${_o1}" "${_o2}" "${_o3}" "${_o4}"; do
    case "${_octet}" in
      (''|*[!0-9]*)
        printf -- 'net_mask_to_cidr: %s\n' "invalid mask: ${1}" >&2
        return 1
      ;;
    esac
    if (( _octet > 255 )); then
      printf -- 'net_mask_to_cidr: %s\n' "invalid mask: ${1}" >&2
      return 1
    fi
  done
  (( _mask = (_o1 << 24) | (_o2 << 16) | (_o3 << 8) | _o4 ))
  (( _inv  = _mask ^ 0xFFFFFFFF ))
  # A valid contiguous mask inverts to a block of consecutive 1-bits from bit 0.
  # Identity: inv & (inv + 1) == 0
  if (( (_inv & (_inv + 1)) != 0 )); then
    printf -- 'net_mask_to_cidr: %s\n' "non-contiguous mask: ${1}" >&2
    return 1
  fi
  _host_bits=0
  while (( _inv > 0 )); do
    (( _inv >>= 1 ))
    (( _host_bits++ ))
  done
  printf -- '%d\n' "$(( 32 - _host_bits ))"
}

# TODO: future additions to this module:
#   net_network_address  - derive network address from IP + prefix/mask
#   net_broadcast_address - derive broadcast address from IP + prefix/mask
#   net_subnet_size      - number of usable hosts for a given prefix length
