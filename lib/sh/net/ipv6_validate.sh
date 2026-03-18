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
# Adapted from labbots/bash-utility (MIT) https://github.com/labbots/bash-utility

[ -n "${_SHELLAC_LOADED_net_ipv6_validate+x}" ] && return 0
_SHELLAC_LOADED_net_ipv6_validate=1

# @description Validate whether a string is a valid IPv6 address.
#   Handles full, compressed (::), link-local, IPv4-mapped, and zone ID (%eth0) forms.
#
# @arg $1 string String to test
#
# @example
#   net_validate_ipv6 "::1"                    # => exit 0
#   net_validate_ipv6 "2001:db8::1"            # => exit 0
#   net_validate_ipv6 "fe80::1%eth0"           # => exit 0
#   net_validate_ipv6 "not-an-address"          # => exit 1
#
# @exitcode 0 Valid IPv6 address
# @exitcode 1 Invalid
# @exitcode 2 Missing argument
net_validate_ipv6() {
  local re
  [[ $# -eq 0 ]] && { printf -- '%s\n' "net_validate_ipv6: missing argument" >&2; return 2; }
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
