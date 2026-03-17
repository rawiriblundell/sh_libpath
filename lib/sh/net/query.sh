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
# Provenance: https://raw.githubusercontent.com/rawiriblundell/dotfiles/master/.bashrc
# SPDX-License-Identifier: Apache-2.0

[ -n "${_SHELLAC_LOADED_net_query+x}" ] && return 0
_SHELLAC_LOADED_net_query=1

# Public IP reflection services (for net_query_ip):
# http https IPv DNS
#            4 6
# y    y     4 6 -   ifconfig.co/
# y    *     4 n -   whatismyip.akamai.com/ # cert may not match
# y    y     4 6 -   icanhazip.com/
# y    y     4 n -   ipinfo.io/ip
# y    y     4 6 -   ifconfig.me/
# y    y     4 n -   echoip.xyz/
# -    -     4 6 y   ns1.google.com. o-o.myaddr.l.google.com. TXT
# -    -     4 6 y   resolver1.opendns.com. myip.opendns.com. A

# @description Query the public/external IP address of this host using a
#   reflection service. For the local IP address, use net_get_ip instead.
#
# @arg $1 string Optional: '-6' for IPv6 (default: IPv4)
#
# @stdout The public IP address
# @exitcode 0 Success
# @exitcode 1 curl failed
net_query_ip() {
  case "${1}" in
    (-6) curl -s -6 ifconfig.io ;;
    (*)  curl -s -4 ifconfig.io ;;
  esac
}

# @description Look up geo and network metadata for an IP address or hostname
#   using ipinfo.io. Requires IPINFO_TOKEN to be set in the environment.
#
# @arg $1 string Optional: '-b' or '--brief' for country code only
# @arg $2 string IP address or hostname to look up (default: caller's public IP)
#
# @example
#   net_query_ipinfo 8.8.8.8
#   net_query_ipinfo --brief 8.8.8.8
#
# @stdout JSON metadata, or 'IP: COUNTRY' in brief mode
# @exitcode 0 Success
# @exitcode 1 IPINFO_TOKEN not set
net_query_ipinfo() {
  local target mode country
  (( "${#IPINFO_TOKEN}" == 0 )) && {
    printf -- '%s\n' "IPINFO_TOKEN not found in the environment" >&2
    return 1
  }
  while (( $# > 0 )); do
    case "${1}" in
      (-b|--brief) mode=brief; shift 1 ;;
      (*)          target="${1}"; shift 1 ;;
    esac
  done
  case "${mode}" in
    (brief)
      country=$(curl -s "https://ipinfo.io/${target}/country?token=${IPINFO_TOKEN}")
      printf -- '%s: %s\n' "${target}" "${country}"
    ;;
    (*)
      curl -s "https://ipinfo.io/${target}?token=${IPINFO_TOKEN}"
    ;;
  esac
}

# @description Return the HTTP status code for a URL.
#
# @arg $1 string URL to query
#
# @stdout HTTP status code (e.g. 200, 404)
# @exitcode 0 curl succeeded
# @exitcode 1 curl failed
net_query_http_code() {
  curl ${CURL_OPTS} --silent --output /dev/null --write-out '%{http_code}' \
    "${1:?No URI specified}"
}

# @description Fetch AS numbers for a given search term from bgpview.io.
#
# @arg $1 string Search term (e.g. organisation name or IP)
#
# @stdout AS numbers, one per line
# @exitcode 0 Always
net_query_as_numbers() {
  curl -s "https://bgpview.io/search/${1:?No search term specified}" |
    awk -F '[><]' '/bgpview.io\/asn/{print $5}'
}

# @description Pull ASN info from riswhois.ripe.net for one or more AS numbers.
#
# @arg $@ string One or more AS numbers
#
# @stdout whois output with blank/comment lines stripped
# @exitcode 0 Always
net_query_asn_attr() {
  local as_num
  for as_num in "${@:?No AS number supplied}"; do
    whois -H -h riswhois.ripe.net -- -F -K -i "${as_num}" | grep -Ev '^$|^%|::'
  done
}

# @description Test basic internet connectivity by attempting a TCP connection
#   to a well-known host (Google Public DNS by default).
#
# @arg $1 string Optional: host to test (default: 8.8.8.8)
# @arg $2 string Optional: port to test (default: 53)
#
# @exitcode 0 Connection succeeded
# @exitcode 1 Connection failed or timed out
net_query_internet() {
  local test_host test_port
  test_host="${1:-8.8.8.8}"
  test_port="${2:-53}"
  timeout 1 bash -c ">/dev/tcp/${test_host}/${test_port}" >/dev/null 2>&1
}

# @description Test connectivity to a remote host's port via bash /dev/tcp or /dev/udp.
#
# @arg $1 string Remote hostname or IP address
# @arg $2 int Port number (default: 22)
# @arg $3 string Protocol: tcp or udp (default: tcp)
#
# @example
#   net_query_port example.com 443
#   net_query_port example.com 53 udp
#
# @exitcode 0 Port is reachable
# @exitcode 1 Port is unreachable or timed out
net_query_port() {
  timeout 1 bash -c "</dev/${3:-tcp}/${1:?No target}/${2:-22}" 2>/dev/null
}
