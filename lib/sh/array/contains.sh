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

# Simply return 0 or return 1 (i.e. Boolean test)
# if there is an element in the array that contains a pattern
# Usage: array_contains needle haystack
# e.g. array_contains needle "${haystack[@]}"
# This function intentionally uses a subshell
array_contains() (
  _needle="${1:?No search pattern provided}"
  shift 1
  printf -- '%s\n' "${@}" | grep "${_needle}" >/dev/null 2>&1
)

# Find the indexes of elements that contain a pattern
# TODO: This requires a lot of testing
# Known bug: returns '0' if literally anything is given as a second param
# Usage: array_index needle haystack
# e.g. array_index needle "${haystack[@]}"
# This function intentionally uses a subshell
array_index() (
  _needle="${1:?No search pattern provided}"
  shift 1
  # Print every element to its own line
  # Number each line, 0-indexed, printed immediate left, semi-colon delimited
  # Print the first field of any second field pattern matches via 'awk'
  printf -- '%s\n' "${@}" |
    nl -v 0 -w 1 -s';' |
    awk -v pattern="${_needle}" -F ';' '$2 ~ pattern {print $1}'
)

# The below function is more portable than array_index, but slower at scale

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
  #    do_something_with "${tempArray[@]:$(( index + 1 ))}"
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
