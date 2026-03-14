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

[ -n "${_SH_LOADED_text_wrap+x}" ] && return 0
_SH_LOADED_text_wrap=1

# @description Format a long command into multi-line with vertically aligned backslash continuations.
#   Each flag/option starting with ' -' is placed on its own line, indented by two spaces.
#   Backslash continuations are right-aligned to the longest line.
#
# @arg $@ string The command string to wrap
#
# @example
#   wrap_code_block aws s3api copy-object --bucket foo --key bar
#
# @stdout Multi-line command with aligned backslash continuations
# @exitcode 0 Always
wrap_code_block() {
  # Search for a leading space and a dash, to capture ` -a` and `--arg` style options
  # Replace with a newline and two space indentation, slurp each line into an array
  mapfile -t < <(sed 's/ -/\n  -/g' <<< "${*}")

  # Get the length of the longest line
  right_bound=$(for element in "${MAPFILE[@]}"; do printf -- '%d\n' "${#element}"; done | sort -n | tail -n 1)

  # Pad it
  right_bound=$(( right_bound + 2 ))

  # Generate our output
  for (( i=0; i<"${#MAPFILE[@]}"; i++ )); do
    if (( i == ("${#MAPFILE[@]}" - 1) )); then
      printf -- '%s\n' "${MAPFILE[i]}"
    else
      printf -- '%s%*s%s\n' "${MAPFILE[i]}" $(( right_bound - "${#MAPFILE[i]}" )) '\'
    fi
  done
}

