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

[ -n "${_SH_LOADED_text_append+x}" ] && return 0
_SH_LOADED_text_append=1

# @description Append one string to another, exporting the result as $append_stdout.
#   Optionally define a delimiter with -d|--delimiter (defaults to a single space).
#
# @arg $1 string Optional: -d|--delimiter followed by delimiter string
# @arg $2 string First string
# @arg $3 string Second string to append
#
# @example
#   str_append -d ':' foo bar   # => append_stdout="foo:bar"
#   str_append foo bar          # => append_stdout="foo bar"
#
# @exitcode 0 Always
str_append() {
  local _append_delimiter
  case "${1}" in
    (-d|--delimiter)
      _append_delimiter="${2}"
      shift 2
    ;;
  esac
  append_stdout="${1}${_append_delimiter:- }${2}"
  append_rc="${?}"
  export append_stdout append_rc
}

# @description Alias for str_append.
append() {
  local _append_delimiter
  case "${1}" in
    (-d|--delimiter)
      _append_delimiter="${2}"
      shift 2
    ;;
  esac
  append_stdout="${1}${_append_delimiter:- }${2}"
  append_rc="${?}"
  export append_stdout append_rc
}
