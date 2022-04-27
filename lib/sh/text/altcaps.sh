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

# This is the magic sauce - we convert the input character to a decimal (%d)
# Then add 32 to move it 32 places on the ASCII table
# Then we print it in unsigned octal (%o)
# And finally print the char that matches the octal representation (\\)
# Example: printf '%d' "'A" => 65 (+32 = 97)
#          printf '%o' "97" => 141
#          printf \\141 => a
_str_altcaps_lowercase(){
    # shellcheck disable=SC2059
    case "${1}" in
        ([[:upper:]])
            printf \\"$(printf '%o' "$(( $(printf '%d' "'${1}") + 32 ))")"
        ;;
        (*)
            printf "%s" "${1}"
        ;;
    esac
}

# And the inverse of the above for uppercasing
_str_altcaps_uppercase(){
    # shellcheck disable=SC2059
    case "${1}" in
        ([[:lower:]])
            printf \\"$(printf '%o' "$(( $(printf '%d' "'${1}") - 32 ))")"
        ;;
        (*)
            printf "%s" "${1}"
        ;;
    esac
}

str_altcaps() {
    _str_altcaps_lastswitch=lower
    _str_altcaps_count=0
    for _str_altcaps_word in "${@}"; do
        for _str_altcaps_char in $(printf -- '%s\n' "${_str_altcaps_word}" | fold -w 1); do
            case "${_str_altcaps_lastswitch}" in
                (lower)
                    _str_altcaps_uppercase "${_str_altcaps_char}"
                    _str_altcaps_lastswitch=upper
                ;;
                (upper)
                    _str_altcaps_lowercase "${_str_altcaps_char}"
                    _str_altcaps_lastswitch=lower
                ;;
            esac
        done
        _str_altcaps_count=$(( _str_altcaps_count + 1 ))
        (( _str_altcaps_count != "${#}" )) && printf -- '%s' " "
    done

    printf -- '%s\n' ""
    unset -v _str_altcaps_lastswitch _str_altcaps_count _str_altcaps_word _str_altcaps_char
}
