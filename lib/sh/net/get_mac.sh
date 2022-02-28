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

# Takes word split mac address, uppercases and outputs in XX-YY-... format
_sanitise_mac_addr() {
  for octet in ${rawMac}; do
    if [[ "${#octet}" -eq "1" ]]; then
      printf "0%s-" "${octet}"
    else
      printf "%s-" "${octet}"
    fi
  done | tr '[:lower:]' '[:upper:]' | cut -d- -f1-6
}

# MAC Address, start with the newer ip command, failover to ifconfig
# ifconfig has unexplored issues in Azure/Openshift
# AIX may need to use netstat -ia
# HPUX may need to use lanscan
get_mac() {
  if command -v ip >/dev/null 2>&1; then
    macAddr=$(ip -brief link | awk '$2 == "UP" {print $3; exit}' | tr ":" "-")
    #macAddr=$(ip -s link | grep -A 1 UP | awk '/ether/{print $2; exit}' | tr ":" "-")
  elif command -v ifconfig >/dev/null 2>&1; then
    macAddr=$(ifconfig | awk '$0 ~ /HWaddr/ {print $5}' | tr ":" "-" | head -n 1)
    # If we're here, then we might have a different ifconfig output format.  Yay.
    if [[ -z "${macAddr}" ]]; then
      macAddr=$(ifconfig | awk '$0 ~ /ether/ {print $2; exit}' | tr ":" "-")
    fi
  # Solaris
  elif command -v dladm >/dev/null 2>&1; then
    dladm show-linkprop -p mac-address | awk '/^LINK/{print $4; exit}' | tr ":" " "
  elif arp "$(hostname)" >/dev/null 2>&1; then
    rawMac=$(arp "$(hostname)" | awk '{ print $4 }' | tr ":" " ")
  fi
}
