# shellcheck shell=bash

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
# Adapted from adoyle-h/lobash (Apache-2.0) https://github.com/adoyle-h/lobash
# Adapted from hastec-fr/apash (Apache-2.0) https://github.com/hastec-fr/apash

[ -n "${_SHELLAC_LOADED_text_predicates+x}" ] && return 0
_SHELLAC_LOADED_text_predicates=1

# @description Test if a string is empty (zero length).
#
# @arg $1 string The string to test
#
# @exitcode 0 String is empty
# @exitcode 1 String is not empty
str_is_empty() {
  [[ -z "${1}" ]]
}

# @description Test if a string is blank (empty or whitespace only).
#
# @arg $1 string The string to test
#
# @exitcode 0 String is blank
# @exitcode 1 String contains non-whitespace characters
str_is_blank() {
  local _str
  _str="${1}"
  _str="${_str//[[:space:]]/}"
  [[ -z "${_str}" ]]
}

# @description Test if a string starts with a given prefix.
#
# @arg $1 string The string to test
# @arg $2 string The prefix to check for
#
# @exitcode 0 String starts with prefix
# @exitcode 1 String does not start with prefix
str_starts_with() {
  local _str _prefix
  _str="${1:?No string given}"
  _prefix="${2:?No prefix given}"
  [[ "${_str}" = "${_prefix}"* ]]
}

# @description Test if a string ends with a given suffix.
#
# @arg $1 string The string to test
# @arg $2 string The suffix to check for
#
# @exitcode 0 String ends with suffix
# @exitcode 1 String does not end with suffix
str_ends_with() {
  local _str _suffix
  _str="${1:?No string given}"
  _suffix="${2:?No suffix given}"
  [[ "${_str}" = *"${_suffix}" ]]
}

# @description Test if a string contains a given substring.
#
# @arg $1 string The string to test
# @arg $2 string The substring to check for
#
# @exitcode 0 String contains substring
# @exitcode 1 String does not contain substring
str_contains() {
  local _str _substr
  _str="${1:?No string given}"
  _substr="${2:?No substring given}"
  [[ "${_str}" = *"${_substr}"* ]]
}

# @description Test if two strings are equal ignoring case. Requires bash 4+.
#
# @arg $1 string First string
# @arg $2 string Second string
#
# @exitcode 0 Strings are equal (case-insensitive)
# @exitcode 1 Strings are not equal
str_equal_fold() {
  local _a _b
  _a="${1:?No first string given}"
  _b="${2:?No second string given}"
  [[ "${_a,,}" = "${_b,,}" ]]
}

# @description Test whether a string matches a regex pattern (ERE).
#   On success BASH_REMATCH is populated by the shell.
#
# @arg $1 string String to test
# @arg $2 string Extended regex pattern
#
# @example
#   str_match "hello world" "^hello"                             # 0
#   str_match "2024-03-19" "([0-9]{4})-([0-9]{2})-([0-9]{2})"
#   printf '%s\n' "${BASH_REMATCH[1]}"                           # => 2024
#
# @exitcode 0 Match; 1 No match
str_match() {
  [[ "${1:-}" =~ ${2:-} ]]
}

# @description Match a string against a regex and populate a named array with
#   the capture groups (BASH_REMATCH[0..n]).  Requires bash 4.3+ for namerefs.
#
# @arg $1 string String to test
# @arg $2 string Extended regex pattern
# @arg $3 string Name of the caller's array variable to populate
#
# @example
#   str_match_captures "2024-03-19" "([0-9]{4})-([0-9]{2})-([0-9]{2})" parts
#   printf '%s\n' "${parts[1]}"   # => 2024
#   printf '%s\n' "${parts[2]}"   # => 03
#   printf '%s\n' "${parts[3]}"   # => 19
#
# @exitcode 0 Match found and array populated; 1 No match; 2 Missing argument
str_match_captures() {
  local str pattern
  local -n _str_match_out="${3:?str_match_captures: missing array name argument}"
  str="${1:-}"
  pattern="${2:-}"
  _str_match_out=()
  [[ "${str}" =~ ${pattern} ]] || return 1
  _str_match_out=( "${BASH_REMATCH[@]}" )
}

# @description Return 0 if the string is composed only of characters in the given set.
#   An empty string always returns 0. A non-empty string against an empty set returns 1.
#   The character set is used as a bracket expression: e.g. "a-z0-9", "[:alpha:]".
#
# @arg $1 string The string to test
# @arg $2 string Allowed character set (bracket expression)
#
# @example
#   str_contains_only ""     "abc"      # 0 — empty string always passes
#   str_contains_only "abab" "abc"      # 0 — only a, b, c
#   str_contains_only "ab1"  "a-z"      # 1 — digit not in set
#
# @exitcode 0 String contains only characters from the set (or is empty)
# @exitcode 1 String contains characters outside the set, or non-empty with empty set
str_contains_only() {
  local str set
  str="${1:-}"
  set="${2:-}"
  [[ -z "${str}" ]] && return 0
  [[ -n "${str}" && -z "${set}" ]] && return 1
  [[ "${str}" =~ ^[${set}]*$ ]]
}

# @description Return 0 if the string contains only ASCII alphabetic characters (non-empty).
# @arg $1 string String to test
# @exitcode 0 Non-empty and purely alphabetic; 1 otherwise
str_is_alpha() {
  [[ "${1:-}" =~ ^[[:alpha:]]+$ ]]
}

# @description Return 0 if the string contains only ASCII alphanumeric characters (non-empty).
# @arg $1 string String to test
# @exitcode 0 Non-empty and purely alphanumeric; 1 otherwise
str_is_alnum() {
  [[ "${1:-}" =~ ^[[:alnum:]]+$ ]]
}

# @description Return 0 if the string contains only ASCII digit characters (non-empty).
# @arg $1 string String to test
# @exitcode 0 Non-empty and purely decimal digits; 1 otherwise
str_is_digits() {
  [[ "${1:-}" =~ ^[[:digit:]]+$ ]]
}
