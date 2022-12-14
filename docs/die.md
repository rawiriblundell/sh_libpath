# FUNCTION_NAME

## Description

## Synopsis

## Options

## Examples

## Output
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

# Get the top level PID and setup a trap so that we can call die() within subshells
trap "exit 1" TERM
_self_pid="${$}"
export _self_pid

# Function to print an error message and exit
die() {
  if [ -t 0 ]; then
    printf '\e[31;1m====>%s\e[0m\n' "${0}:(${LINENO}): ${*}" >&2
  else
    printf -- '====>%s\n' "${0}:(${LINENO}): ${*}" >&2
  fi
  # Send a TERM signal to the top level PID, this is trapped and exit 1 is forced
  kill -s TERM "${_self_pid}"
}

Or in a terser form:

# shellcheck disable=SC2059
die() {
  [ -t 0 ] && _diefmt='\e[31;1m====>%s\e[0m\n'
  printf "${_diefmt:-====>%s\n}" "${0}:(${LINENO}): ${*}" >&2
  # Send a TERM signal to the top level PID, this is trapped and exit 1 is forced
  kill -s TERM "${_self_pid}"
}

With datestamps and [ERROR] tags:

die() {
  if [ -t 0 ]; then
    printf '\e[31;1m====>[%s] %s [ERROR]: %s\e[0m\n' "$(date +%s)" "${0}:${LINENO}" "${*}" >&2
  else
    printf -- '====>[%s] %s [ERROR]: %s\n' "$(date +%s)" "${0}:${LINENO}" "${*}" >&2
  fi
  # Send a TERM signal to the top level PID, this is trapped and exit 1 is forced
  kill -s TERM "${_self_pid}"
}
