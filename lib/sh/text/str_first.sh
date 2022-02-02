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

# Return the first n lines, defaults to 1
# A convoluted remapping of `head` to set its default behaviour to one line
first() {
  while (( "${#}" > 0 )); do
    case "${1}" in
      ([0-9]*) _first_count="${1}"; shift 1 ;;
      (-n)     _first_count="${2}"; shift 2 ;;
      (*)      _first_params="${1}"; shift 1 ;;
    esac
  done

  # Re-build our positional parameters
  set -- "${_first_params}"

  # Strip any non-numeric chars from _first_count
  _first_count="$(printf -- '%s\n' "${_first_count}" | sed 's/[^0-9.]//g')"

  # Get the first n lines
  head -n "${_first_count:-1}" "${1:--}"

  unset -v _first_count _first_params 
}
