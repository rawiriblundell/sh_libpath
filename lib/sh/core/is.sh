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
    (int|integer)
      case "${1#[-+]}" in 
        (''|*[!0-9]*) return 1 ;;
      esac
      return 0
    ;;
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

# Test if a given item is a function and emit a return code
is_function() {
  [[ $(type -t "${1:-grobblegobble}") = function ]]
}

# Are we within a directory that's tracked by git?
is_gitdir() {
  if [[ -e .git ]]; then
    return 0
  else
    git rev-parse --git-dir 2>&1 | grep -Eq '^.git|/.git'
  fi
}

# Test if a given value is an integer
# To ensure that we fail on floats (i.e. in ksh),
# we ensure that one side of the test is an int
is_integer() {
  [ "${1%%.*}" -eq "${1}" ] 2>/dev/null
}

# Test if a given value is a global var, local var (default) or array
is_set() {
  case "${1}" in
    (-a|-array)
      declare -p "${2}" 2>/dev/null | grep -- "-a ${2}=" >/dev/null 2>&1
      return "${?}"
    ;;
    (-g|-global)
      export -p | grep "declare -x ${2}=" >/dev/null 2>&1
      return "${?}"
    ;;
    (-h|--help|"")
      printf -- '%s\n' "Function to test whether NAME is declared" \
        "Usage: is_set [-a(rray)|-l(ocal var)|-g(lobal var)|-h(elp)] NAME" \
        "If no option is supplied, NAME is tested as a local var"
      return 0
    ;;
    (-l|-local)
      declare -p "${2}" 2>/dev/null | grep -- "-- ${2}=" >/dev/null 2>&1
      return "${?}"
    ;;
    (*)
      declare -p "${1}" 2>/dev/null | grep -- "-- ${1}=" >/dev/null 2>&1
      return "${?}"
    ;;
  esac
}
