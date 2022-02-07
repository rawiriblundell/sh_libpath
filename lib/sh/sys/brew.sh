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

brew_is_installed() {
  local failcount
  failcount=0
  if ! command -v brew >/dev/null 2>&1; then
    printf -- '%s\n' "This script requires brew on a mac.  This wasn't found..." >&2
    exit 1
  fi
  for brew_pkg in ${*:?Package unspecified}; do
    if brew list | grep -w "${brew_pkg}" >/dev/null 2>&1; then
      printf -- '%s\n' "${brew_pkg} appears to be installed"
    else
      printf -- '%s\n' "${brew_pkg} is not installed"
      (( failcount++ ))
    fi
  done
  (( failcount > 0 )) && return 1
}
