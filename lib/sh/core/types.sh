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

[ -n "${_SH_LOADED_core_types+x}" ] && return 0
_SH_LOADED_core_types=1

# Classify a string value by its apparent type.
# Outputs one of: empty, integer, float, bool, string
# Classification is ordered most-specific to least:
#   empty   - zero-length or unset
#   integer - whole number (includes negative)
#   float   - decimal number (includes negative)
#   bool    - true/false/yes/no/on/off (not 0/1 - those resolve to integer)
#   string  - anything else
#
# Usage: string_type <value>
# Example:
#   case "$(string_type "${var}")" in
#     (integer) ...;;
#     (float)   ...;;
#     (bool)    ...;;
#     (empty)   ...;;
#     (string)  ...;;
#   esac
string_type() {
    [ -z "${1:-}" ] && { printf -- '%s\n' "empty"; return 0; }
    printf -- '%d' "${1}" >/dev/null 2>&1 && { printf -- '%s\n' "integer"; return 0; }
    printf -- '%f' "${1}" >/dev/null 2>&1 && { printf -- '%s\n' "float"; return 0; }
    case "${1}" in
        ([tT][rR][uU][eE]|[fF][aA][lL][sS][eE]|[yY][eE][sS]|[nN][oO]|[oO][nN]|[oO][fF][fF])
            printf -- '%s\n' "bool"; return 0 ;;
    esac
    printf -- '%s\n' "string"
}
