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

# Spinner, a wholly aesthetic spinning cursor!
# Use like so:
# begin_spinner &
# SpinPID="${!}"
# [start a long running task]
# end_spinner "${1:-$?}"
begin_spinner() {
  SpinChars='/-\|'
  printf -- "%s" "Processing ${Host}, this might take a while... [ "
  tput sc
  while true; do
    printf -- '\b%.1s' "${SpinChars}"
    SpinChars=${SpinChars#?}${SpinChars%???}
    tput rc
    sleep 1
  done
}

end_spinner() {
  kill "${SpinPID}"
  wait "${SpinPID}" 2>/dev/null

  # Handle the task's exit code
  case "${1}" in
    (0)   printf -- '%s\n' "] ${txtGrn}Task finished successfully ${txtRst}" ;;
    (1)   printf -- '%s\n' "] ${txtRed}Task failed! ${txtRst}" ;;
    (2)   printf -- '%s\n' "] ${txtRed}Unable to connect! ${txtRst}" ;;
    (124) printf -- '%s\n' "] ${txtRed}Task timed out! ${txtRst}" ;;
    (*)   printf -- '%s\n' "] ${txtRed}Unknown failure encountered ${txtRst}" ;;
  esac
}
