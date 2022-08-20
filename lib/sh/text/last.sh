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

# If you ain't first - you're last!

# This function is the partner for 'first()' 
# It returns the last line, column or character of a given input
last() {
  case "${1}" in
    (char)       shift 1; read -r line; printf -- '%s' "${line#"${line%?}"}" ;;
    (col|column) shift 1; awk '{print $NF}' "${@}" ;;
    (row|line)   shift 1; tail -n 1 "${@}" ;;
    (*)          tail -n 1 "${@}" ;;
  esac
}

str_last() {
  case "${1}" in
    (char)       shift 1; read -r line; printf -- '%s' "${line#"${line%?}"}" ;;
    (col|column) shift 1; awk '{print $NF}' "${@}" ;;
    (row|line)   shift 1; tail -n 1 "${@}" ;;
    (*)          tail -n 1 "${@}" ;;
  esac
}
