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

[ -n "${_SH_LOADED_text_ltrim+x}" ] && return 0
_SH_LOADED_text_ltrim=1

# @description Strip leading whitespace from a string, exporting the result as $ltrim_stdout.
#
# @arg $@ string The input string
#
# @exitcode 0 Always
str_ltrim() {
  LC_CTYPE=C
  local _ltrim_str
  _ltrim_str="${*}"
  while true; do
    ltrim_stdout="${_ltrim_str#[[:space:]]}"
    [[ "${ltrim_stdout}" = "${_ltrim_str}" ]] && break
    _ltrim_str="${ltrim_stdout}"
  done
  ltrim_rc="${?}"
  export ltrim_stdout ltrim_rc
}

# @description Strip leading whitespace from a string and print the result.
#
# @arg $@ string The input string
#
# @stdout Input string with leading whitespace removed
# @exitcode 0 Always
ltrim() {
  LC_CTYPE=C
  local _ltrim_str
  _ltrim_str="${*}"
  while true; do
    ltrim_stdout="${_ltrim_str#[[:space:]]}"
    [[ "${ltrim_stdout}" = "${_ltrim_str}" ]] && break
    _ltrim_str="${ltrim_stdout}"
  done
  printf -- '%s\n' "${_ltrim_str}"
}
