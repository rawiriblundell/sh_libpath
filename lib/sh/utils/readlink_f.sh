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

# Portable version of 'readlink -f' for versions that don't have '-f'

requires readlink

readlink_f() {
  (
    _count=0
    _target="${1:?No target specified}"
    # Ensure that a customised CDPATH doesn't interfere
    CDPATH=''

    # Ensure that target actually exists and is actually a symlink
    [ -e "${_target}" ] || return 1
    [ -L "${_target}" ] || return 1

    while [ -L "${_target}" ]; do
      _target="$(readlink "${_target}")"
      _count=$(( _count + 1 ))
      # This shouldn't be required, but just in case,
      # we ensure that we don't get stuck in an infinite loop
      if [ "${_count}" -gt 20 ]; then
        printf -- '%s\n' "readlink_f error: recursion limit reached" >&2
        return 1
      fi
    done
    cd "$(dirname "${_target}")" >/dev/null 2>&1 || return 1
    printf -- '%s\n' "${PWD%/}/${_target##*/}"
  )
}

