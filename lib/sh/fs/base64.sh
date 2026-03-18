# shellcheck shell=bash

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
# Provenance: https://github.com/rawiriblundell/shellac
# SPDX-License-Identifier: Apache-2.0

[ -n "${_SHELLAC_LOADED_fs_base64+x}" ] && return 0
_SHELLAC_LOADED_fs_base64=1

# @internal
# Encode stdin to base64. Tries base64, then openssl, then uuencode.
_fs_base64_encode() {
  if command -v base64 >/dev/null 2>&1; then
    base64
  elif command -v openssl >/dev/null 2>&1; then
    openssl base64
  elif command -v uuencode >/dev/null 2>&1; then
    uuencode -r -m -
  else
    printf -- '%s\n' "fs_base64_encode: no base64 tool found (tried: base64, openssl, uuencode)" >&2
    return 1
  fi
}

# @internal
# Decode base64 stdin. Tries base64 -d, then openssl, then uudecode.
_fs_base64_decode() {
  if command -v base64 >/dev/null 2>&1; then
    base64 -d
  elif command -v openssl >/dev/null 2>&1; then
    openssl base64 -d
  elif command -v uudecode >/dev/null 2>&1; then
    uudecode -r -m
  else
    printf -- '%s\n' "fs_base64_decode: no base64 tool found (tried: base64, openssl, uudecode)" >&2
    return 1
  fi
}

# @description Base64-encode a file. Tries base64, openssl, uuencode in order.
#
# @arg $1 string Path to the file to encode
#
# @example
#   fs_base64_encode /etc/passwd
#   fs_base64_encode /etc/passwd > /tmp/passwd.b64
#
# @stdout Base64-encoded file contents
# @exitcode 0 Success
# @exitcode 1 File not readable or no suitable tool found
fs_base64_encode() {
  local _file
  _file="${1:?fs_base64_encode: no file given}"

  if [[ ! -r "${_file}" ]]; then
    printf -- 'fs_base64_encode: not readable: %s\n' "${_file}" >&2
    return 1
  fi

  _fs_base64_encode < "${_file}"
}

# @description Base64-decode a file. Tries base64, openssl, uudecode in order.
#
# @arg $1 string Path to the base64-encoded file to decode
#
# @example
#   fs_base64_decode /tmp/passwd.b64
#   fs_base64_decode /tmp/passwd.b64 > /tmp/passwd.restored
#
# @stdout Decoded file contents
# @exitcode 0 Success
# @exitcode 1 File not readable or no suitable tool found
fs_base64_decode() {
  local _file
  _file="${1:?fs_base64_decode: no file given}"

  if [[ ! -r "${_file}" ]]; then
    printf -- 'fs_base64_decode: not readable: %s\n' "${_file}" >&2
    return 1
  fi

  _fs_base64_decode < "${_file}"
}
