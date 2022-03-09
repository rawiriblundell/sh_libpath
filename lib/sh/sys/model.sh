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
    if grep . /sys/devices/virtual/dmi/id/product_name >/dev/null 2>&1; then
      sysModel=$(</sys/devices/virtual/dmi/id/product_name)
    elif dmidecode | grep -m 1 "Product" >/dev/null 2>&1; then
      sysModel=$(dmidecode | awk -F ':' '/Product/{print $2; exit}' | trim)
    else
      sysModel="Generic or unknown"
    fi
  ;;
  (SunOS|solaris)
    sysModel=$(uname -i | cut -d, -f2- | tr "-" " ")
  ;;
esac
