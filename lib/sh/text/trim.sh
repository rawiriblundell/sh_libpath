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

# Trim whitespace either side of text
str_trim() {
  LC_CTYPE=C
  _trim_str="${*}"
  while true; do
    trim_stdout="${_trim_str#[[:space:]]}"     # Strip whitespace to the left
    trim_stdout="${trim_stdout%[[:space:]]}"   # Strip whitespace to the right
    [[ "${trim_stdout}" = "${_trim_str}" ]] && break
    _trim_str="${trim_stdout}"
  done
  trim_rc="${?}"
  unset -v _trim_str
  export trim_stdout trim_rc
}

trim() {
  LC_CTYPE=C
  _trim_str="${*}"
  while true; do
    trim_stdout="${_trim_str#[[:space:]]}"     # Strip whitespace to the left
    trim_stdout="${trim_stdout%[[:space:]]}"   # Strip whitespace to the right
    [[ "${trim_stdout}" = "${_trim_str}" ]] && break
    _trim_str="${trim_stdout}"
  done
  trim_rc="${?}"
  unset -v _trim_str
  export trim_stdout trim_rc
}

str_strip() {
  LC_CTYPE=C
  _trim_str="${*}"
  while true; do
    trim_stdout="${_trim_str#[[:space:]]}"     # Strip whitespace to the left
    trim_stdout="${trim_stdout%[[:space:]]}"   # Strip whitespace to the right
    [[ "${trim_stdout}" = "${_trim_str}" ]] && break
    _trim_str="${trim_stdout}"
  done
  trim_rc="${?}"
  unset -v _trim_str
  export trim_stdout trim_rc
}

strip() {
  LC_CTYPE=C
  _trim_str="${*}"
  while true; do
    trim_stdout="${_trim_str#[[:space:]]}"     # Strip whitespace to the left
    trim_stdout="${trim_stdout%[[:space:]]}"   # Strip whitespace to the right
    [[ "${trim_stdout}" = "${_trim_str}" ]] && break
    _trim_str="${trim_stdout}"
  done
  trim_rc="${?}"
  unset -v _trim_str
  export trim_stdout trim_rc
}

