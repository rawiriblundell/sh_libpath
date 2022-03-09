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

if iscommand virt-what; then
  sysType=$(virt-what 2>/dev/null | head -n 1)
fi

# Function to parse the output of various commands
# Attempts to figure out the virtualisation type, if any
get_virt_type() {
  local sysType
  if nullgrep -Ei "virtualbox|vbox"; then
    sysType="virtualbox"
  elif nullgrep -i "vmware"; then
    sysType="VMware"
  elif nullgrep -i "hvm.*domu"; then
    sysType="Xen"
  elif nullgrep -Ei "rhev|ovirt"; then
    sysType="kvm"
  elif nullgrep -i "qemu"; then
    sysType="qemu"
  elif nullgrep hypervisor /proc/cpuinfo; then
    sysType="Unknown virtual"
  fi
  printf -- '%s\n' "${sysType}"
}

# If virt-what doesn't exist or doesn't return anything, try the following
if [[ -z "${sysType}" ]]; then
  if nullgrep -E '^flags.*svm|^flags.*vmx' /proc/cpuinfo; then
    sysType=Physical
  elif iscommand facter; then
    sysType=$(facter virtual  2>/dev/null)
  elif iscommand pciconf; then
    sysType=$(pciconf -lv 2>/dev/null | get_virt_type)
  elif iscommand dmidecode; then
    sysType=$(dmidecode 2>/dev/null | get_virt_type)
  elif iscommand lspci; then
    sysType=$(lspci -v 2>/dev/null | get_virt_type)
  elif [[ -d /dev/disk/by-id ]]; then
    sysType=$(find /dev/disk/by-id | get_virt_type)
  else
    sysType=other
  fi
fi
