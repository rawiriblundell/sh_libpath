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

# TO-DO: differentiate this from trunc() by performing conversions
# e.g. scientific notation to integers
# Additionally, handle base (default 10)

# Usage: int [number]
int() {
  printf -- '%s\n' "${1:?No float given}" | awk -F '.' '{print $1}'
}

is_odd() {
    (( (${1:?No number specified} % 2) != 0 ))
}

is_even() {
    (( (${1:?No number specified} % 2) == 0 ))
}
