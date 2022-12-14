# LIBRARY_NAME

## Description

## Provides
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

# TODO: Make this more robust, build in validation etc
# This might wind up being a script in its own right rather than a function
carve() {
  read -r count1 delim1 _ count2 delim2 <<< "${@}"
  case "${count1}" in
    ([0-9]*) count1="${count1//[!0-9]/}" ;;
    (first)  count1="1" ;;
    (last)   count1="last" ;;
    (''|*)
      printf -- '%s\n' \
        "Usage: carve SHORT_ORDINAL DELIM1 to SHORT_ORDINAL DELIM2" \
        "Example: carve 2nd '/' to 3rd ':'" \
        "'first' or 'last' can also be used in the short ordinal fields" >&2
    ;;
  esac
  case "${count2}" in
    ([0-9]*) count2="${count1//[!0-9]/}" ;;
    (first)  count2="1" ;;
    (last)   count2="last" ;;
  esac
  while IFS= read -r; do
    case "${count1}" in
      (first) line="${REPLY#*${delim1}}" ;;
      (last)  line="${REPLY##*${delim1}}" ;;
      (*)
        for (( i=0;i<count1;i++ )); do
          (( i == 0 )) && line="${REPLY#*${delim1}}"
          (( i >= 1 )) && line="${line#*${delim1}}"
        done
      ;;
    esac
    case "${count2}" in
      (first) line="${line%%${delim2}*}" ;;
      (last)  line="${line%${delim2}*}" ;;
      (*)
        for (( i=0;i<count2;i++ )); do
          line="${line%%${delim2}*}"
        done
      ;;
    esac
    printf -- '%s\n' "${line}"
  done
}
