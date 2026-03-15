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

[ -n "${_SH_LOADED_text_rtrim+x}" ] && return 0
_SH_LOADED_text_rtrim=1

# @description Strip trailing whitespace from a string and print the result.
#
# @arg $@ string The input string
#
# @stdout Input string with trailing whitespace removed
# @exitcode 0 Always
str_rtrim() {
  LC_CTYPE=C
  local _rtrim_str _rtrim_tmp
  _rtrim_str="${*}"
  while true; do
    _rtrim_tmp="${_rtrim_str%[[:space:]]}"
    [[ "${_rtrim_tmp}" = "${_rtrim_str}" ]] && break
    _rtrim_str="${_rtrim_tmp}"
  done
  printf -- '%s\n' "${_rtrim_str}"
}

# @description Alias for str_rtrim.
rtrim() {
  str_rtrim "${@}"
}
