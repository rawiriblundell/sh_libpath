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

# Check if 'seq' is available, if not, provide a basic replacement function
if ! command -v seq >/dev/null 2>&1; then
  seq() {
    local first
    # If no parameters are given, print out usage
    if [[ -z "$*" ]]; then
      printf -- '%s\n' "Usage:"
      printf -- '\t%s\n'  "seq LAST" \
        "seq FIRST LAST" \
        "seq FIRST INCR LAST" \
        "Note: this is a step-in function, no args are supported."
      return 0
    fi
    
    # If only one number is given, we assume 1..n
    if [[ -z "${2}" ]]; then
      eval "printf -- '%d\\n' {1..$1}"
    # Otherwise, we act accordingly depending on how many parameters we get
    # This runs with a default increment of 1/-1 for two parameters
    elif [[ -z "${3}" ]]; then
      eval "printf -- '%d\\n' {$1..$2}"
    # and with three parameters we use the second as our increment
    elif [[ -n "${3}" ]]; then
      # First we test if the bash version is 4, if so, use native increment
      if (( BASH_VERSINFO >= 4 )); then
        eval "printf -- '%d\\n' {$1..$3..$2}"
      # Otherwise, use the manual approach
      else
        first="${1}"
        # Simply iterate through in ascending order
        if (( first < $3 )); then
          while (( first <= $3 )); do
            printf -- '%d\n' "${first}"
            first=$(( first + $2 ))
          done
        # or... undocumented feature: descending order!
        elif (( first > $3 )); then
          while (( first >= $3 )); do
            printf -- '%d\n' "${first}"
            first=$(( first - $2 ))
          done
        fi
      fi
    fi
  }
fi
