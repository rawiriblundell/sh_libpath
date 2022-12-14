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

# Setup our standardised output style functions
# If no performance data is detected (var=value), then default to '-'
printOut() {
  if [[ "$2" == *"="* ]]; then
    printf '%s\n' "$1 ${thisJob} $2" "${@:3}"
  else
    printf '%s\n' "$1 ${thisJob} - $2" "${@:3}"
  fi
}

printAuto() {
  if (( $# == 1 )); then
    printOut P "$*"
  elif (( $# > 1 )); then
    printOut P "$@" | printLong
  fi
}

printOK() {
  if (( $# == 1 )); then
    printOut 0 "$*"
  elif (( $# > 1 )); then
    printOut 0 "$@" | printLong
  fi
}

printWarn() {
  if (( $# == 1 )); then
    printOut 1 "$*"
  elif (( $# > 1 )); then
    printOut 1 "$@" | printLong
  fi
}

printCrit() {
  if (( $# == 1 )); then
    printOut 2 "$*"
  elif (( $# > 1 )); then
    printOut 2 "$@" | printLong
  fi
}

printDebug() {
  if (( $# == 1 )); then
    printOut 3 "$*"
  elif (( $# > 1 )); then
    printOut 3 "$@" | printLong
  fi
}

# This function converts newlines to literal '\n' for multi-line output
printLong() {
  sed -e ':a' -e 'N' -e '$!ba' -e 's/\n/\\n/g'
}
