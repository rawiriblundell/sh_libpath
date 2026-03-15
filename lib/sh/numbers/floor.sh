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

[ -n "${_SHELLAC_LOADED_numbers_floor+x}" ] && return 0
_SHELLAC_LOADED_numbers_floor=1

# @description Round a float downwards to the nearest integer (truncate fractional part).
#
# @arg $1 float The value to round down
#
# @example
#   floor 3.7   # => 3
#
# @stdout The floor integer value
# @exitcode 0 Always
floor() {
  printf -- '%s\n' "${1:?No float given}" | awk '{print int($0)}'
}
