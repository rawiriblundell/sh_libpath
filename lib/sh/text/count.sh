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

[ -n "${_SH_LOADED_text_count+x}" ] && return 0
_SH_LOADED_text_count=1

# @description Count the number of non-overlapping occurrences of a substring
#   within a string.
#
# @arg $1 string The string to search within
# @arg $2 string The substring to count
#
# @example
#   str_count "banana" "an"   # => 2
#   str_count "hello" "l"     # => 2
#
# @stdout Integer count of occurrences
# @exitcode 0 Always
str_count() {
  local _str _substr _stripped _count
  _str="${1:?No string given}"
  _substr="${2:?No substring given}"
  _stripped="${_str//"${_substr}"/}"
  _count=$(( (${#_str} - ${#_stripped}) / ${#_substr} ))
  printf -- '%d\n' "${_count}"
}

# @description Count the number of words in a string (split on whitespace).
#
# @arg $@ string The string to count words in
#
# @example
#   str_word_count "hello world foo"   # => 3
#   str_word_count "  spaced  out  "   # => 2
#
# @stdout Integer word count
# @exitcode 0 Always
str_word_count() {
  local _input
  _input="${*}"
  local -a _words
  # shellcheck disable=SC2206
  _words=( ${_input} )
  printf -- '%d\n' "${#_words[@]}"
}
