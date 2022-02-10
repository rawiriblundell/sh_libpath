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
    printf -- 'ssl_connect: %s\n' "This library requires 'openssl', which was not found in PATH" >&2
    exit 1
fi

ssl_connect () {
    _ssl_connect_remote_host="${1}"
    _ssl_connect_remote_port="${2:-443}"

    if (( "${#_ssl_connect_remote_host}" == 0 )); then
        printf -- 'ssl_connect: %s\n' "No remote host defined" >&2
        return 1
    fi

    openssl s_client -status -connect "${_ssl_connect_remote_host}:${_ssl_connect_remote_port}"

    unset -v _ssl_connect_remote_host _ssl_connect_remote_port
}
