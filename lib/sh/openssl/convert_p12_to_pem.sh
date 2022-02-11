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

if ! command -v openssl >/dev/null 2>&1; then
    printf -- 'convert_p12_to_pem: %s\n' "This library requires 'openssl', which was not found in PATH" >&2
    exit 1
fi

convert_p12_to_pem() {
    _p12_to_pem_in="${1}"
    _p12_to_pem_out="${2}"

    if (( "${#_p12_to_pem_in}" == 0 )); then
        printf -- 'convert_p12_to_pem: %s\n' "No input file provided" >&2
        return 1
    fi

    if [[ -s "${_p12_to_pem_in}" ]]; then
        printf -- 'convert_p12_to_pem: %s\n' "Input file eppears to be empty" >&2
        return 1
    fi

    if (( "${#_p12_to_pem_out}" == 0 )); then
        _p12_to_pem_out="${_p12_to_pem_in%.*}"
        _p12_to_pem_out="${_p12_to_pem_out}.pem"
    fi

    openssl pkcs12 -nodes -in "${_p12_to_pem_in}" -out "${_p12_to_pem_out}"

    unset -v _p12_to_pem_in _p12_to_pem_out
}
