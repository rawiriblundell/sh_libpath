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

[ -n "${_SHELLAC_LOADED_numbers_ldaptime_to_epoch+x}" ] && return 0
_SHELLAC_LOADED_numbers_ldaptime_to_epoch=1

# @description Convert a Windows/LDAP 100-nanosecond interval timestamp to a Unix epoch.
#   The LDAP timestamp counts 100ns intervals since 1 January 1601.
#
# @arg $1 int LDAP timestamp (100-nanosecond intervals since 1601-01-01)
#
# @example
#   ldaptime_to_epoch 132000000000000000   # => Unix epoch integer
#
# @stdout Unix epoch as an integer
# @exitcode 0 Always
ldaptime_to_epoch() {
  local _ldap_timestamp _ldap_offset
  _ldap_timestamp="${1:?No ldap timestamp supplied}"
  _ldap_timestamp=$(( _ldap_timestamp / 10000000 ))
  # Calculated as '( (1970-1601) * 365 -3 + ((1970-1601)/4) ) * 86400'
  _ldap_offset=11644473600
  printf -- '%s\n' "$(( _ldap_timestamp - _ldap_offset ))"
}
