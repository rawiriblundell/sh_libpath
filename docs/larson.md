# FUNCTION_NAME

## Description

## Synopsis

## Options

## Examples

## Output
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

# These functions setup a row of asterisks and then cycle through some text effects
# This gives the 'look' of an animation of sorts - where each asterisk starts dim, 
# then goes bright, then goes dim again, before moving on to its neighbour.

# half_larson scans left to right before starting at the far most left
# full_larson scans left to right and back again right to left

# These functions are named for the guy who developed this effect for the Cylons
# in the original Battlestar Galactica, and for KITT in Knight Rider.

_larson_reset() {
  tput sgr0     # Unset as many things that we've set as possible
  tput cnorm    # Display the cursor again
  printf '%s\n' ""
  exit 0
}

# Try to set things back the way they were, however we exit
trap _larson_reset HUP INT QUIT TERM EXIT

half_larson() {
  progWidth="${1:-3}"
  sleepTime="0.2"
 
  # GNU sleep can handle fractional seconds, non-GNU cannot
  # so we default to 1 second resolution in that scenario
  if ! sleep "${sleepTime}" >/dev/null 2>&1; then
    sleepTime=1
  fi
  
  tput sc                                    # Capture position
  tput civis                                 # Hide cursor
  tput dim                                   # Set base emphasis
  printf '%*s' "${progWidth}" | tr ' ' "*"   # Setup base char width
  while true; do                             # Infinite loop
    tput rc                                  # Return to saved position
    for ((i=0;i<progWidth;i++)); do          # Iterate horizontally
      for em in dim sgr0 bold sgr0 dim; do   # Emphasis sequence
        printf -- '%s' "$(tput "${em}")*"    # Output emphasised char
        sleep "${sleepTime}"                 # Pause for effect
        tput cub1                            # Move left one char
      done
      tput cuf1                              # Move right one char
    done
  done
}

full_larson() {
  progWidth="${1:-3}"
  sleepTime="0.2"
 
  # GNU sleep can handle fractional seconds, non-GNU cannot
  # so we default to 1 second resolution in that scenario
  if ! sleep "${sleepTime}" >/dev/null 2>&1; then
    sleepTime=1
  fi
  
  tput sc                                    # Capture position
  tput civis                                 # Hide cursor
  tput dim                                   # Set base emphasis
  printf '%*s' "${progWidth}" | tr ' ' "*"   # Setup base char width
  while true; do                             # Infinite loop
    tput rc                                  # Return to saved position
    for ((i=0;i<progWidth;i++)); do          # Iterate horizontally
      for em in dim sgr0 bold sgr0 dim; do   # Emphasis sequence
        printf -- '%s' "$(tput "${em}")*"    # Output emphasised char
        sleep "${sleepTime}"                 # Pause for effect
        tput cub1                            # Move left one char
      done
      tput cuf1                              # Move right one char
    done
    tput cub1
    for ((i=progWidth;i>0;i--)); do
      for em in dim sgr0 bold sgr0 dim; do
        printf -- '%s' "$(tput "${em}")*"
        sleep "${sleepTime}"
        tput cub1
      done
      tput cub1
    done
  done
}
