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

[ -n "${_SH_LOADED_sys_get_virtual_status+x}" ] && return 0
_SH_LOADED_sys_get_virtual_status=1

get-virtual-status() {
  if grep -q hypervisor /proc/cpuinfo; then
    printf '%s\n' "virtual"
  elif grep -qE '^flags.*svm|^flags.*vmx' /proc/cpuinfo; then
    printf '%s\n' "physical"
  else
    printf '%s\n' "unknown"
  fi
}

is-azure() {
  # All Azure hosts should have waagent.log
  grep -q -m 1 Azure /var/log/waagent.log 2>/dev/null && return "$?"
  # This may be a suitable alternative:
  #dmidecode | grep "String 1: \[MS_VM_CERT"
  # Does not work reliably:
  #blkid | grep -qE 'BEK|KEK' && return "$?"
  # The below might is not reliable, and technically it identifies HyperV:
  #dmesg | grep -q "Hardware name: Microsoft Corporation Virtual Machine/Virtual Machine"
}

# From https://serverfault.com/a/903599
# See also: 
# https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/identify_ec2_instances.html
# TODO: Update for IMDSv2
is-aws() {
  local doc_url="http://169.254.169.254/latest/dynamic/instance-identity/document"
  if grep -q "^ec2" /sys/hypervisor/uuid 2>/dev/null; then
    return 0
  elif grep -q "^EC2" /sys/devices/virtual/dmi/id/product_uuid 2>/dev/null; then
    return 0
  elif curl -s -m 5 "${doc_url}" | grep -q availabilityZone; then
    return 0
  else
    return 1
  fi
}

if iscommand virt-what; then
  sys_type=$(virt-what 2>/dev/null | head -n 1)
fi

# Function to parse the output of various commands
# Attempts to figure out the virtualisation type, if any
Fn_getVirt() {
  local sys_type
  if nullgrep -Ei "virtualbox|vbox"; then
    sys_type="virtualbox"
  elif nullgrep -i "vmware"; then
    sys_type="VMware"
  elif nullgrep -i "hvm.*domu"; then
    sys_type="Xen"
  elif nullgrep -Ei "rhev|ovirt"; then
    sys_type="kvm"
  elif nullgrep -i "qemu"; then
    sys_type="qemu"
  elif nullgrep hypervisor /proc/cpuinfo; then
    sys_type="Unknown virtual"
  fi
  printf -- '%s\n' "${sys_type}"
}

# If virt-what doesn't exist or doesn't return anything, try the following
if [[ -z "${sys_type}" ]]; then
  if nullgrep -E '^flags.*svm|^flags.*vmx' /proc/cpuinfo; then
    sys_type=Physical
  elif iscommand facter; then
    sys_type=$(facter virtual  2>/dev/null)
  elif iscommand pciconf; then
    sys_type=$(pciconf -lv 2>/dev/null | Fn_getVirt)
  elif iscommand dmidecode; then
    sys_type=$(dmidecode 2>/dev/null | Fn_getVirt)
  elif iscommand lspci; then
    sys_type=$(lspci -v 2>/dev/null | Fn_getVirt)
  elif [[ -d /dev/disk/by-id ]]; then
    sys_type=$(find /dev/disk/by-id | Fn_getVirt)
  else
    sys_type=other
  fi
fi
