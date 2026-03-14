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

[ -n "${_SH_LOADED_array_fill+x}" ] && return 0
_SH_LOADED_array_fill=1

# Fill a named array with a value repeated n times.
# Usage: array_fill arr_name value n
# Example:
#     $ array_fill myarr x 3
#     $ printf '%s\n' "${myarr[@]}"
#     x
#     x
#     x
array_fill() {
  local -n _arr="${1:?No array name given}"
  local _value _n _i
  _value="${2:?No fill value given}"
  _n="${3:?No count given}"
  _arr=()
  for (( _i = 0; _i < _n; _i++ )); do
    _arr+=( "${_value}" )
  done
}

# Pad a named array to a minimum length by appending a fill value.
# Has no effect if the array is already at or above the minimum length.
# Usage: array_pad arr_name min_length value
# Example:
#     $ myarr=( a b c )
#     $ array_pad myarr 5 x
#     $ printf '%s\n' "${myarr[@]}"
#     a
#     b
#     c
#     x
#     x
array_pad() {
  local -n _arr="${1:?No array name given}"
  local _min_len _value _i
  _min_len="${2:?No minimum length given}"
  _value="${3:?No pad value given}"
  for (( _i = ${#_arr[@]}; _i < _min_len; _i++ )); do
    _arr+=( "${_value}" )
  done
}

# Generate a named array of integers from start to end, with optional step.
# Usage: array_range arr_name start end [step]
# Example:
#     $ array_range myarr 1 5
#     $ printf '%s\n' "${myarr[@]}"
#     1
#     2
#     3
#     4
#     5
array_range() {
  local -n _arr="${1:?No array name given}"
  local _start _end _step _i
  _start="${2:?No start given}"
  _end="${3:?No end given}"
  _step="${4:-1}"
  _arr=()
  for (( _i = _start; _i <= _end; _i += _step )); do
    _arr+=( "${_i}" )
  done
}
