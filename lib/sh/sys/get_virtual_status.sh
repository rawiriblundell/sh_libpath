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
is-aws() {
  local docUrl="http://169.254.169.254/latest/dynamic/instance-identity/document"
  if grep -q "^ec2" /sys/hypervisor/uuid 2>/dev/null; then
    return 0
  elif grep -q "^EC2" /sys/devices/virtual/dmi/id/product_uuid 2>/dev/null; then
    return 0
  elif curl -s -m 5 "${docUrl}" | grep -q availabilityZone; then
    return 0
  else
    return 1
  fi
}
