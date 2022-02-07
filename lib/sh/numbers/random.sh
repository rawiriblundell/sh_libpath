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

# Function to generate a reliable seed for whatever method requires one
# Because 'date +%s' isn't entirely portable, we try other methods to get the epoch
random_seed() {
  # First we check if /dev/urandom is available.
  # We used to have a method_urandom.  /dev/urandom can generate numbers fast
  # But selecting numbers in ranges etc made for a fairly slow method
  if [ -c /dev/urandom ] && command -v od >/dev/null 2>&1; then
    # Get a string of bytes from /dev/urandom using od
    od -N 4 -A n -t uL /dev/urandom | tr -d '\n' | awk '{$1=$1+0};1'
  # Otherwise we try to get another seed
  elif date '+%s' >/dev/null 2>&1; then
    date '+%s'
  # Portable workaround based on http://www.etalabs.net/sh_tricks.html
  # We take extra steps to try to prevent accidental octal interpretation
  else
    local secsVar=$(TZ=GMT0 date +%S)
    local minsVar=$(TZ=GMT0 date +%M)
    local hourVar=$(TZ=GMT0 date +%H)
    local dayVar=$(TZ=GMT0 date +%j | sed 's/^0*//')
    local yrOffset=$(( $(TZ=GMT0 date +%Y) - 1600 ))
    local yearVar=$(( (yrOffset * 365 + yrOffset / 4 - yrOffset / 100 + yrOffset / 400 + dayVar - 135140) * 86400 ))

    printf '%s\n' "$(( yearVar + (${hourVar#0} * 3600) + (${minsVar#0} * 60) + ${secsVar#0} ))"
  fi
}

random_lcg() {
    # Linear congruential generator, range 0 - 32767
    # See: https://rosettacode.org/wiki/Linear_congruential_generator
    # Usage: lcgrng (optional: number count, default:1) (optional: seed, default: epoch in seconds)
    rnCount="${1:-1}"
    rnSeed="${2:-$(date +%s)}"

    # Here's an unnecessary nod to FreeBSD's rand.c
    if [ "${rnSeed}" = 0 ]; then
        rnSeed=123459876
    fi

    while [ "${rnCount}" -gt 0 ]; do
        # BSD style modulus'ed against 2^31
        rnSeed=$(( (1103515245 * rnSeed + 12345) % 2147483648 ))

        # Microsoft style
        #rnSeed=$(( (214013 * rnSeed + 2531011) % 2147483648 ))

        # print the generated number as an unsigned int (i.e. positive decimal)
        # Divided by 2^16
        printf "%u\n" "$(( rnSeed / 65536 ))"

        # Decrement the counter
        rnCount=$(( rnCount - 1 ))
    done

    #---

    # If the special variable isn't available (e.g. dash shell), we fall back to a BSD-style
    # Linear congruential generator (LCG) which we use to create our own '$RANDOM' variable
    # See: https://rosettacode.org/wiki/Linear_congruential_generator

    # If two invocations of RANDOM are the same (or both are blank), 
    # then we're working with a shell that does not support $RANDOM.
    if [ "${RANDOM}" = "${RANDOM}" ]; then

        # We set the initial seed for the LCG
        # First we check if /dev/urandom is available.
        if [ -c /dev/urandom ] && command -v od >/dev/null 2>&1; then
            # Get a string of bytes from /dev/urandom using od
            rnSeed=$(od -N 4 -A n -t uL /dev/urandom | tr -d " ")
        # Otherwise we can just seed it using the epoch
        else
            rnSeed=$(date +%s)
        fi
        
        # BSD style LCG modulus'ed against 2^31
        rnSeed=$(( (1103515245 * rnSeed + 12345) % 2147483648 ))

        # Print as an unsigned integer, divided by 2^16
        RANDOM="$(printf "%u\n" "$(( rnSeed / 65536 ))")"
    fi
}

random_xorshift128plus() {
    nCount="${1:-1}"
    nMin="${2:-1}"
    seed0=4          # RFC 1149.5
    seed1="${4:-$(Fn_getSeed)}"

    # Figure out our default maxRand, using 'getconf'
    if [ "$(getconf LONG_BIT)" -eq 64 ]; then
        # 2^63-1
        maxRand=9223372036854775807
    elif [ "$(getconf LONG_BIT)" -eq 32 ]; then
        # 2^31-1
        maxRand=2147483647
    else
        # 2^15-1
        maxRand=32767
    fi

    nMax="${3:-maxRand}"

    nRange=$(( nMax - nMin  + 1 ))

    int0="${seed0}"
    int1="${seed1}"
    while (( nCount > 0 )); do
        # This is required for modulo de-biasing
        # We figure out the number of problematic integers to skip
        # in order to bring modulo back into uniform alignment
        # This is significantly faster than naive rejection sampling
        #skipInts=$(( ((maxRand % nMax) + 1) % nMax ))
        skipInts=$(( (maxRand - nRange) % nRange ))

        # xorshift128+ with preselected triples
        int1=$(( int1 ^ int1 << 23 ))
        int1=$(( int1 ^ int1 >> 17 ))
        int1=$(( int1 ^ int0 ))
        int1=$(( int1 ^ int0 >> 26 ))
        seed1="${int1}"
        
        # If our generated int is larger than the number of problematic ints
        # Then we can modulo it safely, otherwise drop it and generate again
        if (( (seed0 + seed1) > skipInts )); then
            #printf '%u\n' "$(( ((seed0 + seed1) % nMax) + 1 ))"
            printf '%u\n' "$(( ((seed0 + seed1) % nRange) + nMin))"
            nCount=$(( nCount - 1 ))
        fi
    
    done 
}
