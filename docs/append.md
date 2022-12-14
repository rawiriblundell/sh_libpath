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

# Append one string to another, export as $append_stdout
# Optionally define a delimiter using '-d|--delimiter'
# e.g.
# Command: str_append -d ':' foo bar
# Output : foo:bar
str_append() {
  case "${1}" in
    (-d|--delimiter)
      _append_delimiter="${2}"
      shift 2
    ;;
  esac
  append_stdout="${1}${_append_delimiter:- }${2}"
  append_rc="${?}"
  unset -v _append_delimiter
  export append_stdout append_rc
}

append() {
  case "${1}" in
    (-d|--delimiter)
      _append_delimiter="${2}"
      shift 2
    ;;
  esac
  append_stdout="${1}${_append_delimiter:- }${2}"
  append_rc="${?}"
  unset -v _append_delimiter
  export append_stdout append_rc
}
