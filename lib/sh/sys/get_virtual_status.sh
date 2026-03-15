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

[ -n "${_SHELLAC_LOADED_sys_get_virtual_status+x}" ] && return 0
_SHELLAC_LOADED_sys_get_virtual_status=1

# @description Determine whether the host is a virtual machine or physical host
#   by inspecting /proc/cpuinfo for hypervisor and virtualisation CPU flags.
#
# @stdout "virtual", "physical", or "unknown"
# @exitcode 0 Always
get-virtual-status() {
  if grep -q hypervisor /proc/cpuinfo; then
    printf '%s\n' "virtual"
  elif grep -qE '^flags.*svm|^flags.*vmx' /proc/cpuinfo; then
    printf '%s\n' "physical"
  else
    printf '%s\n' "unknown"
  fi
}

# @description Detect whether the host is running on Microsoft Azure.
#   Checks for waagent.log containing "Azure" as the primary indicator.
#
# @exitcode 0 Host appears to be on Azure
# @exitcode 1 Host does not appear to be on Azure
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

# @description Detect whether the host is running on Amazon Web Services (EC2).
#   Checks /sys/hypervisor/uuid, DMI product_uuid, and the instance identity
#   document endpoint. Note: not updated for IMDSv2.
#
# @exitcode 0 Host appears to be on AWS EC2
# @exitcode 1 Host does not appear to be on AWS EC2
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

# @description Parse stdin for known virtualisation product strings and print
#   the detected hypervisor type. Intended to be used as a filter for the output
#   of dmidecode, lspci, pciconf, or similar commands.
#
# @stdout Virtualisation type string, e.g. "virtualbox", "VMware", "Xen", "kvm", "qemu"
# @exitcode 0 Always
Fn_getVirt() {
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
