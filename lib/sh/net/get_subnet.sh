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

# Subnet Mask
# Note: this is for the primary IP address only.
# We try with 'ip', which requires CIDR conversion
if command ip >/dev/null 2>&1; then
  cidr=$(ip -o -f inet addr show | awk -F '/' '/scope global/{print $2}' | awk '{print $1}')
  ipMask=$(Fn_cdr2mask "${cidr}")
# If 'ifconfig' is present, we can try it like this:
elif command ifconfig >/dev/null 2>&1; then
  ipMask=$(ifconfig | grep -m 1 Mask | cut -d: -f4-)
  # Again, if we're here, we're dealing with a different ifconfig output format
  if [[ -z "${ipMask}" ]]; then
    ipMask=$(ifconfig | awk '/netmask/{print $4; exit}')
  fi
fi

# Solaris
# Subnet Mask - requires gateway address
#ipMask=$(netstat -nrv | grep "^$(echo "${gwAddr}" | cut -d"." -f1-3)" | awk '{print $2}')
