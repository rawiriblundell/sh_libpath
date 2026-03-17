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

[ -n "${_SHELLAC_LOADED_sys_serial_number+x}" ] && return 0
_SHELLAC_LOADED_sys_serial_number=1

# @description Print the system serial number.
#   On Linux: tries /sys DMI, dmidecode, lshw, facter; falls back to UUID then
#   hostid. On Solaris: tries sneep, smbios, eeprom, ipmitool, prtfru, hostid.
#   A blank or literal "0" serial is treated as absent and the next fallback tried.
#
# @stdout Serial number string
# @exitcode 0 Always
get_sysinfo_serial() {
  local serial_number

  case "${OSSTR:-$(uname -s)}" in
    ([lL]inux)
      if [[ -s /sys/devices/virtual/dmi/id/product_serial ]]; then
        serial_number="$(< /sys/devices/virtual/dmi/id/product_serial)"
      elif command -v dmidecode >/dev/null 2>&1; then
        serial_number="$(dmidecode 2>/dev/null | awk -F ': ' '/Serial Number/ { print $2; exit }')"
      elif command -v lshw >/dev/null 2>&1; then
        serial_number="$(lshw 2>/dev/null | awk -F ': ' '/serial/ { print $2; exit }')"
      elif command -v facter >/dev/null 2>&1; then
        serial_number="$(facter 2>/dev/null | awk '/serialnumber/ { print $3 }')"
      fi

      # On some virtualised systems the serial may be blank or literally "0";
      # fall back to the system UUID, then hostid.
      if [[ -z "${serial_number}" ]] || [[ "${serial_number}" = "0" ]]; then
        serial_number="$(dmidecode 2>/dev/null | awk -F ': ' '/UUID/ { print $2; exit }')"
        if [[ -z "${serial_number}" ]] || [[ "${serial_number}" = "0" ]]; then
          if command -v hostid >/dev/null 2>&1; then
            serial_number="$(hostid)"
          fi
        fi
      fi
    ;;
    (SunOS|solaris)
      if command -v sneep >/dev/null 2>&1; then
        serial_number="$(sneep)"
      elif smbios -t SMB_TYPE_SYSTEM >/dev/null 2>&1; then
        serial_number="$(smbios -t SMB_TYPE_SYSTEM | awk '/Serial/ { print $3 }')"
        if [[ "${serial_number}" = "0" ]] || [[ -z "${serial_number}" ]]; then
          serial_number="$(smbios -t SMB_TYPE_SYSTEM | awk '/UUID/ { print $2 }')"
        fi
      elif eeprom 2>/dev/null | grep -q ChassisSerialNumber; then
        serial_number="$(eeprom | awk '/ChassisSerialNumber/ { print $3 }')"
      elif ipmitool fru >/dev/null 2>&1; then
        serial_number="$(
          ipmitool fru print |
            grep -E 'Mainboard|/SYS' |
            awk '{ print $7 }' |
            cut -d ')' -f1 |
            awk '/Product Serial/ { print $4 }'
        )"
      elif command -v prtfru >/dev/null 2>&1; then
        serial_number="sneep not found"
      else
        serial_number="$(hostid)"
      fi
    ;;
  esac

  printf -- '%s\n' "${serial_number:-Unknown}"
}
