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

[ -n "${_SH_LOADED_array_shift+x}" ] && return 0
_SH_LOADED_array_shift=1

# array_shift <arr_name> [<n>]
# From https://www.reddit.com/r/bash/comments/aj0xm0/quicktip_shifting_arrays/
array_shift() {
  # Create nameref to real array
  local -n arr="$1"
  local n="${2:-1}"
  arr=("${arr[@]:${n}}")
}

# Rotate elements of a named array left by n positions.
# Negative n rotates right.
# Usage: array_rotate arr_name [n]
# Example:
#     $ myarr=( a b c d e )
#     $ array_rotate myarr 2
#     $ printf '%s\n' "${myarr[@]}"
#     c
#     d
#     e
#     a
#     b
array_rotate() {
  local -n _arr="${1:?No array name given}"
  local _n _len
  _n="${2:-1}"
  _len="${#_arr[@]}"
  (( _len == 0 )) && return 0
  (( _n = _n % _len ))
  (( _n < 0 )) && (( _n += _len ))
  _arr=( "${_arr[@]:${_n}}" "${_arr[@]:0:${_n}}" )
}
