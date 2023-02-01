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
    if iscommand dmidecode; then
      sys_bios=$(dmidecode | grep -m 1 -A 2 Vendor | awk -F ':' '{print $2}' | paste -sd '' - | trim)
    fi
  ;;
  (SunOS|solaris)
    # BIOS Version
    if iscommand prtdiag; then
      if prtdiag >/dev/null 2>&1; then
        sys_bios=$(prtdiag -v | grep -E '^OBP|^BIOS')
      fi
    elif smbios -t SMB_TYPE_BIOS >/dev/null 2>&1; then
      sys_bios=$( \
        smbios -t SMB_TYPE_BIOS \
        | grep -E 'Vendor|Version|Release' \
        | awk -F ':' '{print $2}' \
        | paste -sd ' ' - \
        | trim)
    else
      sys_bios=unknown
    fi
  ;;
esac
