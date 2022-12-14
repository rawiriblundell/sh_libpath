# LIBRARY_NAME

## Description

## Provides
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

rot13 () {
  # If parameter is a file, or stdin is used, action that first
  if [[ -r "${1}" ]]||[[ ! -t 0 ]]; then
    tr a-zA-Z n-za-mN-ZA-M < "${1:-/dev/stdin}"
  # Otherwise, if a parameter is given, rot13 all parameters
  elif [[ "${1}" ]]; then
    tr a-zA-Z n-za-mN-ZA-M <<< "$*"
  # Otherwise, print usage
  else
    printf -- '%s\n' "Usage: rot13 [FILE|STDIN|STRING]"
    return 1
  fi
}
