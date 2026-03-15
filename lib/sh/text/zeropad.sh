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

[ -n "${_SHELLAC_LOADED_text_zeropad+x}" ] && return 0
_SHELLAC_LOADED_text_zeropad=1

# @description Right-pad an integer with zeros to reach a minimum length.
#   If the integer is already at or above the target length, it is printed unchanged.
#
# @arg $1 int The integer to pad
# @arg $2 int Optional: target minimum length (default: 3)
#
# @stdout Zero-right-padded integer
# @exitcode 0 Always
zeropad_right() {
  int="${1:?No number provided}"
  len="${2:-3}"

  if (( "${#int}" >= len )); then
    printf -- '%d\n' "${int}"
    return 0
  fi

  # shellcheck disable=SC2183
  printf '%d%0*d\n' "${int}" "$(( len - "${#int}" ))"
}
