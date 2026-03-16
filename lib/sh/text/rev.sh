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
# Provenance: https://raw.githubusercontent.com/rawiriblundell/dotfiles/master/.bashrc
# SPDX-License-Identifier: Apache-2.0

[ -n "${_SHELLAC_LOADED_text_rev+x}" ] && return 0
_SHELLAC_LOADED_text_rev=1

command -v rev >/dev/null 2>&1 && return 0

# @description Step-in replacement for 'rev' on systems that lack it.
#   Reverses the characters in each line of a file, a string argument, or stdin.
#   Cannot accept both piped input and a positional argument simultaneously.
#
# @arg $1 string Optional: file path or string to reverse; reads stdin if omitted
#
# @stdout Each input line with its characters in reverse order
# @exitcode 0 Success
# @exitcode 1 Both piped input and a positional argument were provided
rev() {
  local _i
  local _len
  local _line
  local _rev
  # Check that stdin or $1 isn't empty
  if [[ -t 0 ]] && [[ -z "${1}" ]]; then
    printf -- '%s\n' "Usage:  rev string|file" ""
    printf -- '\t%s\n'  "Reverse the order of characters in STRING or FILE." "" \
      "With no STRING or FILE, read standard input instead." "" \
      "Note: This is a bash function to provide the basic functionality of the command 'rev'"
    return 0
  # Disallow both piping in strings and declaring strings
  elif [[ ! -t 0 ]] && [[ -n "${1}" ]]; then
    printf -- '%s\n' "rev: please select either piping in or declaring a string to reverse, not both." >&2
    return 1
  fi

  # If parameter is a file, or stdin is used, action that first
  if [[ -f "${1}" ]] || [[ ! -t 0 ]]; then
    while read -r; do
      _len=${#REPLY}
      _rev=
      for((_i=_len-1;_i>=0;_i--)); do
        _rev="${_rev}${REPLY:${_i}:1}"
      done
      printf -- '%s\n' "${_rev}"
    done < "${1:-/dev/stdin}"
  # Else, if parameter exists, action that
  elif [[ -n "$*" ]]; then
    _line="${*}"
    _rev=
    _len=${#_line}
    for((_i=_len-1;_i>=0;_i--)); do
      _rev="${_rev}${_line:${_i}:1}"
    done
    printf -- '%s\n' "${_rev}"
  fi
}
