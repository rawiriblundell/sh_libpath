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


# Replace all instances of a match with a replacement
# Usage: str_replace [string] [match] [replacement] [count (defaults to all)]
str_replace() {
  _str_replace_string="${1}"
  _str_replace_match="${2}"
  _str_replace_replacement="${3}"
  _str_replace_count="${4}"

  # TODO: escape all sed special chars in the vars
  # TODO: validate that _str_replace_count is a legit integer

  case "${_str_replace_count}" in
    ('')
      printf -- '%s\n' "${_str_replace_string}" |
        sed "s/${_str_replace_match}/${_str_replace_replacement}/g"
    ;;
    (*)
      _str_replace_i=0
      until (( _str_replace_i == _str_replace_count )); do
        (( _str_replace_i++ ))
        printf -- '%s\n' "${_str_replace_string}" |
          sed "s/${_str_replace_match}/${_str_replace_replacement}/"
      done
      unset -v _str_replace_i
    ;;
  esac

  unset -v _str_replace_string _str_replace_match
  unset -v _str_replace_replacement _str_replace_count
}
