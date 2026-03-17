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

[ -n "${_SHELLAC_LOADED_array_insert+x}" ] && return 0
_SHELLAC_LOADED_array_insert=1

# @description Insert one or more elements into a named array at a given index.
#   Existing elements at and after the index are shifted right.
#
# @arg $1 string Name of the array variable.
# @arg $2 int Zero-based index at which to insert.
# @arg $@ string One or more elements to insert.
#
# @example
#   myarr=( a b d e )
#   array_insert myarr 2 c
#   printf '%s\n' "${myarr[@]}"
#   # => a
#   # => b
#   # => c
#   # => d
#   # => e
#
# @exitcode 0 Always
array_insert() {
  local -n _arr="${1:?No array name given}"
  local _idx
  local -a _new_arr
  _idx="${2:?No index given}"
  shift 2
  _new_arr=(
    "${_arr[@]:0:${_idx}}"
    "${@}"
    "${_arr[@]:${_idx}}"
  )
  _arr=( "${_new_arr[@]}" )
}
