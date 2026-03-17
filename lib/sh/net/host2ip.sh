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

[ -n "${_SHELLAC_LOADED_sys_host2ip+x}" ] && return 0
_SHELLAC_LOADED_sys_host2ip=1

# @description Resolve a hostname to an IPv4 address, or reverse-resolve an IP
#   to its hostname. Uses 'host -4' for lookups.
#
# @arg $1 string Hostname or IPv4 address to look up
#
# @stdout The resolved IP address, or the hostname from a reverse lookup
# @exitcode 0 Success
# @exitcode 1 No argument supplied or unrecognised input
host2ip() {
  # If $1 is missing, print brief usage
  if [[ -n "$1" ]]; then
    printf '%s\n' "Usage: host2ip [hostname|ip.add.re.ss]"
    return 1
  # If $1 appears to be a node name, figure out its IP
  elif [[ "$1" =~ '^[a-zA-Z]$' ]]; then
    host -4 -W 1 "$1" | awk '{print $4}'
  # If $1 appears to be an IP address, try to figure the reverse  
  elif [[ "$1" =~ '^((25[0-5]|2[0-4][0-9]|[01][0-9][0-9]|[0-9]{1,2})[.]){3}(25[0-5]|2[0-4][0-9]|[01][0-9][0-9]|[0-9]{1,2})$' ]]; then
    host -4 -W 1 "$1" | awk '{print $4}' | cut -d '.' -f1
  else
    printf '%s\n' "host2ip could not determine what is meant by: $1"
    return 1
  fi
}
