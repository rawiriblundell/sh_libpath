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

[ -n "${_SHELLAC_LOADED_sys_manufacturer+x}" ] && return 0
_SHELLAC_LOADED_sys_manufacturer=1

# @description Print the system hardware manufacturer.
#   On Linux: tries /sys/devices/virtual/dmi/id/sys_vendor, then dmidecode.
#   On Solaris: tries smbios. Falls back to "Generic or unknown".
#
# @stdout Manufacturer name
# @exitcode 0 Always
get_sysinfo_manufacturer() {
  case "${OSSTR:-$(uname -s)}" in
    ([lL]inux)
      if [[ -s /sys/devices/virtual/dmi/id/sys_vendor ]]; then
        printf -- '%s\n' "$(< /sys/devices/virtual/dmi/id/sys_vendor)"
      elif dmidecode 2>/dev/null | grep -q -m 1 "Manufacturer"; then
        dmidecode 2>/dev/null | awk -F ': ' '/Manufacturer/ { print $2; exit }'
      elif dmidecode 2>/dev/null | grep -q -m 1 "Vendor"; then
        dmidecode 2>/dev/null | awk -F ': ' '/Vendor/ { print $2; exit }'
      else
        printf -- 'Generic or unknown\n'
      fi
    ;;
    (SunOS|solaris)
      if command -v smbios >/dev/null 2>&1 && smbios -t SMB_TYPE_SYSTEM >/dev/null 2>&1; then
        smbios -t SMB_TYPE_SYSTEM |
          awk -F ': ' '/Manufacturer|Product/ { printf "%s ", $2 }' |
          awk '{$1=$1; print}'
      else
        printf -- 'Sun Inc\n'
      fi
    ;;
  esac
}
