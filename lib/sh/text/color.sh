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

# Define an array of color numbers for the colors that are
# hardest to see on either a black or white terminal background
BLOCKED_COLORS=(0 1 7 9 11 {15..18} {154..161} {190..197} {226..235} {250..255})

# Define another array that is an inversion of the above
mapfile -t ALLOWED_COLORS < <(printf -- '%d\n' {0..255} "${BLOCKED_COLORS[@]}" | sort -n | uniq -u)

# A function to generate a random color code using the above arrays
text_color_random() {
  local color
  # Define our initial color code
  color=$(( RANDOM % 255 ))
  # Ensure that our color code is an allowed one.  If not, regenerate until it is.
  until printf -- '%d\n' "${ALLOWED_COLORS[@]}" | grep -xq "${color}"; do
    color=$(( RANDOM % 255 ))
  done
  # Emit our selected color number
  printf -- '%d\n' "${color}"
}

# Define some basic colors
COLOR_BLACK='\e[30m'
COLOR_RED='\e[31m'
COLOR_GREEN='\e[32m'
COLOR_YELLOW='\e[33m'
COLOR_BLUE='\e[34m'
COLOR_MAGENTA='\e[35m'
COLOR_CYAN='\e[36m'
COLOR_WHITE='\e[37m'
COLOR_RESET='\e[0m'

# Define some basic text effects
TEXT_BOLD='\e[1m'
TEXT_DIM='\e[2m'
TEXT_ITALIC='\e[3m'
TEXT_UNDERLINE='\e[4m'
TEXT_INVERTED='\e[7m' 
TEXT_RESET='\e[0m'

# Make our variables into constants
readonly COLOR_BLACK COLOR_RED COLOR_GREEN COLOR_YELLOW COLOR_BLUE 
readonly COLOR_MAGENTA COLOR_CYAN COLOR_WHITE COLOR_RESET
readonly TEXT_BOLD TEXT_DIM TEXT_ITALIC TEXT_UNDERLINE TEXT_INVERTED TEXT_RESET
readonly CURSOR_OFF CURSOR_ON

# Export them to the environment
export COLOR_BLACK COLOR_RED COLOR_GREEN COLOR_YELLOW COLOR_BLUE 
export COLOR_MAGENTA COLOR_CYAN COLOR_WHITE COLOR_RESET
export TEXT_BOLD TEXT_DIM TEXT_ITALIC TEXT_UNDERLINE TEXT_INVERTED TEXT_RESET
export CURSOR_OFF CURSOR_ON
