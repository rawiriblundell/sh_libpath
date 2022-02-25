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

if command -v systemctl >/dev/null 2>&1; then
  svc_start() {
    /bin/systemctl start "${1:?No service specified}"
  }
  svc_restart() {
    /bin/systemctl restart "${1:?No service specified}"
  }
  svc_status() {
    /bin/systemctl --quiet is-active "${1:?No service specified}"
  }

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

elif [[ -x /sbin/service ]]; then
  svc_start() {
    /sbin/service "${1:?No service specified}" start >/dev/null 2>&1
  }
  svc_restart() {
    /sbin/service "${1:?No service specified}" restart >/dev/null 2>&1
  }
  svc_status() {
    /sbin/service "${1:?No service specified}" status >/dev/null 2>&1
  }

elif [[ -f /etc/init.d/"${1:?No service specified}" ]]; then
  svc_start() {
    /etc/init.d/"${1:?No service specified}" start >/dev/null 2>&1
  }
  svc_restart() {
    /etc/init.d/"${1:?No service specified}" restart >/dev/null 2>&1
  }
  svc_status() {
    /etc/init.d/"${1:?No service specified}" status >/dev/null 2>&1
  }
  
else
  svc_start() {
    printf -- '%s\n' "No service specified, or service control method not found" >&2
  }
  svc_restart() {
    printf -- '%s\n' "No service specified, or service control method not found" >&2
  }
  svc_status() {
    printf -- '%s\n' "No service specified, or service control method not found" >&2
  }
fi

