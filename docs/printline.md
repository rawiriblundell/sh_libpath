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

# A function to print a specific line from a file
# TO-DO: Update it to handle globs e.g. 'printline 4 *'
printline() {
  # Fail early: We require sed
  if ! command -v sed >/dev/null 2>&1; then
    printf -- '%s\n' "[ERROR] printline: This function depends on 'sed' which was not found." >&2
    return 1
  fi

  # If $1 is empty, print a usage message
  # Otherwise, check that $1 is a number, if it isn't print an error message
  # If it is, blindly convert it to base10 to remove any leading zeroes
  case "${1}" in
    (''|-h|--help|--usage|help|usage)
      printf -- '%s\n' "Usage:  printline n [file]" ""
      printf -- '\t%s\n' "Print the Nth line of FILE." "" \
        "With no FILE or when FILE is -, read standard input instead."
      return 0
    ;;
    (*[!0-9]*)
      printf -- '%s\n' "[ERROR] printline: '${1}' does not appear to be a number." "" \
        "Run 'printline' with no arguments for usage." >&2
      return 1
    ;;
    (*) local lineNo="$((10#${1})){p;q;}" ;;
  esac

  # Next, we handle $2.  First, we check if it's a number, indicating a line range
  if (( "${2}" )) 2>/dev/null; then
    # Stack the numbers in lowest,highest order
    if (( "${2}" > "${1}" )); then
      lineNo="${1},$((10#${2}))p;$((10#${2}+1))q;"
    else
      lineNo="$((10#${2})),${1}p;$((${1}+1))q;"
    fi
    shift 1
  fi

  # Otherwise, we check if it's a readable file
  if [[ -n "${2}" ]]; then
    if [[ ! -r "${2}" ]]; then
      printf -- '%s\n' "[ERROR] printline: '$2' does not appear to exist or I can't read it." "" \
        "Run 'printline' with no arguments for usage." >&2
      return 1
    else
      local file="${2}"
    fi
  fi

  # Finally after all that testing and setup is done
  sed -ne "${lineNo}" -e "\$s/.*/[ERROR] printline: End of stream reached./" -e '$ w /dev/stderr' "${file:-/dev/stdin}"
}
