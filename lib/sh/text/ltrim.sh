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

str_ltrim() {
  LC_CTYPE=C
  local _ltrim_str
  _ltrim_str="${*}"
  while true; do
    ltrim_stdout="${_ltrim_str#[[:space:]]}"
    [[ "${ltrim_stdout}" = "${_ltrim_str}" ]] && break
    _ltrim_str="${ltrim_stdout}"
  done
  ltrim_rc="${?}"
  export ltrim_stdout ltrim_rc
}

ltrim() {
  LC_CTYPE=C
  local _ltrim_str
  _ltrim_str="${*}"
  while true; do
    ltrim_stdout="${_ltrim_str#[[:space:]]}"
    [[ "${ltrim_stdout}" = "${_ltrim_str}" ]] && break
    _ltrim_str="${ltrim_stdout}"
  done
  printf -- '%s\n' "${_ltrim_str}"
}
