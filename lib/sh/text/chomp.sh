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

[ -n "${_SHELLAC_LOADED_text_chomp+x}" ] && return 0
_SHELLAC_LOADED_text_chomp=1

# @description Remove trailing newlines from a string and print the result.
#
# @arg $@ string The input string
#
# @stdout Input string with trailing newline stripped
# @exitcode 0 Always
str_chomp() {
  local _chomp_str
  _chomp_str="${*}"
  _chomp_str="${_chomp_str%$'\n'}"
  printf -- '%s\n' "${_chomp_str}"
}

# @description Alias for str_chomp.
chomp() {
  str_chomp "${@}"
}
