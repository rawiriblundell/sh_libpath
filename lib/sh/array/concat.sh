# shellcheck shell=bash

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

[ -n "${_SHELLAC_LOADED_array_concat+x}" ] && return 0
_SHELLAC_LOADED_array_concat=1

# @description Copy a named array to another named array.
#
# @arg $1 string Name of the source array variable.
# @arg $2 string Name of the destination array variable.
#
# @example
#   myarr=( a b c )
#   array_copy myarr copy
#   printf '%s\n' "${copy[@]}"
#   # => a
#   # => b
#   # => c
#
# @exitcode 0 Always
array_copy() {
  local -n _src="${1:?No source array name given}"
  local -n _dst="${2:?No destination array name given}"
  _dst=( "${_src[@]}" )
}

# @description Concatenate one or more named arrays into a destination named array.
#
# @arg $1 string Name of the destination array variable.
# @arg $@ string Names of one or more source array variables to concatenate in.
#
# @example
#   arr1=( a b c )
#   arr2=( d e f )
#   array_concat arr1 arr2
#   printf '%s\n' "${arr1[@]}"
#   # => a
#   # => b
#   # => c
#   # => d
#   # => e
#   # => f
#
# @exitcode 0 Always
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
