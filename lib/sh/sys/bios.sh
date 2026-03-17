# shellcheck shell=bash

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

[ -n "${_SHELLAC_LOADED_sys_bios+x}" ] && return 0
_SHELLAC_LOADED_sys_bios=1

# @description Print BIOS vendor, version, and release date as a single line.
#   On Linux: uses dmidecode -t bios. On Solaris: uses prtdiag or smbios.
#
# @stdout Space-separated BIOS info string
# @exitcode 0 Always
get_biosinfo() {
  case "${OSSTR:-$(uname -s)}" in
    ([lL]inux)
      if command -v dmidecode >/dev/null 2>&1; then
        dmidecode -t bios 2>/dev/null |
          awk -F ': ' '/(Vendor|Version|Release Date)/ { printf "%s ", $2 }' |
          awk '{$1=$1; print}'
      fi
    ;;
    (SunOS|solaris)
      if command -v prtdiag >/dev/null 2>&1 && prtdiag >/dev/null 2>&1; then
        prtdiag -v | grep -E '^OBP|^BIOS'
      elif smbios -t SMB_TYPE_BIOS >/dev/null 2>&1; then
        smbios -t SMB_TYPE_BIOS |
          awk -F ': ' '/Vendor|Version|Release/ { printf "%s ", $2 }' |
          awk '{$1=$1; print}'
      else
        printf -- 'unknown\n'
      fi
    ;;
  esac
}
