# FUNCTION_NAME

## Description

## Synopsis

## Options

## Examples

## Output
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

# Figure out the lowest boundary for the available UID range
uidMin=$(awk '/^UID_MIN/{print $2}' /etc/login.defs)
# Older releases of various Linux distros tended to use '500' as the minimum
# So if we can't find it in login.defs, we'll default to '500'
uidMin="${uidMin:-500}"

get_system_accounts() {
  awk -F ':' -v min="${uidMin}" '{ if ( $3 < min ) print $1 }' /etc/passwd
}

get_system_uids() {
  awk -F ':' -v min="${uidMin}" '{ if ( $3 < min ) print $3 }' /etc/passwd
}

get_user_uids() {
  awk -F ':' -v min="${uidMin}" '{ if ( $3 >= min ) print $3 }' /etc/passwd
}
