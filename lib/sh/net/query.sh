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
