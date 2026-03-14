# shellcheck shell=ksh

[ -n "${_SH_LOADED_core_wants+x}" ] && return 0
_SH_LOADED_core_wants=1

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

# @description Source a file only if it exists; silently skip if it does not.
#   Unlike include(), a missing file is not an error. An existing but unreadable
#   or broken file still causes a failure.
#
# @arg $1 string Path to the file to source
#
# @stderr Warning if the file exists but cannot be read or fails to source
# @exitcode 0 File sourced successfully or file does not exist
# @exitcode 1 File exists but is unreadable or failed to source
wants() {
  local _fstarget
  _fstarget="${1:?No target specified}"
  [ -e "${_fstarget}" ] || return

  if [ -r "${_fstarget}" ]; then
    # shellcheck disable=SC1090
    . "${_fstarget}" || {
      printf -- 'wants: %s\n' "Failed to load '${_fstarget}'"
      if [ -t 0 ]; then
        return 1
      else
        exit 1
      fi
    }
  else
    printf -- 'wants: %s\n' "${_fstarget} exists but isn't readable" >&2
    if [ -t 0 ]; then
      return 1
    else
      exit 1
    fi
  fi
}
