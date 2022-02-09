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

# Functionalise 'command -v' to allow 'if get_command [command]' idiom
get_command() {
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
      printf -- '%s\n' "get_command [-v|--verbose] list of commands" \
        "get_command will emit return code 1 if any listed command is not found" >&2
      return 0
    ;;
    (*)
      errcount=0
      for cmd in "${@}"; do
        command -v "${1}" >/dev/null 2>&1 || (( ++errcount ))
      done
      (( errcount == 0 )) && return 0
    ;;
  esac
  # If we get to this point, we've failed
  return 1
}
