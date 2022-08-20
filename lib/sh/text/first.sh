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

# A basic function to return either the first char, column or line of a given input
first() {
  case "${1}" in
    (char)       shift 1; read -r line; printf -- '%.1s' "${line}" ;;
    (col|column) shift 1; awk '{print $1}' "${@}" ;;
    (row|line)   shift 1; head -n 1 "${@}" ;;
    (*)          head -n 1 "${@}" ;;
  esac
}

str_first() {
  case "${1}" in
    (char)       shift 1; read -r line; printf -- '%.1s' "${line}" ;;
    (col|column) shift 1; awk '{print $1}' "${@}" ;;
    (row|line)   shift 1; head -n 1 "${@}" ;;
    (*)          head -n 1 "${@}" ;;
  esac
}
