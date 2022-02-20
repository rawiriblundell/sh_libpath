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

# If the input matches "int.int", then we test if it's a float
# Otherwise, we test if it's an integer
# +/- specifiers are accepted
# All other conditions will return 1 i.e. not a float or int
_temp_number_validation() {
    case "${1}" in
        (*[0-9].[0-9]*)
            # Floats
            if printf -- '%s\n' "${1}" | grep -E '^[-+]?[0-9]+\.[0-9]*$' >/dev/null 2>&1; then
                return 0
            fi
            return 1
        ;;
        (*[0-9]*)
            # Integers
            if printf -- '%s\n' "${1}" | grep -E '^[-+]?[0-9]+$' >/dev/null 2>&1; then
                return 0
            fi
            return 1
        ;;
        (*) return 1 ;;
    esac
}

# Celsius to Fahrenheit
# Formula: temp times 9 divided by 5 + 32
c_to_f() {
    _temp_c="${1}"
    if _temp_number_validation "${_temp_c}"; then
        _temp_f=$(printf -- '%s\n' "scale=2;${_temp_c} * 9 / 5 + 32" | bc)
        printf -- '%.2f\n' "${_temp_f}"
    else
        printf -- '%s\n' "null"
    fi
    unset -v _temp_c _temp_f
}

# Fahrenheit to Celsius
# Forumla: temp minus 32 times 5 divided by 9
f_to_c() {
    _temp_f="${1}"
    if _temp_number_validation "${_temp_f}"; then
        _temp_c=$(printf -- '%s\n' "scale=2;${_temp_f} - 32 * 5 / 9" | bc)
        printf -- '%.2f\n' "${_temp_c}"
    else
        printf -- '%s\n' "null"
    fi
    unset -v _temp_c _temp_f
}
