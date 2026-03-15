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

[ -n "${_SHELLAC_LOADED_core_is+x}" ] && return 0
_SHELLAC_LOADED_core_is=1

########## Paths
# @description Test whether a path exists (any type).
#
# @arg $1 string Path to test
#
# @exitcode 0 Path exists
# @exitcode 1 Path does not exist
path_exists() {
  [ -e "${1:-$RANDOM}" ] >/dev/null 2>&1
}

# @description Test whether a path is a regular file.
#
# @arg $1 string Path to test
#
# @exitcode 0 Path is a regular file
# @exitcode 1 Path is not a regular file
path_is_file() {
  [ -f "${1:-$RANDOM}" ] >/dev/null 2>&1
}

# @description Test whether a path is a directory.
#
# @arg $1 string Path to test
#
# @exitcode 0 Path is a directory
# @exitcode 1 Path is not a directory
path_is_directory() {
  [ -d "${1:-$RANDOM}" ] >/dev/null 2>&1
}

# TODO: path_is_hardlink()
# @description Test whether a path is a symbolic link.
#
# @arg $1 string Path to test
#
# @exitcode 0 Path is a symlink
# @exitcode 1 Path is not a symlink
path_is_symlink() {
  [ -L "${1:-$RANDOM}" ] >/dev/null 2>&1
}

# @description Test whether a path is readable by the current process.
#
# @arg $1 string Path to test
#
# @exitcode 0 Path is readable
# @exitcode 1 Path is not readable
path_is_readable() {
  [ -r "${1:-$RANDOM}" ] >/dev/null 2>&1
}

# @description Test whether a path is writeable by the current process.
#
# @arg $1 string Path to test
#
# @exitcode 0 Path is writeable
# @exitcode 1 Path is not writeable
path_is_writeable() {
  [ -w "${1:-$RANDOM}" ] >/dev/null 2>&1
}

# @description Test whether a path is executable by the current process.
#
# @arg $1 string Path to test
#
# @exitcode 0 Path is executable
# @exitcode 1 Path is not executable
path_is_executable() {
  [ -x "${1:-$RANDOM}" ] >/dev/null 2>&1
}

