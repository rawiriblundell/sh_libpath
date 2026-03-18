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

[ -n "${_SHELLAC_LOADED_numbers_format+x}" ] && return 0
_SHELLAC_LOADED_numbers_format=1

# @description Format one or more numbers to two decimal places.
#
# @arg $@ number One or more numeric values
#
# @stdout Each value formatted to two decimal places, one per line
# @exitcode 0 Always
num_2dp() {
  printf -- '%0.2f\n' "${@}"
}

# @description Right-pad an integer with zeros to reach a minimum length.
#   If the integer is already at or above the target length, it is printed unchanged.
#
# @arg $1 int The integer to pad
# @arg $2 int Optional: target minimum length (default: 3)
#
# @stdout Zero-right-padded integer
# @exitcode 0 Always
num_zeropad_right() {
  local _int _len
  _int="${1:?No number provided}"
  _len="${2:-3}"

  if (( "${#_int}" >= _len )); then
    printf -- '%d\n' "${_int}"
    return 0
  fi

  printf -- '%d%0*d\n' "${_int}" "$(( _len - "${#_int}" ))" 0
}
