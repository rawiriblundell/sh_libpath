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

[ -n "${_SH_LOADED_array_slice+x}" ] && return 0
_SH_LOADED_array_slice=1

# TODO:
# Pluck out elements between a starting and ending position
# Negative indices?
# Every x element?

# Usage:
# array_slice n arrayname => prints element at position n
# array_slice :n arrayname => prints range of elements from 0 to n
# array_slice ::n arrayname => prints every nth element from 0
# array_slice x:y arrayname => prints range of elements between x and y
# array_slice x:y:z arrayname => prints every zth element beween x and y
array_slice() {
  local _slice_mode _slice_start _slice_end _slice_incr
  _slice_mode=''
  until (( "${#_slice_mode}" > 0 )); do
    if printf -- '%s\n' "${1}" | grep -E -- "^-?[0-9]+$" >/dev/null 2>&1; then
      _slice_mode="single"
      break
    fi
    if printf -- '%s\n' "${1}" | grep -E -- "^:-?[0-9]+$" >/dev/null 2>&1; then
      _slice_mode="inclusive"
      break
    fi
    if printf -- '%s\n' "${1}" | grep -E -- "^::-?[0-9]+$" >/dev/null 2>&1; then
      _slice_mode="inclusive_increment"
      break
    fi
    if printf -- '%s\n' "${1}" | grep -E -- "^-?[0-9]+:-?[0-9]+$" >/dev/null 2>&1; then
      _slice_mode="range"
      break
    fi
    if printf -- '%s\n' "${1}" | grep -E -- "^-?[0-9]+:-?[0-9]+:-?[0-9]+$" >/dev/null 2>&1; then
      _slice_mode="increment"
      break
    fi
    # If there's no matches, we dump the whole array.  Should probably error out instead...
    _slice_mode="all"
  done

  # Read array indicated at $2 into a function internal array _slice_tmp
  # This is pretty dirty... I'd like to know a safer and portable alternative...
  eval "_slice_tmp=( \"\${$2[@]}\" )"

  case "${_slice_mode}" in
    (single)
      printf -- '%s\n' "${_slice_tmp[$1]}"
    ;;
    (inclusive)
      for (( i=0; i<"${1/:/}"; i++ )); do
        printf -- '%s\n' "${_slice_tmp[i]}"
      done
    ;;
    (range)
      _slice_start="${1%:*}"
      _slice_end="${1#*:}"
      for (( i=_slice_start; i<_slice_end; i++ )); do
        printf -- '%s\n' "${_slice_tmp[i]}"
      done
    ;;
    (inclusive_increment)
      _slice_incr="${1/::/}"
      i=0
      while (( i < "${#_slice_tmp}" )); do
        printf -- '%s\n' "${_slice_tmp[i]}"
        i=$(( i + _slice_incr ))
      done
    ;;
    (increment)
      _slice_var1="${1%:*}"
      _slice_var2="${1#*:}"
      i="${_slice_var1%:*}"
      _slice_end="${_slice_var1#*:}"
      _slice_incr="${_slice_var2#*:}"
      while (( i <= _slice_end )); do
        printf -- '%s\n' "${_slice_tmp[i]}"
        i=$(( i + _slice_incr ))
      done
    ;;
    (all)
      printf -- '%s\n' "${_slice_tmp[@]}"
    ;;
  esac
}

# Print the element at index n in a named array (supports negative indices).
# Pass --random as the index to select a random element.
# Usage: array_at arr_name n|--random
# Example:
#     $ myarr=( a b c d e )
#     $ array_at myarr -1
#     e
#     $ array_at myarr --random
#     c
array_at() {
  local -n _arr="${1:?No array name given}"
  local _idx
  case "${2:?No index given}" in
    (--random) (( _idx = RANDOM % ${#_arr[@]} )) ;;
    (*)        _idx="${2}" ;;
  esac
  printf -- '%s\n' "${_arr[${_idx}]}"
}

# Print the first n elements of a named array.
# Usage: array_head arr_name [n]
array_head() {
  local -n _arr="${1:?No array name given}"
  local _n _i
  _n="${2:-1}"
  for (( _i = 0; _i < _n && _i < ${#_arr[@]}; _i++ )); do
    printf -- '%s\n' "${_arr[_i]}"
  done
}

# Print the last n elements of a named array.
# Usage: array_tail arr_name [n]
array_tail() {
  local -n _arr="${1:?No array name given}"
  local _n _start _i
  _n="${2:-1}"
  (( _start = ${#_arr[@]} - _n ))
  (( _start < 0 )) && _start=0
  for (( _i = _start; _i < ${#_arr[@]}; _i++ )); do
    printf -- '%s\n' "${_arr[_i]}"
  done
}
