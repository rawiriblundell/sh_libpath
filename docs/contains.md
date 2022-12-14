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

# Functions for testing if an array contains an element

# Boolean test

# index location

# This function looks for a keyword within a simple array (i.e. numerical index)
# and prints out its location (index) within the array if found
# This can then be used for other array manipulation e.g. splitting
# Usage: getArrayIndex keyword array
# e.g. getArrayIndex needle "${haystack[@]}"
getArrayIndex() {
  local searchString="$1"
  shift
  local tempArray=( "$@" )
  # This is how you'd do it with bash-3+
  #for index in "${!tempArray[@]}"; do
  #  if [[ "${tempArray[index]}" = "${searchString}" ]]; then
  #    triggerCommand="${tempArray[@]:$(( index + 1 ))}"
  #  fi
  #done
  # Here's how we do it more portably by iterating through the array
  # This tests each element one-by-one against the keyword,
  # and prints and then breaks if a match is found
  for (( index=0; index<"${#tempArray[@]}"; index++ )); do
    if [[ "${tempArray[index]}" = "${searchString}" ]]; then
      printf '%s\n' "${index}"
      return 0
    fi
  done
  return 1
}
