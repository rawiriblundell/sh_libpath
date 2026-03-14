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

[ -n "${_SH_LOADED_net_get_gateway+x}" ] && return 0
_SH_LOADED_net_get_gateway=1

# @description Get the default gateway address. Tries 'ip route', then 'netstat',
#   then 'route' in order. Handles Linux and Solaris differences via OSSTR.
#
# @stdout The default gateway IP address
# @exitcode 0 Always
get_gateway() {
  local _get_gwaddr
  # Default Gateway
  if command -v ip >/dev/null 2>&1; then
    _get_gwaddr=$(ip route show | awk '/^default|^0.0.0.0/{ print $3 }')
  elif [[ -z ${_get_gwaddr} ]]; then
    case "${OSSTR}" in
      (linux)
        _get_gwaddr=$(netstat -nrv | awk '/^default|^0.0.0.0/{ print $2; exit }')
      ;;
      (solaris)
        _get_gwaddr=$(netstat -nrv | awk '/^default|^0.0.0.0/{ print $3; exit }')
      ;;
    esac
  elif [[ -z ${_get_gwaddr} ]]; then
    _get_gwaddr=$(route -n | awk '/^default|^0.0.0.0/{ print $2 }')
  fi
  printf -- '%s\n' "${_get_gwaddr}"
}
