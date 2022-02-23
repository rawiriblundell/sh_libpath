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

if [[ -x /bin/systemctl ]]; then
  Start_Service() {
    /bin/systemctl start "${1:?No service specified}"
  }
  Restart_Service() {
    /bin/systemctl restart "${1:?No service specified}"
  }
elif [[ -x /sbin/service ]]; then
  Start_Service() {
    /sbin/service "${1:?No service specified}" start >/dev/null 2>&1
  }
  Restart_Service() {
    /sbin/service "${1:?No service specified}" restart >/dev/null 2>&1
  }
elif [[ -f /etc/init.d/"${1:?No service specified}" ]]; then
  Start_Service() {
    /etc/init.d/"${1:?No service specified}" start >/dev/null 2>&1
  }
  Restart_Service() {
    /etc/init.d/"${1:?No service specified}" restart >/dev/null 2>&1
  }
else
  Start_Service() {
    printDebug "No service specified, or service control method not found"
  }
  Restart_Service() {
    printDebug "No service specified, or service control method not found"
  }
fi

# Determine -how- to check a service status
if [[ -x /bin/systemctl ]]; then
  svcCmd() {
    /bin/systemctl --quiet is-active "${svcName}"
  }
elif [[ -x /sbin/service ]]; then
  svcCmd() {
    /sbin/service "${svcName}" status >/dev/null 2>&1
  }
elif [[ -f /etc/init.d/"${svcName}" ]]; then
  svcCmd() {
    /etc/init.d/"${svcName}" status >/dev/null 2>&1
  }
fi

# Check if a service is enabled
get-service-enabled() {
  systemctl list-unit-files | grep -q "${1:?svc unset}.*enabled"
  return "$?"
}

# Check if a service is active
get-service-active() {
  systemctl | grep -q "${1:?svc unset}.service.*running"
  return "$?"
}
