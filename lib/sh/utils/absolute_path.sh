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

# Try to convert a relative path to an absolute one
# A slightly adjusted version sourced from
# https://stackoverflow.com/a/23002317
get_absolute_path() {
  _filename="${1:?No filename specified}"
  # Ensure that a customised CDPATH doesn't interfere
  CDPATH=''

  # We only act further if the file actually exists
  [ -e "${_filename}" ] || return 1

  # If it's a directory, print it
  if [ -d "${_filename}" ]; then
    (cd "${_filename}" && pwd)
  elif [ -f "${_filename}" ]; then
    if [[ "${_filename}" = /* ]]; then
      printf -- '%s\n' "${_filename}"
    elif [[ "${_filename}" == */* ]]; then
      (
        cd "${_filename%/*}" >/dev/null 2>&1 || return 1
        printf -- '%s\n' "${PWD:-$(pwd)}/${_filename##*/}"
      )
    else
      printf -- '%s\n' "${PWD:-$(pwd)}/${_filename}"
    fi
  fi
  unset -v _filename
}
