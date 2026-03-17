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

[ -n "${_SHELLAC_LOADED_net_get_ip+x}" ] && return 0
_SHELLAC_LOADED_net_get_ip=1

# External options
# http https IPv DNS
#            4 6
# y    y     4 6 -   ifconfig.co/
# y    *     4 n -   whatismyip.akamai.com/ # cert may not match
# y    y     4 6 -   icanhazip.com/
# y    y     4 n -   ipinfo.io/ip
# y    y     4 6 -   ifconfig.me/
# y    y     4 n -   echoip.xyz/
# -    -     4 6 y   ns1.google.com. o-o.myaddr.l.google.com. TXT
# -    -     4 6 y   resolver1.opendns.com. myip.opendns.com. A myip.opendns.com. AAAA

# ifconfig outputs in either of these formats:
# inet addr:192.168.2.1  Bcast:192.168.1.255  Mask:255.255.255.0
# inet 172.19.243.193  netmask 255.255.240.0  broadcast 172.19.255.255
#
# So we try to cater for both by searching for 'inet' and printing the next field with "addr:" stripped

# @description Get the IP address of the local host or its external/public address.
#   Supports IPv4 (default) and IPv6 via flags. Falls back through 'ip', 'ifconfig',
#   and 'nslookup' in that order for local addresses. Uses ifconfig.io for external.
#
# @arg $1 string Optional: 'external' or 'public' for the external IP; '-4' for IPv4; '-6' for IPv6
# @arg $2 string Optional: '-6' when combined with 'external' to request the IPv6 public address
#
# @example
#   get_ip           # => local IPv4 address
#   get_ip -6        # => local IPv6 address
#   get_ip external  # => public IPv4 address
#
# @stdout The IP address(es), one per line
# @exitcode 0 Success
# @exitcode 1 Could not determine address
get_ip() {
  case "${1}" in
    (external|public)
      case "${2}" in
        (-6) curl -6 ifconfig.io ;;
        (*)  curl -4 ifconfig.io ;;
      esac
    ;;
    (-6)
      # Start with the 'ip' command
      if command -v ip >/dev/null 2>&1; then
        ip -o -6 a show up | awk -F '[ /]' '$2 != "lo" {print $7; exit}'
        return "${?}"
      # Failover to 'ifconfig'
      elif command -v ifconfig >/dev/null 2>&1; then
        ifconfig -a |
          sed -e '/^docker/{N;N;d;}' |
          awk '/inet6 / && $2 !~ /::1/ {print $2; exit}' |
          sed 's/addr"//g'
        return "${?}"
      fi
    ;;
    (-4|*)
      # Start with the 'ip' command
      if command -v ip >/dev/null 2>&1; then
        ip -o -4 a show up | awk -F '[ /]' '$2 != "lo" {print $7}'
        return "${?}"
      # Failover to 'ifconfig'
      elif command -v ifconfig >/dev/null 2>&1; then
        ifconfig -a |
          sed -e '/^docker/{N;N;d;}' |
          awk '/inet / && $2 !~ /127.0.0.1/ {print $2; exit}' |
          sed 's/addr"//g'
        return "${?}"
      fi
    
      # If we get to this point, we hope that DNS is working
      if command -v nslookup >/dev/null 2>&1; then
        # Because nslookup exits with 0 even on failure, we test for failure first
        if nslookup "$(hostname)" 2>&1 |
             grep -E "Server failed|SERVFAIL|can't find" >/dev/null 2>&1; then
          printf '%s\n' "Could not determine the local IP address"
          return 1
        else
          # Alt to test:
          # nslookup "$(hostname)" | awk '/^Address/ && !/#/{print $2}'
          nslookup "$(hostname)" |
            awk -F ':' '/Address:/{gsub(/ /, "", $2); print $2}' |
            grep -v "#" |
            sed 's/^ *//g'
          return "${?}"
        fi
      fi

      # If we get to this point, return nothing but a failure code
      return 1
    ;;
  esac
}
