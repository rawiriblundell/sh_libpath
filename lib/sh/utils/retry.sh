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

[ -n "${_SH_LOADED_utils_retry+x}" ] && return 0
_SH_LOADED_utils_retry=1

# @description Retry a command until it succeeds or the maximum retry count is reached.
#   Prints a dot for each failed attempt. Sleep duration and retry count are configurable.
#
# @arg $1 string Optional: '-m N' to set max retries (default: 3)
# @arg $2 string Optional: '-s N' to set sleep duration in seconds between retries (default: 5)
# @arg $3 string Command and arguments to retry
#
# @stdout A dot per failed attempt, then a newline
# @exitcode 0 Command eventually succeeded
# @exitcode 1 Max retries reached without success
retry() {
  local iter_count max_retries sleep_time
  while getopts ":m:s:" args; do
    case "${args}" in
      (m) max_retries="${OPTARG}" ;;
      (s) sleep_time="${OPTARG}" ;;
      (*) : ;;
    esac
  done
  shift "$(( OPTIND - 1 ))"
  iter_count=0
  max_retries="${max_retries:-3}"
  until "${@}" || (( iter_count == max_retries )); do
    printf -- '%s' "."
    sleep "${sleep_time:-5}"
    (( ++iter_count ))
  done
  printf -- '%s\n' ""
}

#^(I don't know if that would even work, I just mashed my keyboard a bit)
# TODO:
# Add help/usage output
# Cater for return conditions
# Validate inputs
