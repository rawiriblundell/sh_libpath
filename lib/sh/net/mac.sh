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

[ -n "${_SHELLAC_LOADED_net_mac+x}" ] && return 0
_SHELLAC_LOADED_net_mac=1

# @internal
_sanitise_mac_addr() {
  local raw_mac octet
  raw_mac="${1:?No MAC data}"
  for octet in ${raw_mac}; do
    if [[ "${#octet}" -eq "1" ]]; then
      printf "0%s-" "${octet}"
    else
      printf "%s-" "${octet}"
    fi
  done | tr '[:lower:]' '[:upper:]' | cut -d- -f1-6
}

# @description Get the MAC address of the primary UP network interface.
#   Tries 'ip' first, then 'ifconfig', then 'dladm' (Solaris), then 'arp'.
#   ifconfig has unexplored issues in Azure/OpenShift.
#   AIX may need netstat -ia; HPUX may need lanscan.
#
# @stdout The MAC address in XX-YY-ZZ-AA-BB-CC format (uppercase)
# @exitcode 0 Always
net_get_mac() {
  local mac_addr raw_mac
  if command -v ip >/dev/null 2>&1; then
    mac_addr=$(ip -brief link | awk '$2 == "UP" {print $3; exit}' | tr ":" "-")
  elif command -v ifconfig >/dev/null 2>&1; then
    mac_addr=$(ifconfig | awk '$0 ~ /HWaddr/ {print $5}' | tr ":" "-" | head -n 1)
    # If we're here, then we might have a different ifconfig output format.  Yay.
    if [[ -z "${mac_addr}" ]]; then
      mac_addr=$(ifconfig | awk '$0 ~ /ether/ {print $2; exit}' | tr ":" "-")
    fi
  # Solaris
  elif command -v dladm >/dev/null 2>&1; then
    mac_addr=$(dladm show-linkprop -p mac-address | awk '/^LINK/{print $4; exit}' | tr ":" " ")
  elif arp "$(hostname)" >/dev/null 2>&1; then
    raw_mac=$(arp "$(hostname)" | awk '{ print $4 }' | tr ":" " ")
    mac_addr=$(_sanitise_mac_addr "${raw_mac}")
  fi
  printf -- '%s\n' "${mac_addr}"
}
