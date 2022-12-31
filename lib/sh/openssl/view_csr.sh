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
    printf -- 'view_csr: %s\n' "This library requires 'openssl', which was not found in PATH" >&2
    exit 1
fi

view_csr () {
    local _view_csr_in
    _view_csr_in="${1}"

    if (( "${#_view_csr_in}" == 0 )); then
        printf -- 'view_csr: %s\n' "No input file provided" >&2
        return 1
    fi

    openssl req -text -noout -verify -in "${_view_csr_in}"
}

view_csr_modulus() {
    local _view_csr_modulus_in
    _view_csr_modulus_in="${1}"

    if (( "${#_view_csr_modulus_in}" == 0 )); then
        printf -- 'view_csr_modulus: %s\n' "No input file provided" >&2
        return 1
    fi

    openssl req -noout -modulus -in "${_view_csr_modulus_in}" | shasum -a 256
}
