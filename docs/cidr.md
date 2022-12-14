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

cidr_prefix_to_mask() {
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
        printf -- 'cidr_prefix_to_mask: %s\n' "Usage: cider_prefix_to_mask [/int|int]" >&2
        return 1
    ;;
  esac
  printf -- '%s\n' "${_subnet_mask}"
  unset -v _subnet_mask
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

cidr_prefix_table() {
  for (( _prefix_int=32; _prefix_int>=0; _prefix_int-- )); do
    printf -- '%s\n' "+-----+-----------------+"
    printf -- '| /%-2s | %-15s |\n' "${_prefix_int}" "$(cidr_prefix_to_mask "${_prefix_int}")"
  done
  printf -- '%s\n' "+-----+-----------------+"
  unset -v _prefix_int
}
