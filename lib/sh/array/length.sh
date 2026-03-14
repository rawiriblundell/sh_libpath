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

[ -n "${_SH_LOADED_array_length+x}" ] && return 0
_SH_LOADED_array_length=1

# Print the number of elements in a named array.
# Usage: array_length arr_name
# Example:
#     $ myarr=( a b c )
#     $ array_length myarr
#     3
array_length() {
  local -n _arr="${1:?No array name given}"
  printf -- '%s\n' "${#_arr[@]}"
}

# Count occurrences of a value in a named array.
# Usage: array_count arr_name element
# Example:
#     $ myarr=( a b a c a )
#     $ array_count myarr a
#     3
array_count() {
  local -n _arr="${1:?No array name given}"
  local _elem _item _count
  _elem="${2:?No element given}"
  _count=0
  for _item in "${_arr[@]}"; do
    [[ "${_item}" = "${_elem}" ]] && (( _count++ ))
  done
  printf -- '%s\n' "${_count}"
}

# Print the indices of a named array.
# Usage: array_keys arr_name
# Example:
#     $ myarr=( a b c )
#     $ array_keys myarr
#     0
#     1
#     2
array_keys() {
  local -n _arr="${1:?No array name given}"
  local _i
  for _i in "${!_arr[@]}"; do
    printf -- '%s\n' "${_i}"
  done
}

# Print index:value pairs for all elements in a named array.
# Usage: array_entries arr_name
# Example:
#     $ myarr=( a b c )
#     $ array_entries myarr
#     0:a
#     1:b
#     2:c
array_entries() {
  local -n _arr="${1:?No array name given}"
  local _i
  for _i in "${!_arr[@]}"; do
    printf -- '%s:%s\n' "${_i}" "${_arr[${_i}]}"
  done
}
