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

# Convert a three number style semantic version number to an integer for version comparisons
# This zero pads, to double digits, the second and third numbers and removes any non-numerical chars
# e.g. 'openssl 1.0.2k-fips' -> '10002'
semver_to_int() {
    _sem_ver="${1:?No version number supplied}"

    # Strip the variable of any non-numerics or dots
    _sem_ver="$(printf -- '%s\n' "${_sem_ver}" | sed 's/[^0-9.]//g')"

    # Swap the dots for spaces and assign the outcome to the positional param array
    # We want word splitting here, so we disable shellcheck's complaints
    # shellcheck disable=SC2046
    set -- $(printf -- '%s\n' "${_sem_ver}" | tr '.' ' ')

    # Assemble and print our integer
    printf -- '%d%02d%02d' "${1}" "${2:-0}" "${3:-0}"

    unset -v _sem_ver
}

# In pure bash, the above would look like this:
# semver_to_int() {
#     local _sem_ver
#     _sem_ver="${1:?No version number supplied}"
#     _sem_ver="${_sem_ver//[^0-9.]/}"
#     # shellcheck disable=SC2086
#     set -- ${_sem_ver//./ }
#     printf -- '%d%02d%02d' "${1}" "${2:-0}" "${3:-0}"
# }
