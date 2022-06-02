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
    printf -- 'validate_cert: %s\n' "This library requires 'openssl', which was not found in PATH" >&2
    exit 1
fi

validate_cert() {
    _validate_cert="${1}"
    _validate_key="${2}"

    if (( "${#_validate_cert}" == 0 )); then
        printf -- 'validate_cert: %s\n' "No input file provided" >&2
        return 1
    fi

    if (( "${#_validate_key}" == 0 )); then
        # We assume either a .pem or .crt extension and remove it
        _validate_key="${_validate_cert%.*}"
        # We assume a .key file with the same name exists
        _validate_key="${_validate_key}.key"
    fi

    if [ ! -r "${_validate_key}" ]; then
        printf -- 'validate_cert: %s\n' "key file not found, specified, or readable" >&2
        return 1
    fi

    _cert_hash="$(openssl x509 -noout -modulus -in "${_validate_cert}" | openssl md5)"
    _key_hash="$(openssl rsa -noout -modulus -in "${_validate_key}" | openssl md5)"
    unset -v _validate_cert _validate_key

    if [ "${_cert_hash}" = "${_key_hash}" ]; then
        unset -v _cert_hash _key_hash
        return 0
    fi

    unset -v _cert_hash _key_hash
    return 1
}
