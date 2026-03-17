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
# Provenance: https://github.com/rawiriblundell/shellac
# SPDX-License-Identifier: Apache-2.0

[ -n "${_SHELLAC_LOADED_utils_cmd+x}" ] && return 0
_SHELLAC_LOADED_utils_cmd=1

# @description Check whether one or more commands exist in PATH. With -v/--verbose,
#   prints the resolved path of each found command and an error for each missing one.
#   Without -v, suppresses all output and simply returns 0 or 1.
#
# @arg $1 string Optional: '-v' or '--verbose' to print paths and missing-command errors
# @arg $@ string One or more command names to check
#
# @example
#   cmd_check git curl jq
#   cmd_check --verbose git curl jq
#
# @stdout (verbose only) Path of each found command; error message for each missing one
# @exitcode 0 All specified commands were found
# @exitcode 1 One or more commands were not found
cmd_check() {
  local errcount cmd
  case "${1}" in
    (-v|--verbose)
      shift 1
      errcount=0
      for cmd in "${@}"; do
        command -v "${cmd}" ||
          { printf -- '%s\n' "${cmd} not found" >&2; (( ++errcount )); }
      done
      (( errcount == 0 )) && return 0
    ;;
    ('')
      printf -- 'Usage: cmd_check [-v|--verbose] <command> [command...]\n' >&2
      return 0
    ;;
    (*)
      errcount=0
      for cmd in "${@}"; do
        command -v "${cmd}" >/dev/null 2>&1 || (( ++errcount ))
      done
      (( errcount == 0 )) && return 0
    ;;
  esac
  return 1
}

# @description List all commands available in the current shell environment,
#   optionally filtered by one or more search strings. Powered by compgen -c.
#   Pass plain substrings, not glob patterns.
#
# @arg $@ string Optional: one or more substrings to filter the command list
#
# @example
#   cmd_list
#   cmd_list git aws
#
# @stdout Matching command names, one per line
# @exitcode 0 Always
cmd_list() {
  local needle
  case "${1}" in
    ('') compgen -c ;;
    (*)
      for needle in "${@}"; do
        compgen -c | grep "${needle}"
      done
    ;;
  esac
}
