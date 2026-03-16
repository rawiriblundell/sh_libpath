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

[ -n "${_SHELLAC_LOADED_text_encode+x}" ] && return 0
_SHELLAC_LOADED_text_encode=1

# @description Percent-encode a string for use in a URL (RFC 3986).
#   Unreserved characters (A-Z a-z 0-9 - _ . ~) are passed through unchanged.
#
# @arg $@ string The string to encode
#
# @example
#   str_url_encode "hello world"   # => hello%20world
#   str_url_encode "foo=bar&baz"   # => foo%3Dbar%26baz
#
# @stdout URL-encoded string
# @exitcode 0 Always
str_url_encode() {
  local _input _encoded _char _i
  _input="${*}"
  _encoded=""
  for (( _i = 0; _i < ${#_input}; _i++ )); do
    _char="${_input:_i:1}"
    case "${_char}" in
      ([a-zA-Z0-9.~_-])
        _encoded+="${_char}"
      ;;
      (*)
        # shellcheck disable=SC2059
        printf -v _char '%%%02X' "'${_char}"
        _encoded+="${_char}"
      ;;
    esac
  done
  printf -- '%s\n' "${_encoded}"
}

# @description Decode a percent-encoded URL string. Plus signs are decoded
#   as spaces (application/x-www-form-urlencoded convention).
#
# @arg $@ string The URL-encoded string to decode
#
# @example
#   str_url_decode "hello%20world"   # => hello world
#   str_url_decode "foo%3Dbar"       # => foo=bar
#
# @stdout Decoded string
# @exitcode 0 Always
str_url_decode() {
  local _input
  _input="${*}"
  _input="${_input//+/ }"
  printf -- '%b\n' "${_input//%/\\x}"
}

# @description Base64-encode a string. Requires the base64 command.
#
# @arg $@ string The string to encode
#
# @example
#   str_to_base64 "hello world"   # => aGVsbG8gd29ybGQ=
#
# @stdout Base64-encoded string
# @exitcode 0 Always
str_to_base64() {
  printf -- '%s' "${*}" | base64
}

# @description Decode a base64-encoded string. Requires the base64 command.
#
# @arg $@ string The base64-encoded string to decode
#
# @example
#   str_from_base64 "aGVsbG8gd29ybGQ="   # => hello world
#
# @stdout Decoded string
# @exitcode 0 Always
str_from_base64() {
  printf -- '%s' "${*}" | base64 --decode
}

# @description Escape a string for safe use as a shell argument.
#   Uses bash's printf %q format, which produces output suitable for reuse
#   as input to the shell.
#
# @arg $@ string The string to escape
#
# @example
#   str_escape "hello world"     # => hello\ world
#   str_escape "it's a test"     # => it\'s\ a\ test
#
# @stdout Shell-escaped string
# @exitcode 0 Always
str_escape() {
  printf -- '%q\n' "${*}"
}

# @description Convert a string to its hexadecimal representation.
#   Requires xxd.
#
# @arg $1 string The string to convert
#
# @stdout Hex-encoded string (no spaces, lowercase)
# @exitcode 0 Always
str_to_hex() {
  printf -- '%s' "${1:?No string supplied}" | xxd -pu
}
