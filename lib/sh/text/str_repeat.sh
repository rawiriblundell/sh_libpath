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

# Repeat a string n number of times
# Supports '-n' to suppress newlines while iterating
str_repeat() {
  case "${1}" in
    (-n) _str_repeat_newlines=no; shift 1 ;;
  esac
  _str_repeat_newlines="${_str_repeat_newlines:-yes}"
  _str_repeat_str="${1:?No string specified}"
  _str_repeat_count="${2:-1}"

  case "${_str_repeat_newlines}" in
    (yes)
      for (( i=0; i<_str_repeat_count; ++i )); do
        printf -- '%s\n' "${_str_repeat_str}"
      done
    ;;
    (no)
      for (( i=0; i<_str_repeat_count; ++i )); do
        printf -- '%s' "${_str_repeat_str}"
      done
      printf -- '%s\n' ""
    ;;
    (*)
      printf -- 'str_repeat: %s\n' "Unspecified error" >&2
      return 1
    ;;
  esac

  unset -v _str_repeat_str _str_repeat_count _str_repeat_newlines
}
