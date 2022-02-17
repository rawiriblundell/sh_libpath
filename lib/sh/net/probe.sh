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

# A small function to test connectivity to a remote host's port.
# Usage: probe-port [remote host] [port (default: 22)] [tcp/udp (default: tcp)]
probe-port() {
  timeout 1 bash -c "</dev/${3:-tcp}/${1:?No target}/${2:-22}" 2>/dev/null
}

# Use probe-port to test a remote host's ssh connectivity
probe-ssh() {
  probe-port "${1:?No target}" "${2:-22}"
}

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
