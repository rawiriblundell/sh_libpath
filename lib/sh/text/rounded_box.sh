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
# TODO: Accept heredoc inputs
# TODO: Add coloured border handling e.g. red borders for warning messages
rounded_box() {
    local u_left u_right b_left b_right h_bar v_bar h_width title content
    u_left="\xe2\x95\xad"   # upper left corner
    u_right="\xe2\x95\xae"  # upper right corner
    b_left="\xe2\x95\xb0"   # bottom left corner
    b_right="\xe2\x95\xaf"  # bottom right corner
    h_bar="\xe2\x94\x80"    # horizontal bar
    v_bar="\xe2\x94\x82"    # vertical bar
    h_width="78"            # default horizontal width

    # Reset OPTIND
    OPTIND=1

    while getopts ":ht:w:" flags; do
        case "${flags}" in
            (h)
                printf -- '%s\n' "rounded_box (-t [title] -w [width in columns]) [content]" >&2
                return 0
            ;;
            (t) title="${OPTARG}" ;;
            (w) h_width="$(( OPTARG - 2 ))" ;;
            (*) : ;;
        esac
    done
    shift "$(( OPTIND - 1 ))"

    # What remains after getopts is our content
    # We store it this way to support multi-line input
    content=$(printf -- '%s ' "${@}")

    # Print our top bar
    printf -- '%b' "${u_left}"
    # If the title is defined, then make space for it within the top bar
    if [[ -n "${title}" ]]; then
        # Calculate visual width of title (accounting for UTF-8)
        title_visual_width=$(printf -- '%s' "${title}" | wc -m)
        title_padding=$(( h_width - title_visual_width - 2 ))

        printf -- '%b %s ' "${h_bar}" "${title}"
        for (( i=0; i<title_padding; i++)); do
            printf -- '%b' "${h_bar}"
        done
    # Otherwise, just print the full bar
    else
        for (( i=0; i<h_width; i++)); do
            printf -- '%b' "${h_bar}"
        done
    fi
    printf -- '%b\n' "${h_bar}${u_right}"

    # Print our content
    if [[ -n "${content}" ]]; then
        # Replace literal "\n" with actual newlines
        processed_content=$(printf -- '%s' "${content}" | sed 's/\\n/\n/g')

        # Process each line, including empty lines
        while IFS= read -r line || [[ -n "${line}" ]]; do
            # Wrap long lines with fold
            while IFS= read -r folded_line; do
                line_visual_width=$(printf -- '%s' "${folded_line}" | wc -m)
                padding_width=$(( h_width - line_visual_width ))
                printf -- '%b %s' "${v_bar}" "${folded_line}"
                printf -- '%*s' "$padding_width"
                printf -- ' %b\n' "${v_bar}"
            done < <(printf '%s\n' "${line}" | fold -s -w "${h_width}")
        done < <(printf -- '%s\n' "${processed_content}")
    else
        # Empty content - print one blank line
        printf -- '%b %*s %b\n' "${v_bar}" "$h_width" "" "${v_bar}"
    fi

    # Print our bottom bar
    printf -- '%b' "${b_left}${h_bar}"
    for (( i=0; i<h_width; i++)); do
        printf -- '%b' "${h_bar}"
    done
    printf -- '%b\n' "${h_bar}${b_right}"
}

