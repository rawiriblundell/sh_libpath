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

[ -n "${_SHELLAC_LOADED_text_contains+x}" ] && return 0
_SHELLAC_LOADED_text_contains=1

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
