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
# Provenance: https://github.com/rawiriblundell/sh_libpath
# SPDX-License-Identifier: Apache-2.0

# Function to convert a decimal to an ascii character
# See: https://www.ascii-code.com/
chr() {
  local int
  int="${1:?No integer supplied}"
  # Ensure that we have an integer
  case "${int}" in
    (*[!0-9]*) return 1 ;;
  esac
  
  # Ensure int is within the range 32-126
  # If it's less than 32, add 32 to bring it up into range
  (( int < 32 )) && int=$(( int + 32 ))
  
  # If it's greater than 126, divide until it's in range
  if (( int > 126 )); then
    until (( int <= 126 )); do
      int=$(( int / 2 ))
    done
  fi

  # Finally, print our character
  # shellcheck disable=SC2059
  printf "\\$(printf -- '%03o' "${int}")"
}
