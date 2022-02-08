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

# Overlay the 'date' command with ordinal suffixes
# This adds a new specifier '%o' which would typically be coupled with '%d'
# Example:
# $ date '+%B %-d'
# February 8
# $ date '+%B %-d%o'
# February 8th
date() {
  case "${@}" in
    (*"%o"*) 
      declare -a args1
      declare -a args2
      while [[ -n "$1" ]]; do
        args2+=("$1")
        if [[ "${1:0:1}" != + ]]; then
          args1+=("$1")
        fi
        shift
      done
      case $(command date +%d "${args1[@]}") in
        (01|21|31) _date_suffix="st";;
        (02|22)    _date_suffix="nd";;
        (03|23)    _date_suffix="rd";;
        (*)        _date_suffix="th";;
      esac
      command date "${args2[@]}" | sed -e "s/%o/${_date_suffix}/g"
    ;;
    (*)
      command date "${@}"
    ;;
  esac
  unset -v _date_suffix
}
