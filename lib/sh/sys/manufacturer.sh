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

case "${OSSTR:-$(uname -s)}" in
  ([lL]inux)
    if nullgrep . /sys/devices/virtual/dmi/id/sys_vendor; then
      sysManufacturer=$(</sys/devices/virtual/dmi/id/sys_vendor)
    elif dmidecode | nullgrep -m 1 "Manufacturer"; then
      sysManufacturer=$(dmidecode | awk -F ':' '/Manufacturer/{print $2; exit}' | trim)
    elif dmidecode | nullgrep -m 1 "Vendor"; then
      sysManufacturer=$(dmidecode | awk -F ':' '/Vendor/{print $2; exit}' | trim)
    else
      sysManufacturer="Generic or unknown"
    fi
  ;;
  (SunOS|solaris)
    # System Manufacturer
    # Possible alternative for x86:
    # prtconf -pv | awk -F ':' '/machine-mfg/{print $2; exit}' | trim
    if iscommand smbios; then
      if smbios -t SMB_TYPE_SYSTEM >/dev/null 2>&1; then
        sysManufacturer=$( \
          smbios -t SMB_TYPE_SYSTEM \
          | grep -E 'Manufacturer|Product' \
          | awk -F ":" '{print $2}' \
          | paste -sd ' ' - \
          | trim)
      fi
    else
      sysManufacturer="Sun Inc"
    fi
  ;;
esac



