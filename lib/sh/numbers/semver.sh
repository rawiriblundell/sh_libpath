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

[ -n "${_SHELLAC_LOADED_numbers_semver+x}" ] && return 0
_SHELLAC_LOADED_numbers_semver=1

# @description Convert a semantic version string to a zero-padded integer for numeric comparison.
#   Strips non-numeric/non-dot characters, then formats as MMMMNNPP (major, 2-digit minor, 2-digit patch).
#
# @arg $1 string Version string (e.g. "1.0.2k-fips" or "openssl 1.0.2")
#
# @example
#   semver_to_int "1.0.2k-fips"   # => 10002
#   semver_to_int "2.31.0"        # => 23100
#
# @stdout Integer representation of the version
# @exitcode 0 Always
semver_to_int() {
    local _sem_ver
    _sem_ver="${1:?No version number supplied}"

    if [ -n "${BASH_VERSION}" ]; then
        _sem_ver="${_sem_ver//[^0-9.]/}"
        # shellcheck disable=SC2086
        set -- ${_sem_ver//./ }
    else
        _sem_ver="$(printf -- '%s\n' "${_sem_ver}" | sed 's/[^0-9.]//g')"
        # shellcheck disable=SC2046
        set -- $(printf -- '%s\n' "${_sem_ver}" | tr '.' ' ')
    fi

    printf -- '%d%02d%02d' "${1}" "${2:-0}" "${3:-0}"
}
