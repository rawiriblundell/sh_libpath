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

# Add any number of integers together
# There is a historical 'sum' program, it has long been superseded by now
sum() {
  local param sum
  case "${1}" in
    (-h|--help|--usage)
      {
        printf -- '%s\n' "Usage: sum x y [..z], or pipeline | sum"
        printf -- '\t%s\n' \
          "sum a sequence of integers, input by either positional parameters or STDIN"
      } >&2
      return 0
    ;;
  esac
  if [ ! -t 0 ]; then
    while read -r; do
      case "${REPLY}" in
        (*[!0-9]*) : ;;
        (*) sum=$(( sum + param )) ;;
      esac
    done < "${1:-/dev/stdin}"
    printf -- '%d\n' "${sum}"
    return 0
  fi
  for param in "${@}"; do
    case "${param}" in
      (*[!0-9]*) : ;;
      (*) sum=$(( sum + param )) ;;
    esac
  done
  printf -- '%d\n' "${sum}"
}
