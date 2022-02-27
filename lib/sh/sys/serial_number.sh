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
    if grep . /sys/devices/virtual/dmi/id/product_serial >/dev/null 2>&1; then
      serialNumber=$(</sys/devices/virtual/dmi/id/product_serial)
    elif command -v dmidecode >/dev/null 2>&1; then
      serialNumber=$(dmidecode | awk -F ':' '/Serial Number/{print $2; exit}' | trim)
    elif command -v lshw >/dev/null 2>&1; then
      serialNumber=$(lshw | awk -F ':' '/serial:/{print $2; exit}')
    elif command -v facter >/dev/null 2>&1; then
      serialNumber=$(facter | awk '/serialnumber/{print $3}')
    fi

    # On some virtualised systems, the Serial Number might be blank or "0",
    # so we can try to use the system UUID instead.  Don't use
    # '[[ "${serialNumber}" -eq 0 ]]; then' for the second test as it can be interpreted as octal/hex!
    if [[ -z "${serialNumber}" ]]|| echo "${serialNumber}" | grep -x "0"; then
      serialNumber=$(dmidecode | awk -F ':' '/UUID/{print $2; exit}' | trim)
      # If at this point, we still don't have anything, try 'hostid'
      if [[ -z "${serialNumber}" ]]|| echo "${serialNumber}" | grep -x "0"; then
        if command -v hostid; then
          serialNumber=$(hostid)
        # Finally fail back to a generic option
        else
          serialNumber="Unknown"
        fi
      fi
    fi
  ;;
  (SunOS|solaris)
    # Serial Number.  Start with 'sneep'
    if command -v sneep >/dev/null 2>&1; then
      serialNumber=$(sneep)
    # Otherwise, we try smbios, first we check the Serial Number field
    elif smbios -t SMB_TYPE_SYSTEM >/dev/null 2>&1; then
      serialNumber=$(smbios -t SMB_TYPE_SYSTEM | awk '/Serial/{print $3}')
      # If that's blank (represented by a '0'), then we try the UUID field
      if [ "${serialNumber}" = 0 ]||[ -z "${serialNumber}" ]; then
        serialNumber=$(smbios -t SMB_TYPE_SYSTEM | awk '/UUID/{print $2}')
      fi
    # Next we try eeprom
    elif eeprom | nullgrep ChassisSerialNumber; then
      serialNumber=$(eeprom | awk '/ChassisSerialNumber/{print $3}')
    # Otherwise, we can try ipmitool (x86).  This is untested
    elif ipmitool fru >/dev/null 2>&1; then
      serialNumber=$(ipmitool fru print |
        grep -E 'Mainboard|/SYS' |
        awk '{print $7}' |
        cut -d ")" -f1 |
        awk '/Product Serial/{print $4}'
      )
    # Alternatively we could make something up based on prtfru (SPARC)
    elif command -v prtfru >/dev/null 2>&1; then
      serialNumber="sneep not found"
    # IF all of that fails, we use 'hostid'
    else
      serialNumber=$(hostid)
    fi
  ;;
esac
