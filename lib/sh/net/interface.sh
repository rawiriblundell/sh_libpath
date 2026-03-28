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

[ -n "${_SHELLAC_LOADED_net_interface+x}" ] && return 0
_SHELLAC_LOADED_net_interface=1

# @description Get the local IP address of the host. Supports IPv4 (default)
#   and IPv6 via flags. Falls back through 'ip', 'ifconfig', and 'nslookup'.
#   For the public/external IP address, use net_query_ip instead.
#
# @arg $1 string Optional: '-4' for IPv4 (default); '-6' for IPv6
#
# @example
#   net_ip      # => local IPv4 address
#   net_ip -6   # => local IPv6 address
#
# @stdout The IP address(es), one per line
# @exitcode 0 Success
# @exitcode 1 Could not determine address
net_ip() {
  # ifconfig outputs in either of these formats:
  # inet addr:192.168.2.1  Bcast:192.168.1.255  Mask:255.255.255.0
  # inet 172.19.243.193  netmask 255.255.240.0  broadcast 172.19.255.255
  # Both are handled by searching for 'inet' and stripping any 'addr:' prefix.
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

# @description Get the default gateway address. Tries 'ip route', then 'netstat',
#   then 'route' in order. Handles Linux and Solaris differences via OSSTR.
#
# @stdout The default gateway IP address
# @exitcode 0 Always
net_gateway() {
  local _get_gwaddr
  if command -v ip >/dev/null 2>&1; then
    _get_gwaddr=$(ip route show | awk '/^default|^0.0.0.0/{ print $3 }')
  fi
  if [[ -z "${_get_gwaddr}" ]]; then
    case "${OSSTR:-$(uname -s)}" in
      (linux|Linux)
        _get_gwaddr=$(netstat -nrv | awk '/^default|^0.0.0.0/{ print $2; exit }')
      ;;
      (solaris|SunOS)
        _get_gwaddr=$(netstat -nrv | awk '/^default|^0.0.0.0/{ print $3; exit }')
      ;;
    esac
  fi
  if [[ -z "${_get_gwaddr}" ]]; then
    _get_gwaddr=$(route -n | awk '/^default|^0.0.0.0/{ print $2 }')
  fi
  printf -- '%s\n' "${_get_gwaddr}"
}

# @internal Normalise a MAC address to XX-YY-ZZ-AA-BB-CC format (uppercase).
_sanitise_mac_addr() {
  local raw_mac octet
  raw_mac="${1:?No MAC data}"
  for octet in ${raw_mac}; do
    if (( ${#octet} == 1 )); then
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
net_mac() {
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

# @description Find the next available local port by scanning with 'ss'.
#   Starts from a given port and increments until a free port is found.
#
# @arg $1 int Starting port number (default: 9000)
# @arg $2 int Number of ports to scan before giving up (default: 100)
#
# @example
#   net_next_port          # => 9000 (or next available above 9000)
#   net_next_port 8080 50
#
# @stdout The first available port number
# @exitcode 0 An available port was found
# @exitcode 1 No available port found within the scan range
net_next_port() {
  local test_port max_port
  test_port="${1:-9000}"
  # Set an upper bound.  100 cycles should be plenty.
  max_port="$(( test_port + "${2:-100}" ))"
  while true; do
    if (( test_port == max_port )); then
      printf -- '%s\n' "net_next_port: no available port found in range" >&2
      return 1
    fi
    # bash builtins weren't working in WSL2 for me, so I'm using 'ss' here
    # TODO: figure out a more portable way to do this, or multiple methods failing over?
    if ! ss 2>&1 | grep -q "127.0.0.1:${test_port}"; then
      printf -- '%d\n' "${test_port}"
      break
    fi
    (( test_port++ ))
  done
}
