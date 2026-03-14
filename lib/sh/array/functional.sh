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

[ -n "${_SH_LOADED_array_functional+x}" ] && return 0
_SH_LOADED_array_functional=1

# Print elements of a named array matching a glob pattern.
# Usage: array_filter arr_name pattern
# Example:
#     $ myarr=( apple banana cherry apricot )
#     $ array_filter myarr 'a*'
#     apple
#     apricot
array_filter() {
  local -n _arr="${1:?No array name given}"
  local _pattern _item
  _pattern="${2:?No pattern given}"
  for _item in "${_arr[@]}"; do
    [[ "${_item}" = ${_pattern} ]] && printf -- '%s\n' "${_item}"
  done
}

# Apply a function to each element of a named array and print the results.
# Usage: array_map arr_name function
# Example:
#     $ upper() { printf -- '%s\n' "${1^^}"; }
#     $ myarr=( hello world )
#     $ array_map myarr upper
#     HELLO
#     WORLD
array_map() {
  local -n _arr="${1:?No array name given}"
  local _fn _item
  _fn="${2:?No function given}"
  for _item in "${_arr[@]}"; do
    "${_fn}" "${_item}"
  done
}

# Reduce a named array to a single value using a binary function.
# The function receives the accumulator as $1 and the current element as $2,
# and must print the new accumulator to stdout.
# If no initial value is given, the first element is used as the accumulator.
# Usage: array_reduce arr_name function [initial]
# Example:
#     $ add() { printf -- '%s\n' "$(( $1 + $2 ))"; }
#     $ myarr=( 1 2 3 4 5 )
#     $ array_reduce myarr add 0
#     15
array_reduce() {
  local -n _arr="${1:?No array name given}"
  local _fn _acc _i _start
  _fn="${2:?No function given}"
  if [[ -n "${3+x}" ]]; then
    _acc="${3}"
    _start=0
  else
    _acc="${_arr[0]}"
    _start=1
  fi
  for (( _i = _start; _i < ${#_arr[@]}; _i++ )); do
    _acc="$("${_fn}" "${_acc}" "${_arr[_i]}")"
  done
  printf -- '%s\n' "${_acc}"
}
