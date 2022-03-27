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

# This function does something tricky.  It slurps an input into an array.
# It dumps the first n elements (default: 1) to stderr
# It dumps everything after the first element to stdout
# Why?  So that you can parse content while keeping desirable lines untouched
# For example, header lines...

# Example:
#
#     ▓▒░$ df -hP | helmet | grep shm
#     Filesystem      Size  Used Avail Use% Mounted on
#     tmpfs           7.4G  1.2G  6.3G  16% /dev/shm
#     ▓▒░$ df -hP | helmet 2 | grep shm
#     Filesystem      Size  Used Avail Use% Mounted on
#     udev            7.3G     0  7.3G   0% /dev
#     tmpfs           7.4G  1.2G  6.3G  16% /dev/shm

helmet() {
  local count
  if [ "${1}" -eq "${1}" ] 2>/dev/null; then
    count="${1}"
    shift 1
  fi

  count="${count:-1}"

  mapfile -t

  printf -- '%s\n' "${MAPFILE[@]:0:count}" >&2
  printf -- '%s\n' "${MAPFILE[@]:count}"
}
