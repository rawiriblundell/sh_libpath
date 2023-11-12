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

# Prepend one string to another, export as $prepend_stdout
# Optionally define a delimiter using '-d|--delimiter'
# e.g.
# Command: str_prepend -d ':' bar foo
# Output : foo:bar
str_prepend() {
  local _prepend_delimiter
  case "${1}" in
    (-d|--delimiter)
      _prepend_delimiter="${2}"
      shift 2
    ;;
  esac
  prepend_stdout="${1}${_prepend_delimiter:- }${2}"
  prepend_rc="${?}"
  export prepend_stdout prepend_rc
}

prepend() {
  local _prepend_delimiter
  case "${1}" in
    (-d|--delimiter)
      _prepend_delimiter="${2}"
      shift 2
    ;;
  esac
  while read -r; do
    printf -- '%s\n' "${1}${_prepend_delimiter:- }${REPLY}"
  done
}
