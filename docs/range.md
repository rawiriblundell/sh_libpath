# FUNCTION_NAME

## Description

## Synopsis

## Options

## Examples

## Output
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

# If 'seq' is available, we simply map to it
# Note:
# Unlike 'seq', 'range' defaults to a 0 start rather than a 1 start
# If three numbers are given, we swap the second and third i.e.
# range [start, stop, step] vs seq [first, increment, last]
if command -v seq >/dev/null 2>&1; then
  range() {
    case "${#}" in
      (0)
        printf -- '%s\n' "Usage: range [last]|[first last]|[first last step]" >&2
        return 1
      ;;
      (1) seq 0 "$(( "${1}" - 1 ))" ;;
      (2) seq "${1}" "${2}" ;;
      (*) seq "${1}" "${3}" "${2}" ;;
    esac
  }
# Otherwise, we provide our own function
else
  range() {
    case "${#}" in
      (0)
        printf -- '%s\n' "Usage: range [last]|[first last]|[first last step]" >&2
        return 1
      ;;
      (1)
        # If only one number is given, we assume 0..n-1
        eval "printf -- '%d\\n' {0.."$(( "${1}" - 1 ))"}"
      ;;
      (2)
        eval "printf -- '%d\\n' {$1..$2}"
      ;;
      (3)
        # First we test if the bash version is 4, if so, use native increment
        if (( BASH_VERSINFO >= 4 )); then
          eval "printf -- '%d\\n' {$1..$2..$3}"
        # Otherwise, use the manual approach
        else
          first="${1}"
          # Simply iterate through in ascending order
          if (( first < $3 )); then
            while (( first <= $3 )); do
              printf -- '%d\n' "${first}"
              first=$(( first + $2 ))
            done
          # or... undocumented feature: descending order!
          elif (( first > $3 )); then
            while (( first >= $3 )); do
              printf -- '%d\n' "${first}"
              first=$(( first - $2 ))
            done
          fi
        fi
      ;;
    esac
  }
fi
