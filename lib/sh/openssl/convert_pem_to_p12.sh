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
    printf -- 'convert_pem_to_p12: %s\n' "This library requires 'openssl', which was not found in PATH" >&2
    exit 1
fi

convert_pem_to_p12() {
    _pem_to_p12_key="${1}"
    _pem_to_p12_cert="${2}"
    _pem_to_p12_ca="${3}"
    _pem_to_p12_out="${4}"

    if (( "${#}" != 4 )); then
        printf -- 'convert_pem_to_p12: %s\n' "No input file provided" >&2
        return 1
    fi

    openssl pkcs12 -export \
      -inkey "${_pem_to_p12_key}" \
      -in "${_pem_to_p12_cert}" \
      -certfile "${_pem_to_p12_ca}" \
      -out "${_pem_to_p12_out}"

    unset -v _pem_to_p12_key _pem_to_p12_cert _pem_to_p12_ca _pem_to_p12_out
}
