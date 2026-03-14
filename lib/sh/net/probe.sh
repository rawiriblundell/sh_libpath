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
# Provenance: https://raw.githubusercontent.com/rawiriblundell/dotfiles/master/.bashrc
# SPDX-License-Identifier: Apache-2.0

[ -n "${_SH_LOADED_net_probe+x}" ] && return 0
_SH_LOADED_net_probe=1

# @description Test connectivity to a remote host's port via bash /dev/tcp or /dev/udp.
#
# @arg $1 string Remote hostname or IP address
# @arg $2 int Port number (default: 22)
# @arg $3 string Protocol: tcp or udp (default: tcp)
#
# @example
#   probe-port example.com 443
#   probe-port example.com 53 udp
#
# @exitcode 0 Port is reachable
# @exitcode 1 Port is unreachable or timed out
probe-port() {
  timeout 1 bash -c "</dev/${3:-tcp}/${1:?No target}/${2:-22}" 2>/dev/null
}

# @description Test SSH connectivity to a remote host using probe-port.
#
# @arg $1 string Remote hostname or IP address
# @arg $2 int SSH port (default: 22)
#
# @exitcode 0 SSH port is reachable
# @exitcode 1 SSH port is unreachable or timed out
probe-ssh() {
  probe-port "${1:?No target}" "${2:-22}"
}

# @description Check whether a remote port is open, trying telnet, nc, or nmap
#   in that order. Exits with an error if none are available.
#
# @arg $1 string Remote hostname or IP address
# @arg $2 int Port number
#
# @exitcode 0 Port is open
# @exitcode 1 Port is closed, unreachable, or no tool found
portcheck() {
  # Ensure that $1 and $2 are present
  if [[ -z $2 ]]||[[ -z $1 ]]; then
    printf "%s\n" "ERROR - server or port not defined" \
      "Usage: portcheck [remote servername or IP] [port to check]"
    exit 1
  fi

  # Now run through a list of potential ways to do this
  if command -v telnet >/dev/null 2>&1; then
    ... # you'd have to build in some timeout logic
  elif command -v nc > /dev/null 2>&1; then
    # Or you could check for netcat if you can ensure portable behaviour
    nc -z -w 1 "$1" "$2"
  elif command -v nmap >/dev/null 2>&1; then
    ... # You can also do this check with nmap
  else
    printf "%s\n" "ERROR - could not determine a method for checking ports"
    exit 1
  fi
}
