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

[ -n "${_SHELLAC_LOADED_net_host2ip+x}" ] && return 0
_SHELLAC_LOADED_net_host2ip=1

# @description Resolve a hostname to an IPv4 address, or reverse-resolve an IP
#   to its hostname. Uses 'host -4' for lookups.
#
# @arg $1 string Hostname or IPv4 address to look up
#
# @stdout The resolved IP address, or the hostname from a reverse lookup
# @exitcode 0 Success
# @exitcode 1 No argument supplied or unrecognised input
host2ip() {
  if [[ -z "${1:-}" ]]; then
    printf -- 'Usage: host2ip [hostname|ip.add.re.ss]\n' >&2
    return 1
  elif [[ "${1}" =~ ^[a-zA-Z] ]]; then
    host -4 -W 1 "${1}" | awk '{ print $4 }'
  elif [[ "${1}" =~ ^((25[0-5]|2[0-4][0-9]|[01][0-9][0-9]|[0-9]{1,2})[.]){3}(25[0-5]|2[0-4][0-9]|[01][0-9][0-9]|[0-9]{1,2})$ ]]; then
    host -4 -W 1 "${1}" | awk '{ print $NF }' | cut -d '.' -f1
  else
    printf -- 'host2ip: unrecognised input: %s\n' "${1}" >&2
    return 1
  fi
}
