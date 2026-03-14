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
