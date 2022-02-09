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

# Basic step-in function for dos2unix
# This simply removes dos line endings using 'sed'
if ! get_command dos2unix; then
  dos2unix() {
    if [[ "${1:0:1}" = '-' ]]; then
      printf -- '%s\n' "This is a simple step-in function, '${1}' isn't supported"
      return 1
    fi
    if [[ -w "${1}" ]]; then
      sed -ie 's/\r//g' "${1}"
    else
      sed -e 's/\r//g' -
    fi
  }
fi
