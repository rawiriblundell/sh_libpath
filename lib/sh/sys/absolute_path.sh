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

[ -n "${_SHELLAC_LOADED_sys_absolute_path+x}" ] && return 0
_SHELLAC_LOADED_sys_absolute_path=1

# @description Convert a relative path to an absolute path without using readlink -f.
#   Works for both files and directories that exist on disk. Returns 1 if the path
#   does not exist. Temporarily clears CDPATH to avoid interference.
#
# @arg $1 string Relative or absolute file/directory path
#
# @stdout Absolute path
# @exitcode 0 Success
# @exitcode 1 Path does not exist
get_absolute_path() {
  local _filename

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
}
