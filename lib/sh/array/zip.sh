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

[ -n "${_SHELLAC_LOADED_array_zip+x}" ] && return 0
_SHELLAC_LOADED_array_zip=1

# @description Interleave elements from two arrays, pairing by index.
#   Stops at the shorter array's length.
#
# @arg $1 string Name of the first array variable.
# @arg $2 string Name of the second array variable.
#
# @example
#   keys=( a b c )
#   vals=( 1 2 3 )
#   array_zip keys vals
#   # => a 1
#   # => b 2
#   # => c 3
#
# @stdout Paired elements as space-separated lines.
# @exitcode 0 Always
array_zip() {
  local -n _arr_a="${1:?No first array name given}"
  local -n _arr_b="${2:?No second array name given}"
  local _i _len
  _len="${#_arr_a[@]}"
  (( ${#_arr_b[@]} < _len )) && _len="${#_arr_b[@]}"
  for (( _i = 0; _i < _len; _i++ )); do
    printf -- '%s %s\n' "${_arr_a[_i]}" "${_arr_b[_i]}"
  done
}
