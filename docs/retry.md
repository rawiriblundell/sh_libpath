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

retry() {
  local iter_count max_retries sleep_time
  while getopts ":m:s:" args; do
    case "${args}" in
      (m) max_retries="${OPTARG}" ;;
      (s) sleep_time="${OPTARG}" ;;
      (*) : ;;
    esac
  done
  shift "$(( OPTIND - 1 ))"
  iter_count=0
  max_retries="${max_retries:-3}"
  until "${@}" || (( iter_count == max_retries )); do
    printf -- '%s' "."
    sleep "${sleep_time:-5}"
    (( ++iter_count ))
  done
  printf -- '%s\n' ""
}

#^(I don't know if that would even work, I just mashed my keyboard a bit)
# TODO:
# Add help/usage output
# Cater for return conditions
# Validate inputs
