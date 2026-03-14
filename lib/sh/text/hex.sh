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

[ -n "${_SH_LOADED_text_hex+x}" ] && return 0
_SH_LOADED_text_hex=1

# @description Convert a string to its hexadecimal representation.
#
# @arg $1 string The string to convert
#
# @stdout Hex-encoded string (no spaces, lowercase)
# @exitcode 0 Always
strtohex() {
  printf -- '%s'  "${1:?No string supplied}" | xxd -pu
}

# @description Convert a hex color code to an RGB string.
#
# @arg $1 string Hex color code, with or without leading '#'
#
# @stdout rgb(r, g, b) string
# @exitcode 0 Always
hex_to_rgb() {
    : "${1/\#/}"
    ((r = 16#${_:0:2}, g = 16#${_:2:2}, b = 16#${_:4:2}))
    printf -- 'rgb(%d, %d, %d)\n' "$r" "$g" "$b"
}

# @description Convert RGB values to a hex color code.
#
# @arg $1 int Red component (0-255)
# @arg $2 int Green component (0-255)
# @arg $3 int Blue component (0-255)
#
# @stdout Hex color code in the form #rrggbb
# @exitcode 0 Always
rgb_to_hex() {
    printf -- '#%02x%02x%02x\n' "$1" "$2" "$3"
}

# @description Convert a hex color code (6 or 8 digits) to an RGBA string.
#   An 8-digit hex value includes an alpha channel; 6-digit values default to alpha 1.0.
#
# @arg $1 string Hex color code, with or without leading '#' (6 or 8 hex digits)
#
# @stdout rgba(r, g, b, a) string
# @exitcode 0 Always
hex_to_rgba() {
  # Remove leading "#" character, if present
  : "${1/\#/}"

  # Extract color components and alpha channel
  if (( ${#_} == 8 )); then
    # Hexadecimal value includes alpha channel
    ((r = 16#${_:0:2}, g = 16#${_:2:2}, b = 16#${_:4:2}, a = 16#${_:6:2}))
    a=$(bc <<< "scale=2; ${a} / 255")
  else
    # Hexadecimal value does not include alpha channel
    ((r = 16#${_:0:2}, g = 16#${_:2:2}, b = 16#${_:4:2}))
    a=1.0
  fi

  # Print "rgba(r, g, b, a)" string
  printf -- 'rgba(%d, %d, %d, %d)\n' "$r" "$g" "$b" "$a"
}
