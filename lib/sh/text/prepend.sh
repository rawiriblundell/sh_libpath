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

[ -n "${_SH_LOADED_text_prepend+x}" ] && return 0
_SH_LOADED_text_prepend=1

# @description Prepend one string to another, exporting the result as $prepend_stdout.
#   Optionally define a delimiter with -d|--delimiter (defaults to a single space).
#
# @arg $1 string Optional: -d|--delimiter followed by delimiter string
# @arg $2 string The string to prepend
# @arg $3 string The string to prepend to
#
# @example
#   str_prepend -d ':' bar foo  # => prepend_stdout="bar:foo"
#
# @exitcode 0 Always
str_prepend() {
  local _prepend_delimiter
  case "${1}" in
    (-d|--delimiter)
      _prepend_delimiter="${2}"
      shift 2
    ;;
  esac
  prepend_stdout="${1}${_prepend_delimiter:- }${2}"
  prepend_rc="${?}"
  export prepend_stdout prepend_rc
}

# @description Prepend a string to each line of stdin.
#   Accepts input via stdin.
#   Optionally define a delimiter with -d|--delimiter (defaults to a single space).
#
# @arg $1 string Optional: -d|--delimiter followed by delimiter string
# @arg $2 string The string to prepend to each line
#
# @stdout Each stdin line prefixed with the given string and delimiter
# @exitcode 0 Always
prepend() {
  local _prepend_delimiter
  case "${1}" in
    (-d|--delimiter)
      _prepend_delimiter="${2}"
      shift 2
    ;;
  esac
  while read -r; do
    printf -- '%s\n' "${1}${_prepend_delimiter:- }${REPLY}"
  done
}
