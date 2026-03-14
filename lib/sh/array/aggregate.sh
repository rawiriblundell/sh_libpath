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

[ -n "${_SH_LOADED_array_aggregate+x}" ] && return 0
_SH_LOADED_array_aggregate=1

# Sum all numeric elements in a named array.
# Usage: array_sum arr_name
array_sum() {
  local -n _arr="${1:?No array name given}"
  local _item _total
  _total=0
  for _item in "${_arr[@]}"; do
    (( _total += _item ))
  done
  printf -- '%s\n' "${_total}"
}

# Print the minimum numeric value in a named array.
# Usage: array_min arr_name
array_min() {
  local -n _arr="${1:?No array name given}"
  local _item _min
  _min="${_arr[0]}"
  for _item in "${_arr[@]}"; do
    (( _item < _min )) && _min="${_item}"
  done
  printf -- '%s\n' "${_min}"
}

# Print the maximum numeric value in a named array.
# Usage: array_max arr_name
array_max() {
  local -n _arr="${1:?No array name given}"
  local _item _max
  _max="${_arr[0]}"
  for _item in "${_arr[@]}"; do
    (( _item > _max )) && _max="${_item}"
  done
  printf -- '%s\n' "${_max}"
}

# Multiply all numeric elements in a named array.
# Usage: array_product arr_name
array_product() {
  local -n _arr="${1:?No array name given}"
  local _item _total
  _total=1
  for _item in "${_arr[@]}"; do
    (( _total *= _item ))
  done
  printf -- '%s\n' "${_total}"
}
