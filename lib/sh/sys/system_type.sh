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

[ -n "${_SHELLAC_LOADED_sys_system_type+x}" ] && return 0
_SHELLAC_LOADED_sys_system_type=1

if iscommand virt-what; then
  sys_type=$(virt-what 2>/dev/null | head -n 1)
fi

# @description Parse stdin for known virtualisation product strings and print
#   the detected hypervisor type. Intended to be used as a filter for the output
#   of dmidecode, lspci, pciconf, or similar commands.
#
# @stdout Virtualisation type string, e.g. "virtualbox", "VMware", "Xen", "kvm", "qemu"
# @exitcode 0 Always
get_virt_type() {
  local sys_type
  if grep -qEi "virtualbox|vbox" 2>/dev/null; then
    sys_type="virtualbox"
  elif grep -qi "vmware" 2>/dev/null; then
    sys_type="VMware"
  elif grep -qi "hvm.*domu" 2>/dev/null; then
    sys_type="Xen"
  elif grep -qEi "rhev|ovirt" 2>/dev/null; then
    sys_type="kvm"
  elif grep -qi "qemu" 2>/dev/null; then
    sys_type="qemu"
  elif grep -q hypervisor /proc/cpuinfo 2>/dev/null; then
    sys_type="Unknown virtual"
  fi
  printf -- '%s\n' "${sys_type}"
}

# If virt-what doesn't exist or doesn't return anything, try the following
if [[ -z "${sys_type}" ]]; then
  if grep -qE '^flags.*svm|^flags.*vmx' /proc/cpuinfo 2>/dev/null; then
    sys_type=Physical
  elif iscommand facter; then
    sys_type=$(facter virtual  2>/dev/null)
  elif iscommand pciconf; then
    sys_type=$(pciconf -lv 2>/dev/null | get_virt_type)
  elif iscommand dmidecode; then
    sys_type=$(dmidecode 2>/dev/null | get_virt_type)
  elif iscommand lspci; then
    sys_type=$(lspci -v 2>/dev/null | get_virt_type)
  elif [[ -d /dev/disk/by-id ]]; then
    sys_type=$(find /dev/disk/by-id | get_virt_type)
  else
    sys_type=other
  fi
fi
