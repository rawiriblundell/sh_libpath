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

# Print a given text within a rounded box
rounded_box() {
    local u_left u_right b_left b_right h_bar v_bar h_width title content
    u_left="\xe2\x95\xad"
    u_right="\xe2\x95\xae"
    b_left="\xe2\x95\xb0"
    b_right="\xe2\x95\xaf"
    h_bar="\xe2\x94\x80"
    v_bar="\xe2\x94\x82"
    h_width="78"

    while getopts ":ht:w:" flags; do
        case "${flags}" in
            (h)
                printf -- '%s\n' "rounded_box (-w [width]) (-t [header]) [content]" >&2
                return 0
            ;;
            (t) title="${OPTARG}" ;;
            (w) h_width="$(( OPTARG - 2 ))" ;;
            (*) : ;;
        esac
    done
    shift "$(( OPTIND - 1 ))"

    content="${*}"

    # Print our header
    printf -- '%b' "${u_left}${h_bar}"
    printf -- '%s' "${title}"
    title_width=$(( h_width - ${#title} ))
    for (( i=0; i<title_width; i++)); do
        printf -- '%b' "${h_bar}"
    done
    printf -- '%b\n' "${h_bar}${u_right}"

    # Print our content
    while read -r; do
        printf -- '%b %s' "${v_bar}" "${REPLY}"
        printf -- '%*s' "$(( h_width - ${#REPLY} ))"
        printf -- ' %b\n' "${v_bar}"
    done < <(fold -s -w "${h_width}" <<< ${content})

    # Print our tail
    printf -- '%b' "${b_left}${h_bar}"
    for (( i=0; i<h_width; i++)); do
        printf -- '%b' "${h_bar}"
    done
    printf -- '%b\n' "${h_bar}${b_right}"
}
