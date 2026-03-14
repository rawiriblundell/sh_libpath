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
# Provenance: https://raw.githubusercontent.com/rawiriblundell/dotfiles/master/.bashrc
# SPDX-License-Identifier: Apache-2.0

[ -n "${_SH_LOADED_utils_basename+x}" ] && return 0
_SH_LOADED_utils_basename=1

# Note that this has its edge cases, and to completely functionalise basename/dirname is a bit more involved.
# Example discussions: 
# https://unix.stackexchange.com/questions/253524/dirname-and-basename-vs-parameter-expansion
# https://stackoverflow.com/questions/22401091/bash-variable-substitution-vs-dirname-and-basename

if ! command -v basename >/dev/null 2>&1; then
  # @description Minimal step-in replacement for 'basename'. Strips the leading
  #   directory path from a filename using parameter expansion. Does not support
  #   the suffix-stripping second argument.
  #
  # @arg $1 string File path
  #
  # @stdout Filename component only
  # @exitcode 0 Always
  basename() {
    printf -- '%s\n' "${1##*/}"
  }
fi
