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

_get_ip_parse_ifconfig() {
  case "${OSSTR:-$(uname -s)}" in
    ([lL]inux)      awk -F ':' '/inet addr/{print $2}' ;;
    (SunOS|solaris) awk '/inet/{print $2}' ;;
  esac
}

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

get_ip() {
  case "${1}" in
    (external|public)
      curl -4 ifconfig.io
      curl -6 ifconfig.io
    ;;
    (*)
      # Start with the 'ip' command
      if command -v ip >/dev/null 2>&1; then
        ip -o -4 a show up | awk -F '[ /]' '/brd/{print $7}' | grep -v "127.0.0.1"
        return "$?"
      # Failover to 'ifconfig'
      elif command -v ifconfig >/dev/null 2>&1; then
        ifconfig -a |
          _get_ip_parse_ifconfig |
          awk '{print $1}' |
          grep -v "127.0.0.1"
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
