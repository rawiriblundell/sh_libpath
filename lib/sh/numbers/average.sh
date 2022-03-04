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

average() {
  case "${#}" in
    (0)
      # Assume stdin
      awk '{ total += $1; count++ } END { print total/count }'
    ;;
    (1)
      # Assume a file
      awk '{ total += $1; count++ } END { print total/count }' "${1}"
    ;;
    (*)
      # Assume params to average
      printf -- '%s\n' "${@}" | awk '{ total += $1; count++ } END { print total/count }'
    ;;
  esac
}
