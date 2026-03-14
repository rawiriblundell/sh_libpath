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

[ -n "${_SH_LOADED_array_split+x}" ] && return 0
_SH_LOADED_array_split=1

# Split a string on a delimiter into a named array.
# Usage: array_split arr_name delimiter string
# Note: delimiter must be a single character.
# Example:
#     $ array_split myarr , "a,b,c,d"
#     $ printf '%s\n' "${myarr[@]}"
#     a
#     b
#     c
#     d
array_split() {
  local -n _arr="${1:?No array name given}"
  local _delim
  local _str
  _delim="${2:?No delimiter given}"
  _str="${3:?No string given}"
  IFS="${_delim}" read -ra _arr <<< "${_str}"
}
