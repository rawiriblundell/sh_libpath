# LIBRARY_NAME

## Description

## Provides
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
    printf -- 'convert_pem_to_crt: %s\n' "This library requires 'openssl', which was not found in PATH" >&2
    exit 1
fi

convert_pem_to_crt() {
    _pem_to_crt_in="${1}"
    _pem_to_crt_out="${2}"
    _pem_to_crt_out="${3}"

    if (( "${#_pem_to_crt_in}" == 0 )); then
        printf -- 'convert_pem_to_crt: %s\n' "No input file provided" >&2
        return 1
    fi

    if [[ -s "${_pem_to_crt_in}" ]]; then
        printf -- 'convert_pem_to_crt: %s\n' "Input file eppears to be empty" >&2
        return 1
    fi

    if (( "${#_pem_to_crt_out}" == 0 )); then
        _pem_to_crt_out="${_pem_to_crt_in%.*}"
        _pem_to_crt_out="${_pem_to_crt_out}.crt"
    fi

    openssl x509 -outform "${_pem_to_crt_enctype:-PEM}" -in "${_pem_to_crt_in}" -out "${_pem_to_crt_out}"

    unset -v _pem_to_crt_in _pem_to_crt_out _pem_to_crt_enctype
}
