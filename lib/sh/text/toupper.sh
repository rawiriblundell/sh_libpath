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

if (( BASH_VERSINFO >= 4 )); then
  toupper() {
    # If parameter is a file, or stdin is used, action that first
    if [[ -r "${1}" ]]||[[ ! -t 0 ]]; then
      # We structure our while read loop to handle no newline at EOF
      eof=
      while [[ -z "${eof}" ]]; do
        read -r || eof=true
        printf -- '%s\n' "${REPLY^^}"
      done < "${1:-/dev/stdin}"
    # Otherwise, if a parameter exists, modify it
    elif [[ "${1}" ]]; then
      printf -- '%s\n' "${*^^}"
    # Otherwise we print our usage
    else
      printf -- '%s\n' "Usage: toupper [FILE|STDIN|STRING]"
      return 1
    fi
  }
else
  # This is the magic sauce - we convert the input character to a decimal (%d)
  # Then add 32 to move it 32 places on the ASCII table
  # Then we print it in unsigned octal (%o)
  # And finally print the char that matches the octal representation (\\)
  # Example: printf '%d' "'A" => 65 (+32 = 97)
  #          printf '%o' "97" => 141
  #          printf \\141 => a
  uc(){
    # shellcheck disable=SC2059
    case "${1}" in
      ([[:lower:]])
        printf \\"$(printf '%o' "$(( $(printf '%d' "'${1}") - 32 ))")"
      ;;
      (*)
        printf "%s" "${1}"
      ;;
    esac
  }
  toupper() {
    if [[ -r "${1}" ]]||[[ ! -t 0 ]]; then
      eof=
      while [[ -z "${eof}" ]]; do
        read -r || eof=true
        for ((i=0;i<${#REPLY};i++)); do
          uc "${REPLY:$i:1}"
        done
        printf -- '%s\n' ""
      done < "${1:-/dev/stdin}"
    elif [[ "${1}" ]]; then
      output="$*"
      for ((i=0;i<${#output};i++)); do
        uc "${output:$i:1}"
      done
      printf -- '%s\n' ""
    else
      printf -- '%s\n' "Usage: toupper [FILE|STDIN|STRING]"
      return 1
    fi
  }
fi
