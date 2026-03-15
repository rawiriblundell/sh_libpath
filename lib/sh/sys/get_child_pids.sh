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

[ -n "${_SHELLAC_LOADED_sys_get_child_pids+x}" ] && return 0
_SHELLAC_LOADED_sys_get_child_pids=1

# @description List the PIDs of all direct child processes of a given parent PID.
#   Uses pgrep if available, otherwise falls back to parsing 'ps -e'.
#
# @arg $1 int Parent PID to query
#
# @stdout One PID per line
# @exitcode 0 Always
get_child_pids() {
  local _ppid
  _ppid="${1:?No PPID supplied}"
  if command -v pgrep >/dev/null 2>&1; then
    pgrep -P "${_ppid}"
  else
    ps -e -o pid,ppid | awk -v _ppid="${_ppid}" '$2 == _ppid{print $1}'
  fi
}
