# shellcheck shell=bash

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

[ -n "${_SHELLAC_LOADED_path_dirname+x}" ] && return 0
_SHELLAC_LOADED_path_dirname=1

command -v dirname >/dev/null 2>&1 && return 0

# @description Minimal step-in replacement for 'dirname'. Strips the filename
#   component using parameter expansion. Does not handle dotfiles, tilde, or
#   other edge cases; see source comments for discussion.
#
# @arg $1 string File path
#
# @stdout Directory component of the path
# @exitcode 0 Always
dirname() {
  printf -- '%s\n' "${1%/*}"
}
