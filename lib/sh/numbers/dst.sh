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

# Function to figure out daylight savings dates for the current year
dst() {
  local TZ
  # RHEL7 / systemd
  if command -v timedatectl >/dev/null 2>&1; then
    TZ=$(timedatectl status | awk -F ': ' '/Time zone/{print $2}' | awk '{print $1}')
  # RHEL5, RHEL6 and similar aged CentOS/Fedora/etc
  elif [[ -r /etc/sysconfig/clock ]]; then
    TZ=$(awk -F "=" '/ZONE/{print $2}' /etc/sysconfig/clock)
  # Older Debian family
  elif [[ -r /etc/timezone ]]; then
    TZ=$(</etc/timezone)
  # Solaris 11
  elif command -v nlsadm >/dev/null 2>&1; then
    TZ=$(nlsadm get-timezone | cut -d '=' -f2)
  # Older Solaris
  elif [[ -r /etc/TIMEZONE ]]; then
    TZ=$(nawk -F '=' '/TZ=/{print $2}' /etc/TIMEZONE)
  fi

  zdump -v "${TZ:-NZ}" \
    | grep "$(date '+%Y').*isdst=1" \
    | tail -n 2 \
    | awk '{print $4, $3, $6}'
}
