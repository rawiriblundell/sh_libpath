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

# If you ain't first - you're last!

# This function is the match for 'first()' 
# i.e. it prints out the last [n] lines of input, defaulting to 1
last() {
  while (( "${#}" > 0 )); do
    case "${1}" in
      (-[0-9]|[0-9]*) _last_count="${1}"; shift 1 ;;
      (-n)            _last_count="${2}"; shift 2 ;;
      (*)             _last_params="${1}"; shift 1 ;;
    esac
  done

  # Re-build our positional parameters
  # shellcheck disable=SC2086
  set -- ${_last_params}

  # Strip any non-numeric chars from _first_count
  _last_count="$(printf -- '%s\n' "${_last_count}" | sed 's/[^0-9.]//g')"

  # Get the last n lines
  tail -n "${_last_count:-1}" "${@}"

  unset -v _last_count _last_params
}

str_last() {
  while (( "${#}" > 0 )); do
    case "${1}" in
      (-[0-9]|[0-9]*) _last_count="${1}"; shift 1 ;;
      (-n)            _last_count="${2}"; shift 2 ;;
      (*)             _last_params="${1}"; shift 1 ;;
    esac
  done

  # Re-build our positional parameters
  # shellcheck disable=SC2086
  set -- ${_last_params}

  # Strip any non-numeric chars from _first_count
  _last_count="$(printf -- '%s\n' "${_last_count}" | sed 's/[^0-9.]//g')"

  # Get the last n lines
  tail -n "${_last_count:-1}" "${@}"

  unset -v _last_count _last_params
}
