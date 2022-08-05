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

# some | pipeline | toarray
# toarray < filename
# toarray -u -> unique elements unsorted
# toarray -s -> sorted
# toarray -su -> sorted and unique

toarray() {
  while (( "${#}" > 0 )); do
    case "${1}" in
      (-u|--unique) _array_unique=true; shift 1 ;;
      (-s|--sorted) _array_sort=true; shift 1 ;;
      (-us|-su)
        _array_unique=true
        _array_sort=true
        shift 1
      ;;
    esac
  done

  if [ "${_array_sort}" = "true" ] && [ "${_array_unique}" = "true" ]; then
    TOARRAY=( $(printf -- '%s\n' "${TOARRAY[@]}" | sort | uniq) )
  fi

  if [ "${_array_unique}" = "true" ]; then
    awk '!s[$0]++'
  fi


}



  while (( "${#}" > 0 )); do
    case "${1}" in
      (-[0-9]|[0-9]*) _last_count="${1}"; shift 1 ;;
      (-n)            _last_count="${2}"; shift 2 ;;
      (*)             _last_params="${1}"; shift 1 ;;
    esac
  done
