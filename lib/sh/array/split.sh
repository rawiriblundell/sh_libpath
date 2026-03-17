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

[ -n "${_SHELLAC_LOADED_array_split+x}" ] && return 0
_SHELLAC_LOADED_array_split=1

# @description Split a string on a delimiter into a named array.
#   The delimiter must be a single character.
#
# @arg $1 string Name of the array variable.
# @arg $2 string Single-character delimiter.
# @arg $3 string The string to split.
#
# @example
#   array_split myarr , "a,b,c,d"
#   printf '%s\n' "${myarr[@]}"
#   # => a
#   # => b
#   # => c
#   # => d
#
# @exitcode 0 Always
array_split() {
  local -n _arr="${1:?No array name given}"
  local _delim
  local _str
  _delim="${2:?No delimiter given}"
  _str="${3:?No string given}"
  IFS="${_delim}" read -ra _arr <<< "${_str}"
}
