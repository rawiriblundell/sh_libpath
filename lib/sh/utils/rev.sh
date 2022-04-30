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

# Check if 'rev' is available, if not, enable a stop-gap function
if ! command -v rev >/dev/null 2>&1; then
  rev() {
    # Check that stdin or $1 isn't empty
    if [[ -t 0 ]] && [[ -z "${1}" ]]; then
      printf -- '%s\n' "Usage:  rev string|file" ""
      printf -- '\t%s\n'  "Reverse the order of characters in STRING or FILE." "" \
        "With no STRING or FILE, read standard input instead." "" \
        "Note: This is a bash function to provide the basic functionality of the command 'rev'"
      return 0
    # Disallow both piping in strings and declaring strings
    elif [[ ! -t 0 ]] && [[ -n "${1}" ]]; then
      printf -- '%s\n' "[ERROR] rev: Please select either piping in or declaring a string to reverse, not both."
      return 1
    fi

    # If parameter is a file, or stdin in used, action that first
    if [[ -f "${1}" ]]||[[ ! -t 0 ]]; then
      while read -r; do
        len=${#REPLY}
        rev=
        for((i=len-1;i>=0;i--)); do
          rev="$rev${REPLY:$i:1}"
        done
        printf -- '%s\n' "${rev}"
      done < "${1:-/dev/stdin}"
    # Else, if parameter exists, action that
    elif [[ -n "$*" ]]; then
      Line=$*
      rev=
      len=${#Line}
      for((i=len-1;i>=0;i--)); do 
        rev="$rev${Line:$i:1}"
      done
      printf -- '%s\n' "${rev}"
    fi
  }
fi
