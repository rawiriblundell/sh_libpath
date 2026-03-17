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
# Provenance: https://github.com/rawiriblundell/sh_libpath
# SPDX-License-Identifier: Apache-2.0

[ -n "${_SHELLAC_LOADED_time_epoch+x}" ] && return 0
_SHELLAC_LOADED_time_epoch=1

# @description Return the current Unix epoch in seconds.
#   Selects the fastest available method at load time:
#   EPOCHSECONDS (bash 5+ / zsh), printf %T (bash 4.2+), date, perl, curl,
#   or a portable pure-shell fallback.
#
# @stdout Current Unix epoch as an integer
# @exitcode 0 Always
#
# Prioritise builtin approaches over externals to improve performance
# We start by testing for the EPOCHSECONDS shell var (bash 5.0 and newer, zsh w/ datetime module)
if [ -n "${EPOCHSECONDS}" ]; then
    time_epoch() { printf -- '%d\n' "${EPOCHSECONDS}"; }

# Next, we try for 'printf' (bash 4.2 and newer, some ksh)
elif printf '%(%s)T\n' -1 | grep "^[0-9].*$" >/dev/null 2>&1; then
    time_epoch() { printf '%(%s)T\n' -1; }

# Next we try for 'date'
# Because some 'date' variants will return a literal '+%s', we perform a capability check
elif date -u +%s | grep "^[0-9].*$" >/dev/null 2>&1; then
    time_epoch() { date -u +%s; }

# Next we try for 'perl', fairly ubiquitous but fading away slowly...
elif command -v perl >/dev/null 2>&1; then
    time_epoch() { perl -e 'print($^T."\n");'; }
    # Alternative: time_epoch() { perl -e 'print time."\n";'; }

# We can try reaching out to the internet...
elif command -v curl >/dev/null 2>&1; then
    if curl -s -m 1 http://icanhazepoch.com/ | grep "^[0-9].*$" >/dev/null 2>&1; then
        time_epoch() { curl -s -m 1 http://icanhazepoch.com/; }
    fi

# Otherwise we failover to a portable-ish shell method
else

# Calculate how many seconds since epoch
# Portable version based on http://www.etalabs.net/sh_tricks.html
# We strip leading 0's in order to prevent unwanted octal math
# This seems terse, but the vars are the same as their 'date' formats
    time_epoch() {
        # TODO: Update format on these vars
        local y j h m s yo

# POSIX portable way to assign all our vars
IFS=: read -r y j h m s <<-EOF
$(date -u +%Y:%j:%H:%M:%S)
EOF

        # yo = year offset
        yo=$(( y - 1600 ))
        y=$(( (yo * 365 + yo / 4 - yo / 100 + yo / 400 + $(( 10#$j )) - 135140) * 86400 ))

        printf -- '%s\n' "$(( y + ($(( 10#$h )) * 3600) + ($(( 10#$m )) * 60) + $(( 10#$s )) ))"
    }
fi

# @description Return the current Unix epoch expressed in a larger time unit.
#
# @arg $1 string Unit: seconds, minutes, hours, or days
#
# @example
#   time_epoch_in days
#   time_epoch_in hours
#
# @stdout Integer epoch value in the requested unit
# @exitcode 0 Always
# @exitcode 1 Unrecognised unit
time_epoch_in() {
  case "${1:-}" in
    (seconds) time_epoch ;;
    (minutes) printf -- '%s\n' "$(( $(time_epoch) / 60 ))" ;;
    (hours)   printf -- '%s\n' "$(( $(time_epoch) / 3600 ))" ;;
    (days)    printf -- '%s\n' "$(( $(time_epoch) / 86400 ))" ;;
    (*)
      printf -- 'Usage: time_epoch_in [seconds|minutes|hours|days]\n' >&2
      return 1
    ;;
  esac
}

# To get the epoch date at particular times
#BSD $(date -j -f "%Y-%m-%dT%T" "$1" "+%s")
#Busybox $(date -d "${1//T/ }" +%s)

# @description Convert a Windows/LDAP 100-nanosecond interval timestamp to a Unix epoch.
#   The LDAP timestamp counts 100ns intervals since 1 January 1601.
#
# @arg $1 int LDAP timestamp (100-nanosecond intervals since 1601-01-01)
#
# @example
#   time_ldaptime_to_epoch 132000000000000000   # => Unix epoch integer
#
# @stdout Unix epoch as an integer
# @exitcode 0 Always
time_ldaptime_to_epoch() {
  local _ldap_timestamp _ldap_offset
  _ldap_timestamp="${1:?No ldap timestamp supplied}"
  _ldap_timestamp=$(( _ldap_timestamp / 10000000 ))
  # Calculated as '( (1970-1601) * 365 -3 + ((1970-1601)/4) ) * 86400'
  _ldap_offset=11644473600
  printf -- '%s\n' "$(( _ldap_timestamp - _ldap_offset ))"
}

# @description Convert an SSL-style date/time string to a Unix epoch using perl.
#   Intended for systems where date(1) does not support the -d flag.
#   Expected input format: "Nov 10 2034 21:19:01"
#
# @arg $1 string Month (e.g. Nov)
# @arg $2 int Day of month
# @arg $3 int Four-digit year
# @arg $4 string Time as HH:MM:SS
#
# @stdout Unix epoch integer
# @exitcode 0 Always
# @exitcode 1 perl not available
time_date_to_epoch() {
    local _sec _min _hours _day _month _year _timestamp
    if ! command -v perl >/dev/null 2>&1; then
        printf -- 'time_date_to_epoch: %s\n' "This function requires 'perl', which was not found in PATH" >&2
        return 1
    fi
    # Read our incoming date/time information into our variables
    _month="${1:?No date provided}"; _day="${2}"; _year="${3}"; _timestamp="${4}"
    printf -- '%s\n' "${_timestamp}" | while IFS=':' read -r _hours _min _sec; do
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
}
