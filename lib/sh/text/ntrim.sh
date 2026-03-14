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

[ -n "${_SH_LOADED_text_ntrim+x}" ] && return 0
_SH_LOADED_text_ntrim=1

# @description Strip leading and trailing whitespace and compact internal spaces.
#   Exports the result as $ntrim_stdout.
#
# @arg $@ string The input string
#
# @exitcode 0 Always
str_ntrim() {
  LC_CTYPE=C
  ntrim_stdout=$(printf -- '%s' "${*}" | xargs)
  ntrim_rc="${?}"
  export ntrim_stdout ntrim_rc
}

# @description Strip leading and trailing whitespace and compact internal spaces, printing the result.
#
# @arg $@ string The input string
#
# @stdout Trimmed and compacted string
# @exitcode 0 Always
ntrim() {
  LC_CTYPE=C
  printf -- '%s' "${*}" | xargs
}
