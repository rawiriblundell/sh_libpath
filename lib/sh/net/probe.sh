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

[ -n "${_SHELLAC_LOADED_net_probe+x}" ] && return 0
_SHELLAC_LOADED_net_probe=1

# @description Test connectivity to a remote host's port via bash /dev/tcp or /dev/udp.
#
# @arg $1 string Remote hostname or IP address
# @arg $2 int Port number (default: 22)
# @arg $3 string Protocol: tcp or udp (default: tcp)
#
# @example
#   probe_port example.com 443
#   probe_port example.com 53 udp
#
# @exitcode 0 Port is reachable
# @exitcode 1 Port is unreachable or timed out
probe_port() {
  timeout 1 bash -c "</dev/${3:-tcp}/${1:?No target}/${2:-22}" 2>/dev/null
}

# @description Test SSH connectivity to a remote host using probe_port.
#
# @arg $1 string Remote hostname or IP address
# @arg $2 int SSH port (default: 22)
#
# @exitcode 0 SSH port is reachable
# @exitcode 1 SSH port is unreachable or timed out
probe_ssh() {
  probe_port "${1:?No target}" "${2:-22}"
}
