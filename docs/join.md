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

# Join array elements with a delimiter and output a string

# Example usage:

#     ▓▒░$ array_join '|' a b c d
#     a|b|c|d
#     ▓▒░$ array_join '||||' a b c d
#     a||||b||||c||||d
#     ▓▒░$ testarray=( a 'b c' d e )
#     ▓▒░$ array_join ',' "${testarray[@]}"
#     a,b c,d,e

array_join() {
  ((${#})) || return 1
  local -- delim="${1}" str IFS=
  shift 1
  # Flatten the rest to a string, with our delimiter in front of every element
  # e.g ,a,b,c,d
  str="${*/#/${delim}}"
  # Print the string, stripping the leading delimiter
  # e.g. a,b,c,d
  printf -- '%s\n' "${str:${#delim}}"
}
