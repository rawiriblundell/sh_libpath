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

[ -n "${_SH_LOADED_array_concat+x}" ] && return 0
_SH_LOADED_array_concat=1

# Concatenate one or more named arrays into a destination named array.
# Usage: array_concat dest_arr_name src_arr_name [src_arr_name ...]
# Example:
#     $ arr1=( a b c )
#     $ arr2=( d e f )
#     $ array_concat arr1 arr2
#     $ printf '%s\n' "${arr1[@]}"
#     a
#     b
#     c
#     d
#     e
#     f
array_concat() {
  local -n _dst="${1:?No destination array name given}"
  local _src_name
  shift
  for _src_name in "${@}"; do
    local -n _src="${_src_name}"
    _dst+=( "${_src[@]}" )
    unset -n _src
  done
}
