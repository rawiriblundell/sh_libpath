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

[ -n "${_SH_LOADED_core_is+x}" ] && return 0
_SH_LOADED_core_is=1

########## Paths
path_exists() {
  [ -e "${1:-$RANDOM}" ] >/dev/null 2>&1
}

path_is_file() {
  [ -f "${1:-$RANDOM}" ] >/dev/null 2>&1
}

path_is_directory() {
  [ -d "${1:-$RANDOM}" ] >/dev/null 2>&1
}

# TODO: path_is_hardlink()
path_is_symlink() {
  [ -L "${1:-$RANDOM}" ] >/dev/null 2>&1
}

path_is_readable() {
  [ -r "${1:-$RANDOM}" ] >/dev/null 2>&1
}

path_is_writeable() {
  [ -w "${1:-$RANDOM}" ] >/dev/null 2>&1
}

path_is_executable() {
  [ -x "${1:-$RANDOM}" ] >/dev/null 2>&1
}

path_is_absolute() {
  case "${1:-}" in
    (/*) return 0 ;;
    (*)  return 1 ;;
  esac
}

path_is_relative() {
  case "${1:-}" in
    (/*) return 1 ;;
    (*)  return 0 ;;
  esac
}

path_is_empty_dir() {
  [ -d "${1:-$RANDOM}" ] || return 1
  [ -z "$(ls -A -- "${1}")" ]
}

########## Bools
bool_is_false() {
  case "${1:-null}" in
    (1|[fF][aA][lL][sS][eE]|[nN][oO]|[oO][fF][fF]) return 0 ;;
    (''|*)                                         return 1 ;;
  esac
}

bool_is_true() {
  case "${1:-null}" in
    (0|[tT][rR][uU][eE]|[yY][eE][sS]|[oO][nN])     return 0 ;;
    (''|*)                                         return 1 ;;
  esac
}

bool_is_valid() {
  case "${1:-null}" in
    (0|1|[tT][rR][uU][eE]|[fF][aA][lL][sS][eE]|[yY][eE][sS]|[nN][oO]|[oO][nN]|[oO][fF][fF]) return 0 ;;
    (''|*) return 1 ;;
  esac
}

########## Numbers
number_is_float() {
  printf -- '%f' "${1:-null}" >/dev/null 2>&1
}

number_is_integer() {
  # Leading "'" or '"' can be interpreted by %d as octal
  # so we validate our inputs
  case "${1:-null}" in
    ("'"*|\"*) return 1 ;; 
  esac
  printf -- '%d' "${1:-null}" >/dev/null 2>&1
}

is_number() {
  printf -- '%f' "${1:-null}" >/dev/null 2>&1
}

is_integer() {
  number_is_integer "${1}"
}

is_float() {
  number_is_float "${1}"
}

# Test if an integer is odd
number_is_odd() {
  (( (${1:?No number specified} % 2) != 0 ))
}

# Test if an integer is even
number_is_even() {
  (( (${1:?No number specified} % 2) == 0 ))
}

########## Vars
# Test if a given value is a global var, local var (default) or array
var_is_set() {
  [ "${1+x}" = "x" ] && [ "${#1}" -gt "0" ]
  return "${?}"
}

var_is_null() {
  [ "${1+x}" = "x" ] && [ "${#1}" -eq "0" ]
  return "${?}"
}

var_is_blank() {
  [ -z "${1+x}" ] || { [ "${1+x}" = "x" ] && [ "${#1}" -eq "0" ]; }
  return "${?}"
}

var_is_global() {
  export -p | grep "declare -x ${1}=" >/dev/null 2>&1
  return "${?}"
}

var_is_local() {
  declare -p "${1}" 2>/dev/null | grep -- "-- ${1}=" >/dev/null 2>&1
  return "${?}"
}

########## Misc
is_array() {
  declare -p "${1:-$RANDOM}" 2>/dev/null | grep -- "-a ${1:-$RANDOM}=" >/dev/null 2>&1
}

is_command() {
  command -v "${1:-$RANDOM}" >/dev/null 2>&1
}

# Test if a given item is a function and emit a return code
is_function() {
  typeset -f "${1:-grobblegobble}" >/dev/null 2>&1
}

# Are we within a directory that's tracked by git?
is_gitdir() {
  if [ -e .git ]; then
    return 0
  else
    git rev-parse --git-dir 2>&1 | grep -Eq '^.git|/.git'
  fi
}

is_substring() {
  case "${1}" in
    (*"${2}"*)  return 0 ;;
    (''|*)      return 1 ;;
  esac
}

# Are we running interactively?
is_interactive() {
  case "$-" in
    (*i*) return 0 ;;
    (*)   return 1 ;;
  esac
}

# Are we running as root?
is_root() {
  (( ${EUID:-$(id -u)} == 0 ))
}

# Is the current script being sourced rather than executed?
# Caveat: bash-only for now.  Needs more...
is_sourced() {
  [ "${BASH_SOURCE[0]}" != "${0}" ]
}
