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

[ -n "${_SHELLAC_LOADED_sys_model+x}" ] && return 0
_SHELLAC_LOADED_sys_model=1

# @description Print the system hardware model/product name.
#   On Linux: tries /sys/devices/virtual/dmi/id/product_name, then dmidecode.
#   On Solaris: uses uname -i. Falls back to "Generic or unknown".
#
# @stdout Model name
# @exitcode 0 Always
get_sysinfo_model() {
  case "${OSSTR:-$(uname -s)}" in
    ([lL]inux)
      if [[ -s /sys/devices/virtual/dmi/id/product_name ]]; then
        printf -- '%s\n' "$(< /sys/devices/virtual/dmi/id/product_name)"
      elif dmidecode 2>/dev/null | grep -q -m 1 "Product"; then
        dmidecode 2>/dev/null | awk -F ': ' '/Product/ { print $2; exit }'
      else
        printf -- 'Generic or unknown\n'
      fi
    ;;
    (SunOS|solaris)
      uname -i | cut -d, -f2- | tr '-' ' '
    ;;
  esac
}
