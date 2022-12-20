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

strtohex() {
  printf -- '%s'  "${1:?No string supplied}" | xxd -pu
}

# Unknown source
# TODO: Locate and confirm copyright
hex_to_rgb() {
    : "${1/\#/}"
    ((r = 16#${_:0:2}, g = 16#${_:2:2}, b = 16#${_:4:2}))
    printf -- 'rgb(%d, %d, %d)\n' "$r" "$g" "$b"
}

# Unknown source
# TODO: Locate and confirm copyright
rgb_to_hex() {
    printf -- '#%02x%02x%02x\n' "$1" "$2" "$3"
}

# ChatGPT generated
# TODO: Adjust style, portable-ise
hex_to_rgba() {
  # Remove leading "#" character, if present
  : "${1/\#/}"

  # Extract color components and alpha channel
  if (( ${#_} == 8 )); then
    # Hexadecimal value includes alpha channel
    ((r = 16#${_:0:2}, g = 16#${_:2:2}, b = 16#${_:4:2}, a = 16#${_:6:2}))
    a=$(echo "scale=2; $a / 255" | bc)
  else
    # Hexadecimal value does not include alpha channel
    ((r = 16#${_:0:2}, g = 16#${_:2:2}, b = 16#${_:4:2}))
    a=1.0
  fi

  # Print "rgba(r, g, b, a)" string
  printf -- 'rgba(%d, %d, %d, %d)\n' "$r" "$g" "$b" "$a"
}
