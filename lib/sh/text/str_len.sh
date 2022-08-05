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

# Make getting a string length a bit more familiar
# for practitioners of other languages
#
# Known issue: some control characters are counted
str_len() {
  case "${1:?No string specified}" in
    (-b|--bytes)
      shift 1
      LANG_orig="${LANG}"; LC_ALL_orig="${LC_ALL}"
      LANG=C; LC_ALL=C;
      str="${*}"
      printf -- '%d\n' "${#str}"
      LANG="${LANG_orig}"; LC_ALL="${LC_ALL_orig}"
    ;;
    ('')
      printf -- '%d\n' "0"
    ;;
    (*)
      str="${*}"
      printf -- '%d\n' "${#str}"
    ;;
  esac
  unset -v str
}

# Make getting a string length a bit more familiar
# for practitioners of other languages
strlen() {
  case "${1:?No string specified}" in
    (-b|--bytes)
      shift 1
      LANG_orig="${LANG}"; LC_ALL_orig="${LC_ALL}"
      LANG=C; LC_ALL=C;
      str="${*}"
      printf -- '%d\n' "${#str}"
      LANG="${LANG_orig}"; LC_ALL="${LC_ALL_orig}"
    ;;
    ('')
      printf -- '%d\n' "0"
    ;;
    (*)
      str="${*}"
      printf -- '%d\n' "${#str}"
    ;;
  esac
  unset -v str
}
