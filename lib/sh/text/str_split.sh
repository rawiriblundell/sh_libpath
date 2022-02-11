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
# Provenance: https://github.com/rawiriblundell/sh_libpath
# SPDX-License-Identifier: Apache-2.0

# Split a string on a given delimiter (defaults to whitespace splitting)
# and save the output into an array, 'STR_SPLIT[@]'
# Avoiding 'readarray'/'mapfile' intentionally here to increase portability
str_split() {
  STR_SPLIT=()
  case "${1}" in
    (-d|--delimiter)
      _str_split_delim="${2}"
      shift 2
      _str_split_counter=0
      while read -r _str_split_line; do
        STR_SPLIT[$_str_split_counter]="${_str_split_line}"
        _str_split_counter=$(( _str_split_counter + 1 ))
      done < <(printf -- '%s\n' "${*}" | tr "${_str_split_delim}" "\n")
    ;;
    (*) STR_SPLIT=( "${@}" ) ;;
  esac
  export STR_SPLIT
  unset -v _str_split_delim _str_split_counter
}
