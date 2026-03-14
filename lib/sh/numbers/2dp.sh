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

[ -n "${_SH_LOADED_numbers_2dp+x}" ] && return 0
_SH_LOADED_numbers_2dp=1

# @description Format one or more numbers to two decimal places.
#
# @arg $@ number One or more numeric values
#
# @stdout Each value formatted to two decimal places, one per line
# @exitcode 0 Always
2dp() {
  printf -- '%0.2f\n' "${@}"
}
