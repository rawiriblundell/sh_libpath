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

[ -n "${_SH_LOADED_array_append+x}" ] && return 0
_SH_LOADED_array_append=1

# @description Append one or more elements to a named array.
#
# @arg $1 string Name of the array variable.
# @arg $@ string One or more elements to append.
#
# @example
#   myarr=( a b c )
#   array_append myarr d e
#   printf '%s\n' "${myarr[@]}"
#   # => a
#   # => b
#   # => c
#   # => d
#   # => e
#
# @exitcode 0 Always
array_append() {
  local -n _arr="${1:?No array name given}"
  shift
  _arr+=( "${@}" )
}
