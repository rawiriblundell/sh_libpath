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

[ -n "${_SH_LOADED_array_contains+x}" ] && return 0
_SH_LOADED_array_contains=1

# Functions for searching and testing array membership

# Test if any element in the array matches a grep regex pattern.
# Passes array elements by value (expand with "${arr[@]}").
# For a nameref-based glob test, see array_some.
# Usage: array_grep needle "${arr[@]}"
# e.g. array_grep '^foo' "${myarr[@]}"
# This function intentionally uses a subshell
array_grep() (
  local _needle
  _needle="${1:?No search pattern provided}"
  shift 1
  printf -- '%s\n' "${@}" | grep "${_needle}" >/dev/null 2>&1
)

# Print the index of the first element that exactly matches a value.
# Returns 1 if not found.
# Usage: array_index arr_name element
# e.g. array_index myarr needle
array_index() {
  local -n _arr="${1:?No array name given}"
  local _elem _i
  _elem="${2:?No element given}"
  for (( _i = 0; _i < ${#_arr[@]}; _i++ )); do
    if [[ "${_arr[_i]}" = "${_elem}" ]]; then
      printf -- '%s\n' "${_i}"
      return 0
    fi
  done
  return 1
}

# Return 0 if any element of a named array matches a glob pattern.
# Usage: array_some arr_name pattern
array_some() {
  local -n _arr="${1:?No array name given}"
  local _pattern _item
  _pattern="${2:?No pattern given}"
  for _item in "${_arr[@]}"; do
    [[ "${_item}" = ${_pattern} ]] && return 0
  done
  return 1
}

# Return 0 if every element of a named array matches a glob pattern.
# Usage: array_every arr_name pattern
array_every() {
  local -n _arr="${1:?No array name given}"
  local _pattern _item
  _pattern="${2:?No pattern given}"
  for _item in "${_arr[@]}"; do
    [[ "${_item}" = ${_pattern} ]] || return 1
  done
  return 0
}

# Print the last index of an element that exactly matches value.
# Usage: array_last_index arr_name element
array_last_index() {
  local -n _arr="${1:?No array name given}"
  local _elem _i _last
  _elem="${2:?No element given}"
  _last=-1
  for (( _i = 0; _i < ${#_arr[@]}; _i++ )); do
    [[ "${_arr[_i]}" = "${_elem}" ]] && _last="${_i}"
  done
  (( _last >= 0 )) || return 1
  printf -- '%s\n' "${_last}"
}

# Print the first element matching a glob pattern.
# Returns 1 if not found.
# Usage: array_find arr_name pattern
array_find() {
  local -n _arr="${1:?No array name given}"
  local _pattern _item
  _pattern="${2:?No pattern given}"
  for _item in "${_arr[@]}"; do
    if [[ "${_item}" = ${_pattern} ]]; then
      printf -- '%s\n' "${_item}"
      return 0
    fi
  done
  return 1
}

# Print the last element matching a glob pattern.
# Usage: array_find_last arr_name pattern
array_find_last() {
  local -n _arr="${1:?No array name given}"
  local _pattern _item _last _found
  _pattern="${2:?No pattern given}"
  _last=''
  _found=0
  for _item in "${_arr[@]}"; do
    if [[ "${_item}" = ${_pattern} ]]; then
      _last="${_item}"
      _found=1
    fi
  done
  (( _found )) || return 1
  printf -- '%s\n' "${_last}"
}


