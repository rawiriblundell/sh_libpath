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

# This library requires 'bc'
if ! command -v bc >/dev/null 2>&1; then
    printf -- 'temperature: %s\n' "This library requires 'bc', which was not found in PATH" >&2
    exit 1
fi

# Helper function:
# Use the 'printf' builtin to test whether we have an int or a float
# +/- specifiers are accepted
# All other conditions will return 1 i.e. not a float or int
_temp_number_validation() {
    # Is it an int?
    printf -- '%d' "${1:-null}" >/dev/null 2>&1 && return 0
    # Is it a float?
    printf -- '%f' "${1:-null}" >/dev/null 2>&1 && return 0
    # If we get here, then we failed in our mission
    return 1
}

# Celsius to Fahrenheit
# Formula: (temp times 9 divided by 5) + 32
c_to_f() {
    _temp_number_validation "${1}" || { printf -- '%s\n' "null"; return 1; }
    printf -- '%s\n' "scale=2;(${1} * 9 / 5) + 32" | bc
}

# Fahrenheit to Celsius
# Forumla: (temp minus 32) times 5 divided by 9
f_to_c() {
    _temp_number_validation "${1}" || { printf -- '%s\n' "null"; return 1; }
    printf -- '%s\n' "scale=2;(${1} - 32) * 5 / 9" | bc
}

# Celsius to Kelvin
# Forumla: temp + 273.15.  Easy!
c_to_k()  {
    _temp_number_validation "${1}" || { printf -- '%s\n' "null"; return 1; }
   printf -- '%s\n' "scale=2;${1} + 273.15" | bc
}

# Kelvin to Celsius
# Forumla: temp - 273.15.  Easy!
k_to_c()  {
    _temp_number_validation "${1}" || { printf -- '%s\n' "null"; return 1; }
    printf -- '%s\n' "scale=2;${1} - 273.15" | bc
}

# Fahrenheit to Kelvin
# Formula: There's a couple of formulas out there, the simplest is literally f -> c -> k
f_to_k() {
    _temp_number_validation "${1}" || { printf -- '%s\n' "null"; return 1; }
    _temp_k=$(printf -- '%s\n' "scale=2;(${1} - 32) * 5 / 9" | bc)
    printf -- '%s\n' "scale=2;${_temp_k} + 273.15" | bc
    unset -v _temp_k
}

# Kelvin to Fahrenheit
# Formula: Reverse of the above - k -> c -> f
k_to_f() {
    _temp_number_validation "${1}" || { printf -- '%s\n' "null"; return 1; }
    _temp_f=$(printf -- '%s\n' "scale=2;${1} - 273.15" | bc)
    printf -- '%s\n' "scale=2;(${_temp_f} * 9 / 5) + 32" | bc
    unset -v _temp_f
}

#TODO: Any thirst for Reaumur and/or Rankine? :)
