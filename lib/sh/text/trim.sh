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

str_ltrim() {
  LC_CTYPE=C
  _ltrim_str="${*}"
  while true; do
    ltrim_stdout="${_ltrim_str#[[:space:]]}"
    [[ "${ltrim_stdout}" = "${_ltrim_str}" ]] && break
    _ltrim_str="${ltrim_stdout}"
  done
  ltrim_rc="${?}"
  unset -v _ltrim_str
  export ltrim_stdout ltrim_rc
}

ltrim() {
  LC_CTYPE=C
  _ltrim_str="${*}"
  while true; do
    ltrim_stdout="${_ltrim_str#[[:space:]]}"
    [[ "${ltrim_stdout}" = "${_ltrim_str}" ]] && break
    _ltrim_str="${ltrim_stdout}"
  done
  printf -- '%s\n' "${_ltrim_str}"
  unset -v _ltrim_str
}

# Strip whitespace from both left and right of a string
# Additionally, compact down multiple spaces inside the string
str_ntrim() {
  LC_CTYPE=C
  ntrim_stdout=$(printf -- '%s' "${*}" | xargs)
  ntrim_rc="${?}"
  unset -v _ntrim_str
  export ntrim_stdout ntrim_rc
}

ntrim() {
  LC_CTYPE=C
  printf -- '%s' "${*}" | xargs
}

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
