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

# Basic step-in function for systems that don't have dos2unix
# This simply removes dos line endings using 'tr'
if ! command -v dos2unix >/dev/null 2>&1; then
  dos2unix() {
    # Ensure that no options are supplied in any arg
    for _dos2unix_arg in "${@}"; do
      case "${_dos2unix_arg}" in
        (-*)
          printf -- '%s\n' "This is a simple step-in function, '${_dos2unix_arg}' isn't supported" >&2
          unset -v _dos2unix_arg
          return 1
        ;;
      esac
    done
    unset -v _dos2unix_arg

    # Determine if we are dealing with a file or files
    if (( "${#}" > 0 )); then
      _dos2unix_rc=0
      for _dos2unix_file in "${@}"; do
        if [ ! -w "${_dos2unix_file}" ]; then
          printf -- '%s\n' "Unable to write to '${_dos2unix_file}'" >&2
          (( _dos2unix_rc++ ))
          continue
        fi
        # Make a temporary file
        # TODO: Make this more robust/portable
        # TODO: portably basename the filename first
        _dos2unix_tmp="/tmp/${_dos2unix_file}"

        # Convert the input file to the temp file
        tr -d '\r' "${_dos2unix_file}" > "${_dos2unix_tmp}" || {
          printf -- '%s\n' "Unable to convert '${_dos2unix_file}'" >&2
          (( _dos2unix_rc++ ))
          continue
        }

        # Write it back
        cp "${_dos2unix_tmp}" "${_dos2unix_file}" || {
          printf -- '%s\n' "Unable to write '${_dos2unix_file}'" >&2
          (( _dos2unix_rc++ ))
          continue
        }
        # Remove the temporary file
        rm "${_dos2unix_tmp}" 2>/dev/null
      done
      (( _dos2unix_rc++ > 0 )) && return 1
    # Otherwise we're parsing stdin
    else
      tr -d '\r' -
    fi
  }
fi
