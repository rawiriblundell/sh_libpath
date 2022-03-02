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

# Prioritise builtin approaches over externals to improve performance
# We start by testing for the EPOCHSECONDS shell var (bash 5.0 and newer, zsh w/ datetime module)
if [ -n "${EPOCHSECONDS}" ]; then
    get_epoch() { printf -- '%d\n' "${EPOCHSECONDS}"; }

# Next, we try for 'printf' (bash 4.2 and newer, some ksh)
elif printf '%(%s)T\n' -1 | grep "^[0-9].*$" >/dev/null 2>&1; then
    get_epoch() { printf '%(%s)T\n' -1; }

# Next we try for 'date'
# Because some 'date' variants will return a literal '+%s', we perform a capability check
elif date -u +%s | grep "^[0-9].*$" >/dev/null 2>&1; then
    get_epoch() { date -u +%s; }

# Next we try for 'perl', fairly ubiquitous but fading away slowly...
elif command -v perl >/dev/null 2>&1; then
    get_epoch() { perl -e 'print($^T."\n");'; }
    # Alternative: get_epoch() { perl -e 'print time."\n";'; }

# We can try reaching out to the internet...
elif command -v curl >/dev/null 2>&1; then
    if curl -s -m 1 http://icanhazepoch.com/ | grep "^[0-9].*$" >/dev/null 2>&1; then
        get_epoch() { curl -s -m 1 http://icanhazepoch.com/; }
    fi

# Otherwise we failover to a portable-ish shell method
else

# Calculate how many seconds since epoch
# Portable version based on http://www.etalabs.net/sh_tricks.html
# We strip leading 0's in order to prevent unwanted octal math
# This seems terse, but the vars are the same as their 'date' formats
    get_epoch() {
        #TODO: Update format on these vars
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

# Calculate how many days since epoch
epochdays() {
  printf -- '%s\n' "$(( $(epoch) / 86400 ))"
}

# To get the epoch date at particular times
#BSD $(date -j -f "%Y-%m-%dT%T" "$1" "+%s")
#Busybox $(date -d "${1//T/ }" +%s)
