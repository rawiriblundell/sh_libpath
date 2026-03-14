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

[ -n "${_SH_LOADED_array_remove+x}" ] && return 0
_SH_LOADED_array_remove=1

# Remove all elements matching a value from a named array and reindex.
# Usage: array_remove arr_name element
# Example:
#     $ myarr=( a b c b d )
#     $ array_remove myarr b
#     $ printf '%s\n' "${myarr[@]}"
#     a
#     c
#     d
array_remove() {
  local -n _arr="${1:?No array name given}"
  local _elem
  local -a _new_arr
  local _item
  _elem="${2:?No element given}"
  _new_arr=()
  for _item in "${_arr[@]}"; do
    [[ "${_item}" = "${_elem}" ]] || _new_arr+=( "${_item}" )
  done
  _arr=( "${_new_arr[@]}" )
}
