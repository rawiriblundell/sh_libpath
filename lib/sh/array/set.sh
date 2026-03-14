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

[ -n "${_SH_LOADED_array_set+x}" ] && return 0
_SH_LOADED_array_set=1

# Print elements present in arr_a but not in arr_b.
# Usage: array_diff arr_a arr_b
# Example:
#     $ arr1=( a b c d )
#     $ arr2=( b d e )
#     $ array_diff arr1 arr2
#     a
#     c
array_diff() {
  local -n _arr_a="${1:?No first array name given}"
  local -n _arr_b="${2:?No second array name given}"
  local -A _seen
  local _item
  _seen=()
  for _item in "${_arr_b[@]}"; do
    _seen["${_item}"]=1
  done
  for _item in "${_arr_a[@]}"; do
    [[ -z "${_seen[${_item}]+x}" ]] && printf -- '%s\n' "${_item}"
  done
}

# Print elements present in both arr_a and arr_b.
# Usage: array_intersect arr_a arr_b
# Example:
#     $ arr1=( a b c d )
#     $ arr2=( b d e )
#     $ array_intersect arr1 arr2
#     b
#     d
# Remove duplicate elements from a named array in place, preserving order.
# Usage: array_unique arr_name
# Example:
#     $ myarr=( a b a c b d )
#     $ array_unique myarr
#     $ printf '%s\n' "${myarr[@]}"
#     a
#     b
#     c
#     d
array_unique() {
  local -n _arr="${1:?No array name given}"
  local -A _seen
  local -a _new_arr
  local _item
  _seen=()
  _new_arr=()
  for _item in "${_arr[@]}"; do
    if [[ -z "${_seen[${_item}]+x}" ]]; then
      _seen["${_item}"]=1
      _new_arr+=( "${_item}" )
    fi
  done
  _arr=( "${_new_arr[@]}" )
}

array_intersect() {
  local -n _arr_a="${1:?No first array name given}"
  local -n _arr_b="${2:?No second array name given}"
  local -A _seen
  local _item
  _seen=()
  for _item in "${_arr_b[@]}"; do
    _seen["${_item}"]=1
  done
  for _item in "${_arr_a[@]}"; do
    [[ -n "${_seen[${_item}]+x}" ]] && printf -- '%s\n' "${_item}"
  done
}
