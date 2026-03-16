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

[ -n "${_SHELLAC_LOADED_utils_confirm+x}" ] && return 0
_SHELLAC_LOADED_utils_confirm=1

# @description Prompt for an interactive yes/no confirmation. Reads a single
#   character; only 'y' or 'Y' returns 0. Supports an optional timeout via
#   -t or --timeout followed by a duration in seconds.
#
# @arg $1 string Optional: '-t' or '--timeout' followed by timeout in seconds
# @arg $2 int Optional: timeout in seconds (when using -t/--timeout)
# @arg $3 string Optional: custom prompt text (default: "Continue")
#
# @exitcode 0 User confirmed with 'y' or 'Y'
# @exitcode 1 Any other input, or timeout expired
confirm() {
  local _confirm_args
  case "${1}" in
    (-t|--timeout)
      _confirm_args=( -t "${2}" )
      set -- "${@:3}"
    ;;
  esac

  read "${_confirm_args[@]}" -rn 1 -p "${*:-Continue} [y/N]? "
  printf -- '%s\n' ""
  case "${REPLY}" in
    ([yY]) return 0 ;;
    (*)    return 1 ;;
  esac
}
