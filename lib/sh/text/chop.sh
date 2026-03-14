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

[ -n "${_SH_LOADED_text_chop+x}" ] && return 0
_SH_LOADED_text_chop=1

# Remove the last n characters from a string.
# Defaults to removing 1 character (Perl chop semantics).
# Usage: str_chop [-n count] string
# Example:
#     $ str_chop "hello,"
#     hello
#     $ str_chop -n 3 "hello..."
#     hello
str_chop() {
  local _n _input
  _n=1
  case "${1}" in
    (-n) _n="${2:?str_chop -n requires a count}"; shift 2 ;;
  esac
  _input="${*}"
  printf -- '%s\n' "${_input:0:$(( ${#_input} - _n ))}"
}

# Convenience alias
chop() {
  str_chop "${@}"
}
