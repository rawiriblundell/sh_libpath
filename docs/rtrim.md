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

# Strip whitespace from the right hand side of a string.
# This works by using two vars, constantly removing a single char and re-assigning
# before comparing the two vars.  When they finally do match, all the whitespace
# will be gone, and the loop can exit
str_rtrim() {
  LC_CTYPE=C
  _rtrim_str="${*}"
  while true; do
    rtrim_stdout="${_rtrim_str#[[:space:]]}"
    [[ "${rtrim_stdout}" = "${_rtrim_str}" ]] && break
    _rtrim_str="${rtrim_stdout}"
  done
  rtrim_rc="${?}"
  unset -v _rtrim_str
  export rtrim_stdout rtrim_rc
}

rtrim() {
  LC_CTYPE=C
  _rtrim_str="${*}"
  while true; do
    rtrim_stdout="${_rtrim_str#[[:space:]]}"
    [[ "${rtrim_stdout}" = "${_rtrim_str}" ]] && break
    _rtrim_str="${rtrim_stdout}"
  done
  printf -- '%s\n' "${_rtrim_str}"
  unset -v _rtrim_str
}
