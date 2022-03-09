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

get_nics() {
  # Let's check /sys/class/net
  if [[ -d /sys/class/net ]]; then
    ls -ltr /sys/class/net/* 2>/dev/null || printInf "no devices found in /sys/class/net/"
  fi

  if iscommand ip; then
    ip a 2>/dev/null | grep -v "valid_lft" || printInf "'ip a' did not return any output"
  fi

  if iscommand ifconfig; then
    ifconfig -a 2>/dev/null | grep -Ev 'RX|TX|collisions' || printInf "'ifconfig -a' did not return any output"
  fi

  # If ethtool is present, let's use it to produce information about ethx interfaces
  if iscommand ethtool; then
    for NetIF in $(ip a | grep "^[0-9]" | cut -d: -f2); do
      ethtool "${NetIF}" 2>/dev/null
    done
  fi
}
