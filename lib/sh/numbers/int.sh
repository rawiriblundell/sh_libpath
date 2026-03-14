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

[ -n "${_SH_LOADED_numbers_int+x}" ] && return 0
_SH_LOADED_numbers_int=1

# TODO: differentiate this from trunc() by performing conversions
# e.g. scientific notation to integers
# Additionally, handle base (default 10)

# @description Strip the fractional part from a number, returning the integer portion.
#
# @arg $1 float The value to truncate
#
# @stdout Integer portion of the value
# @exitcode 0 Always
int() {
  printf -- '%s\n' "${1:?No float given}" | awk -F '.' '{print $1}'
}

# @description Test whether an integer is odd.
#
# @arg $1 int Integer to test
#
# @exitcode 0 Number is odd
# @exitcode 1 Number is even
is_odd() {
    (( (${1:?No number specified} % 2) != 0 ))
}

# @description Test whether an integer is even.
#
# @arg $1 int Integer to test
#
# @exitcode 0 Number is even
# @exitcode 1 Number is odd
is_even() {
    (( (${1:?No number specified} % 2) == 0 ))
}
