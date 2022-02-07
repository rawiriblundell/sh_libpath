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

_hr_width_helper() {
  command -v get_terminal_size >/dev/null 2>&1 || return
# heredocs can't be indented unless you use dirty hard tabs
IFS= read -r _hr_height _hr_width << EOF
$(get_terminal_size)
EOF
  printf -- '%s\n' "${_hr_width}"
  unset -v _hr_height _hr_width
}

# Write a horizontal line using any character
# If run interactively, this defaults to the full width of the window
# Otherwise it defaults to 60 columns
# Note: You will need to escape characters that have special shell meaning
# e.g. 'hr 40 \&'
hr() {
  # Figure out if we're in an interactive shell, then try to figure the width
  case "${-}" in
    (*i*) _hr_width="${COLUMNS:-$(_hr_width_helper)}" ;;
  esac

  # Default to 60 chars wide
  _hr_width="${_hr_width:-60}"

  # shellcheck disable=SC2183
  printf -- '%*s\n' "${1:-$_hr_width}" | tr ' ' "${2:-#}"

  unset -v _hr_width
}
