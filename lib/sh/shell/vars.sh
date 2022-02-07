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

# Set these helper functions early so that they can assist with init
var_is_set() { [ "${1+x}" = "x" ] && [ "${#1}" -gt "0" ]; }     # set and not null
var_is_unset() { [ -z "${1+x}" ]; }                             # unset
var_is_empty() { [ "${1+x}" = "x" ] && [ "${#1}" -eq "0" ]; }   # set and null
var_is_blank() { var_is_unset "${1}" || var_is_empty "${1}"; }  # unset, or set and null
