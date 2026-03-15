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

[ -n "${_SH_LOADED_args_scan_opts+x}" ] && return 0
_SH_LOADED_args_scan_opts=1

# @description Scan a list of arguments for a given flag or word.
#   Returns 0 if found, 1 if not found.  Handles short flags (-v),
#   long flags (--verbose), and plain words.
#
# @arg $1 string The flag or word to search for
# @arg $@ string The arguments to scan (pass "$@" from the caller)
#
# @example
#   scan_opts --verbose "$@"
#   scan_opts -v "$@"
#   scan_opts debug "$@"
#
# @exitcode 0 Flag/word found
# @exitcode 1 Flag/word not found
scan_opts() {
  local _target
  _target="${1:?No flag or word given}"
  shift

  local _arg
  for _arg in "${@}"; do
    [[ "${_arg}" = "${_target}" ]] && return 0
  done
  return 1
}
