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

# Print word pairs separated by delimiters e.g.
# Title1.........Page1
# Longer Title...Page2
# TODO: Add ability to customise width and delimiter
str_padding() {
  _str_padding_width="${COLUMNS:-$(tput cols)}"
  case "${1}" in
    (-w|--width)
      _str_padding_width="${2}"
      if (( _str_padding_width > "${COLUMNS:-$(tput cols)}" )); then
        _str_padding_width="${COLUMNS:-$(tput cols)}"
      fi
      shift 2
    ;;
  esac
  _str_padding_key="${1}"
  _str_padding_val="${2}"
  _str_padding_width=$(( _str_padding_width - "${#_str_padding_key}" ))
  _str_padding_width=$(( _str_padding_width - "${#_str_padding_val}" ))
  _str_padding="$(printf -- '%*s' "${_str_padding_width}" | tr ' ' '.')"
  printf "%s%s%s\n" "${_str_padding_key}" "${_str_padding}" "${_str_padding_val}"
  unset -v _str_padding _str_padding_key _str_padding_val _str_padding_width
}
