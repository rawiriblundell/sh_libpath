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

# Sometimes you might want to load a file only if it exists,
# but otherwise it's not critical and your script can move on.
wants() {
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
    unset -v _fstarget
  else
    printf -- 'wants: %s\n' "${_fstarget} exists but isn't readable" >&2
    unset -v _fstarget
    if [ -t 0 ]; then
      return 1
    else
      exit 1
    fi
  fi
}
