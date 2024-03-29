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
    printf -- 'website_to_hpkp_pin: %s\n' "This library requires 'openssl', which was not found in PATH" >&2
    exit 1
fi

website_to_hpkp_pin() {
    local _website_to_hpkp_pin_in
    _website_to_hpkp_pin_in="${1}"

    if (( "${#_website_to_hpkp_pin_in}" == 0 )); then
        printf -- 'website_to_hpkp_pin: %s\n' "No input file provided" >&2
        return 1
    fi

    openssl s_client -connect "${_website_to_hpkp_pin_in}:443" |
        openssl x509 -pubkey -noout |
        openssl rsa -pubin -outform der |
        openssl dgst -sha256 -binary |
        openssl enc -base64
}
