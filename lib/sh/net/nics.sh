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

[ -n "${_SHELLAC_LOADED_net_nics+x}" ] && return 0
_SHELLAC_LOADED_net_nics=1

# @description Print information about all network interfaces on the host.
#   Checks /sys/class/net, then 'ip a', then 'ifconfig -a', then ethtool per
#   interface if available. Informational messages go to stderr.
#
# @stdout Network interface details from available tools
# @exitcode 0 Always
net_nics() {
  local output
  local net_if

  if [[ -d /sys/class/net ]]; then
    output="$(ls -ltr /sys/class/net/ 2>/dev/null)"
    if [[ -n "${output}" ]]; then
      printf -- '%s\n' "${output}"
    else
      printf -- 'net_nics: no devices found in /sys/class/net/\n' >&2
    fi
  fi

  if command -v ip >/dev/null 2>&1; then
    output="$(ip a 2>/dev/null | grep -v "valid_lft")"
    if [[ -n "${output}" ]]; then
      printf -- '%s\n' "${output}"
    else
      printf -- "net_nics: 'ip a' returned no output\n" >&2
    fi
  fi

  if command -v ifconfig >/dev/null 2>&1; then
    output="$(ifconfig -a 2>/dev/null | grep -Ev 'RX|TX|collisions')"
    if [[ -n "${output}" ]]; then
      printf -- '%s\n' "${output}"
    else
      printf -- "net_nics: 'ifconfig -a' returned no output\n" >&2
    fi
  fi

  if command -v ethtool >/dev/null 2>&1 && command -v ip >/dev/null 2>&1; then
    while read -r net_if; do
      ethtool "${net_if}" 2>/dev/null
    done < <(ip -o link show 2>/dev/null | awk -F ': ' '{ print $2 }')
  fi
}
