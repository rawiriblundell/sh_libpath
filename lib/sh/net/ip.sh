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

[ -n "${_SHELLAC_LOADED_net_ip+x}" ] && return 0
_SHELLAC_LOADED_net_ip=1

# ifconfig outputs in either of these formats:
# inet addr:192.168.2.1  Bcast:192.168.1.255  Mask:255.255.255.0
# inet 172.19.243.193  netmask 255.255.240.0  broadcast 172.19.255.255
#
# So we try to cater for both by searching for 'inet' and printing the next
# field with "addr:" stripped.

# @description Get the local IP address of the host. Supports IPv4 (default)
#   and IPv6 via flags. Falls back through 'ip', 'ifconfig', and 'nslookup'.
#   For the public/external IP address, use net_query_ip instead.
#
# @arg $1 string Optional: '-4' for IPv4 (default); '-6' for IPv6
#
# @example
#   net_get_ip      # => local IPv4 address
#   net_get_ip -6   # => local IPv6 address
#
# @stdout The IP address(es), one per line
# @exitcode 0 Success
# @exitcode 1 Could not determine address
net_get_ip() {
  case "${1}" in
    (-6)
      if command -v ip >/dev/null 2>&1; then
        ip -o -6 a show up | awk -F '[ /]' '$2 != "lo" {print $7; exit}'
        return "${?}"
      elif command -v ifconfig >/dev/null 2>&1; then
        ifconfig -a |
          sed -e '/^docker/{N;N;d;}' |
          awk '/inet6 / && $2 !~ /::1/ {print $2; exit}' |
          sed 's/addr://g'
        return "${?}"
      fi
    ;;
    (-4|*)
      if command -v ip >/dev/null 2>&1; then
        ip -o -4 a show up | awk -F '[ /]' '$2 != "lo" {print $7}'
        return "${?}"
      elif command -v ifconfig >/dev/null 2>&1; then
        ifconfig -a |
          sed -e '/^docker/{N;N;d;}' |
          awk '/inet / && $2 !~ /127.0.0.1/ {print $2; exit}' |
          sed 's/addr://g'
        return "${?}"
      fi

      # If we get to this point, we hope that DNS is working
      if command -v nslookup >/dev/null 2>&1; then
        if nslookup "$(hostname)" 2>&1 |
             grep -E "Server failed|SERVFAIL|can't find" >/dev/null 2>&1; then
          printf -- '%s\n' "Could not determine the local IP address" >&2
          return 1
        else
          nslookup "$(hostname)" |
            awk -F ':' '/Address:/{gsub(/ /, "", $2); print $2}' |
            grep -v "#" |
            sed 's/^ *//g'
          return "${?}"
        fi
      fi

      return 1
    ;;
  esac
}
