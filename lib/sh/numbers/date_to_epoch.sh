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

if ! command -v perl >/dev/null 2>&1; then
    printf -- 'date_to_epoch: %s\n' "This library requires 'perl', which was not found in PATH" >&2
    exit 1
fi

# Used for converting SSL cert datestamps on systems with 'date' that doesn't support '-d'
# Expected format example: "Nov 10 2034 21:19:01"
convert_time_to_epoch() {
    # Read our incoming date/time information into our variables
    _month="${1:?No date provided}"; _day="${2}"; _year="${3}"; _timestamp="${4}"
    write "${_timestamp}" | while IFS=':' read -r _hours _min _sec; do
        # Convert the month to 0..11 range
        case "${_month}" in
            ([jJ]an*) _month=0 ;;
            ([fF]eb*) _month=1 ;;
            ([mM]ar*) _month=2 ;;
            ([aA]pr*) _month=3 ;;
            ([mM]ay)  _month=4 ;;
            ([jJ]un*) _month=5 ;;
            ([jJ]ul*) _month=6 ;;
            ([aA]ug*) _month=7 ;;
            ([sS]ep*) _month=8 ;;
            ([oO]ct*) _month=9 ;;
            ([nN]ov*) _month=10 ;;
            ([dD]ec*) _month=11 ;;
        esac

        # Pass our variables to the mighty 'perl'
        perl -e 'use Time::Local; print timegm(@ARGV[0,1,2,3,4], $ARGV[5]-1900)."\n";' \
            "${_sec}" "${_min}" "${_hours}" "${_day}" "${_month}" "${_year}"
    done
    unset -v _sec _min _hours _day _month _year _timestamp
}
