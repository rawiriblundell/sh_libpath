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

is() {
  [ "${1}" = "not" ] && shift 1; ! is "${@}"; return "${?}"
  _condition="${1}"; _var_a="${2}"; _var_b="${3}"
  case "${_condition}" in
    (-[bcdefghLnprsStuwxz])
      test "${_condition}" "${_var_a}";       return "${?}"
    ;;
    (command)       command -v "${_var_a}";   return "${?}" ;;
    (file)          [ -f "${_var_a}" ];       return "${?}" ;;
    (dir|directory) [ -d "${_var_a}" ];       return "${?}" ;;
    (link|symlink)  [ -L "${_var_a}" ];       return "${?}" ;;
    (exist|exists)  [ -e "${_var_a}" ];       return "${?}" ;;
    (readable)      [ -r "${_var_a}" ];       return "${?}" ;;
    (writeable)     [ -w "${_var_a}" ];       return "${?}" ;;
    (executable)    [ -x "${_var_a}" ];       return "${?}" ;;
    (unset)         [ -z "${_var_a+x}" ];     return "${?}" ;;
    (set)
      [ "${_var_a+x}" = "x" ] && [ "${#_var_a}" -gt "0" ]
      return "${?}"
    ;;
    (empty|null)
      [ "${_var_a+x}" = "x" ] && [ "${#_var_a}" -eq "0" ]
      return "${?}"
    ;;
    (blank)
      [ -z "${_var_a+x}" ] ||
        {
          [ "${_var_a+x}" = "x" ] && [ "${#_var_a}" -eq "0" ]
        }
      return "${?}"
    ;;
    (number|float)
      echo "${_var_a}" | grep -E '^[-+]?[0-9]+\.[0-9]*$'; return "${?}" ;;
    (int|integer)   [ "${_var_a}" -eq "${_var_a}" ]; return "${?}" ;;
    (substr|substring)
      case "${_var_a}" in
        (*"${_var_b}"*)  return 0 ;;
        (''|*)           return 1 ;;
      esac
      [ -z "$1" ] || { [ -z "${2##*$1*}" ] && [ -n "$2" ];}; return "${?}" ;;
    (true)
      case "${_var_a}" in
        (0|[tT][rR][uU][eE]|[yY][eE][sS]|[oO][nN])     return 0 ;;
        (''|*)                                         return 1 ;;
      esac
    ;;
    (false)
      case "${_var_a}" in
        (1|[fF][aA][lL][sS][eE]|[nN][oO]|[oO][fF][fF]) return 0 ;;
        (''|*)                                         return 1 ;;
      esac
    ;;
  esac > /dev/null 2>&1
  return 1
}
