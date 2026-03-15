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

[ -n "${_SHELLAC_LOADED_core_vars+x}" ] && return 0
_SHELLAC_LOADED_core_vars=1

# @description Test whether a variable is set and non-empty.
# @exitcode 0 Variable is set and non-empty
# @exitcode 1 Otherwise
var_is_set() { [ "${1+x}" = "x" ] && [ "${#1}" -gt "0" ]; }     # set and not null

# @description Test whether a variable is unset.
# @exitcode 0 Variable is unset
# @exitcode 1 Variable is set (even if empty)
var_is_unset() { [ -z "${1+x}" ]; }                             # unset

# @description Test whether a variable is set but empty.
# @exitcode 0 Variable is set and empty
# @exitcode 1 Otherwise
var_is_empty() { [ "${1+x}" = "x" ] && [ "${#1}" -eq "0" ]; }   # set and null

# @description Test whether a variable is unset or empty.
# @exitcode 0 Variable is unset or empty
# @exitcode 1 Variable is set and non-empty
var_is_blank() { var_is_unset "${1}" || var_is_empty "${1}"; }  # unset, or set and null