# @description Test whether a path is absolute (starts with /).
#
# @arg $1 string Path to test
#
# @exitcode 0 Path is absolute
# @exitcode 1 Path is not absolute
path_is_absolute() {
  case "${1:-}" in
    (/*) return 0 ;;
    (*)  return 1 ;;
  esac
}

# @description Test whether a path is relative (does not start with /).
#
# @arg $1 string Path to test
#
# @exitcode 0 Path is relative
# @exitcode 1 Path is not relative
path_is_relative() {
  case "${1:-}" in
    (/*) return 1 ;;
    (*)  return 0 ;;
  esac
}

# @description Test whether a path is a directory that contains no files.
#
# @arg $1 string Path to test
#
# @exitcode 0 Path is an empty directory
# @exitcode 1 Path is not an empty directory or does not exist
path_is_empty_dir() {
  [ -d "${1:-$RANDOM}" ] || return 1
  [ -z "$(ls -A -- "${1}")" ]
}

########## Bools
# @description Test whether a value represents a boolean false.
#   Accepts: 1, false, no, off (case-insensitive).
#
# @arg $1 string Value to test
#
# @exitcode 0 Value is a recognised false
# @exitcode 1 Value is not a recognised false
bool_is_false() {
  case "${1:-null}" in
    (1|[fF][aA][lL][sS][eE]|[nN][oO]|[oO][fF][fF]) return 0 ;;
    (''|*)                                         return 1 ;;
  esac
}

# @description Test whether a value represents a boolean true.
#   Accepts: 0, true, yes, on (case-insensitive).
#
# @arg $1 string Value to test
#
# @exitcode 0 Value is a recognised true
# @exitcode 1 Value is not a recognised true
bool_is_true() {
  case "${1:-null}" in
    (0|[tT][rR][uU][eE]|[yY][eE][sS]|[oO][nN])     return 0 ;;
    (''|*)                                         return 1 ;;
  esac
}

# @description Test whether a value is any recognised boolean representation.
#   Accepts: 0, 1, true, false, yes, no, on, off (case-insensitive).
#
# @arg $1 string Value to test
#
# @exitcode 0 Value is a valid boolean
# @exitcode 1 Value is not a valid boolean
bool_is_valid() {
  case "${1:-null}" in
    (0|1|[tT][rR][uU][eE]|[fF][aA][lL][sS][eE]|[yY][eE][sS]|[nN][oO]|[oO][nN]|[oO][fF][fF]) return 0 ;;
    (''|*) return 1 ;;
  esac
}

########## Numbers
# @description Test whether a value can be interpreted as a float.
#
# @arg $1 string Value to test
#
# @exitcode 0 Value is a float
# @exitcode 1 Value is not a float
number_is_float() {
  printf -- '%f' "${1:-null}" >/dev/null 2>&1
}

# @description Test whether a value can be interpreted as an integer.
#   Guards against leading quote characters that printf %d treats as octal.
#
# @arg $1 string Value to test
#
# @exitcode 0 Value is an integer
# @exitcode 1 Value is not an integer
number_is_integer() {
  # Leading "'" or '"' can be interpreted by %d as octal
  # so we validate our inputs
  case "${1:-null}" in
    ("'"*|\"*) return 1 ;; 
  esac
  printf -- '%d' "${1:-null}" >/dev/null 2>&1
}

# @description Test whether a value is a number (float or integer). Alias for number_is_float().
#
# @arg $1 string Value to test
#
# @exitcode 0 Value is a number
# @exitcode 1 Value is not a number
is_number() {
  printf -- '%f' "${1:-null}" >/dev/null 2>&1
}

# @description Alias for number_is_integer().
#
# @arg $1 string Value to test
#
# @exitcode 0 Value is an integer
# @exitcode 1 Value is not an integer
is_integer() {
  number_is_integer "${1}"
}

# @description Alias for number_is_float().
#
# @arg $1 string Value to test
#
# @exitcode 0 Value is a float
# @exitcode 1 Value is not a float
is_float() {
  number_is_float "${1}"
}

# @description Test whether an integer is odd.
#
# @arg $1 int Integer to test
#
# @exitcode 0 Number is odd
# @exitcode 1 Number is even
number_is_odd() {
  (( (${1:?No number specified} % 2) != 0 ))
}

# @description Test whether an integer is even.
#
# @arg $1 int Integer to test
#
# @exitcode 0 Number is even
# @exitcode 1 Number is odd
number_is_even() {
  (( (${1:?No number specified} % 2) == 0 ))
}

########## Vars
# @description Test whether a variable is set and non-empty.
#
# @arg $1 string Variable name
#
# @exitcode 0 Variable is set and non-empty
# @exitcode 1 Variable is unset or empty
var_is_set() {
  [ "${1+x}" = "x" ] && [ "${#1}" -gt "0" ]
  return "${?}"
}

# @description Test whether a variable is set but empty (null).
#
# @arg $1 string Variable name
#
# @exitcode 0 Variable is set and empty
# @exitcode 1 Variable is unset or non-empty
var_is_null() {
  [ "${1+x}" = "x" ] && [ "${#1}" -eq "0" ]
  return "${?}"
}

# @description Test whether a variable is unset, or set and empty.
#
# @arg $1 string Variable name
#
# @exitcode 0 Variable is unset or empty
# @exitcode 1 Variable is set and non-empty
var_is_blank() {
  [ -z "${1+x}" ] || { [ "${1+x}" = "x" ] && [ "${#1}" -eq "0" ]; }
  return "${?}"
}

# @description Test whether a variable is exported (global).
#
# @arg $1 string Variable name
#
# @exitcode 0 Variable is exported
# @exitcode 1 Variable is not exported
var_is_global() {
  export -p | grep "declare -x ${1}=" >/dev/null 2>&1
  return "${?}"
}

# @description Test whether a variable is a local (non-exported) variable.
#
# @arg $1 string Variable name
#
# @exitcode 0 Variable is local
# @exitcode 1 Variable is not local
var_is_local() {
  declare -p "${1}" 2>/dev/null | grep -- "-- ${1}=" >/dev/null 2>&1
  return "${?}"
}

########## Misc
# @description Test whether a name refers to an indexed array variable.
#
# @arg $1 string Variable name
#
# @exitcode 0 Variable is an indexed array
# @exitcode 1 Variable is not an indexed array
is_array() {
  declare -p "${1:-$RANDOM}" 2>/dev/null | grep -- "-a ${1:-$RANDOM}=" >/dev/null 2>&1
}

# @description Test whether a name resolves to a command in PATH or as a builtin/function.
#
# @arg $1 string Command name
#
# @exitcode 0 Command exists
# @exitcode 1 Command does not exist
is_command() {
  command -v "${1:-$RANDOM}" >/dev/null 2>&1
}

# @description Test whether a name is a defined shell function.
#
# @arg $1 string Name to test
#
# @exitcode 0 Name is a function
# @exitcode 1 Name is not a function
is_function() {
  typeset -f "${1:-grobblegobble}" >/dev/null 2>&1
}

# @description Test whether the current working directory is inside a git repository.
#
# @exitcode 0 Inside a git repository
# @exitcode 1 Not inside a git repository
is_gitdir() {
  if [ -e .git ]; then
    return 0
  else
    git rev-parse --git-dir 2>&1 | grep -Eq '^.git|/.git'
  fi
}

# @description Test whether the second argument is a substring of the first.
#
# @arg $1 string The string to search within
# @arg $2 string The substring to search for
#
# @exitcode 0 Substring found
# @exitcode 1 Substring not found
is_substring() {
  case "${1}" in
    (*"${2}"*)  return 0 ;;
    (''|*)      return 1 ;;
  esac
}

# @description Test whether the shell is running interactively.
#
# @exitcode 0 Shell is interactive
# @exitcode 1 Shell is not interactive
is_interactive() {
  case "$-" in
    (*i*) return 0 ;;
    (*)   return 1 ;;
  esac
}

# @description Test whether the current process is running as root (EUID 0).
#
# @exitcode 0 Running as root
# @exitcode 1 Not running as root
is_root() {
  (( ${EUID:-$(id -u)} == 0 ))
}

# @description Test whether the current script is being sourced rather than executed.
#   Bash-only; behaviour on other shells is undefined.
#
# @exitcode 0 Script is sourced
# @exitcode 1 Script is being executed directly
is_sourced() {
  [ "${BASH_SOURCE[0]}" != "${0}" ]
}
