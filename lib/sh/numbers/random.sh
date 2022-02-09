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
        secsVar=$(TZ=GMT0 date +%S)
        minsVar=$(TZ=GMT0 date +%M)
        hourVar=$(TZ=GMT0 date +%H)
        dayVar=$(TZ=GMT0 date +%j | sed 's/^0*//')
        yrOffset=$(( $(TZ=GMT0 date +%Y) - 1600 ))
        yearVar=$(( (yrOffset * 365 + yrOffset / 4 - yrOffset / 100 + yrOffset / 400 + dayVar - 135140) * 86400 ))

        printf -- '%s\n' "$(( yearVar + (${hourVar#0} * 3600) + (${minsVar#0} * 60) + ${secsVar#0} ))"
    fi
}

# A BSD-style Linear Congruential Generator, range 0-32767, just like $RANDOM
# See: https://rosettacode.org/wiki/Linear_congruential_generator
# Usage: lcgrng (optional: number count, default:1) (optional: seed, default: epoch in seconds)
random_lcg() {
    rnCount="${1:-1}"
    rnSeed="${2:-$(random_seed)}"

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
        printf -- "%u\n" "$(( rnSeed / 65536 ))"

        # Decrement the counter
        rnCount=$(( rnCount - 1 ))
    done
}

random_xorshift128plus() {
    nCount="${1:-1}"
    nMin="${2:-1}"
    seed0=4          # RFC 1149.5
    seed1="${4:-$(random_Seed)}"

    # Figure out our default maxRand, using 'getconf'
    case "$(getconf LONG_BIT 2>/dev/null)" in
        (64)
            # 2^63-1
            maxRand=9223372036854775807
        ;;
        (32)
            # 2^31-1
            maxRand=2147483647
        ;;
        (*)
            # 2^15-1
            maxRand=32767
        ;;
    esac

    nMax="${3:-maxRand}"

    nRange=$(( nMax - nMin + 1 ))

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
            printf -- '%u\n' "$(( ((seed0 + seed1) % nRange) + nMin))"
            nCount=$(( nCount - 1 ))
        fi
    
    done 
}

# Get a number of random integers using $RANDOM with debiased modulo
randInt() {
  local nCount nMin nMax nMod randThres i xInt
  nCount="${1:-1}"
  nMin="${2:-1}"
  nMax="${3:-32767}"
  nMod=$(( nMax - nMin + 1 ))
  if (( nMod == 0 )); then return 3; fi
  # De-bias the modulo as best as possible
  randThres=$(( -(32768 - nMod) % nMod ))
  if (( randThres < 0 )); then
    (( randThres = randThres * -1 ))
  fi
  i=0
  while (( i < nCount )); do
    xInt="${RANDOM}"
    if (( xInt > ${randThres:-0} )); then
      printf -- '%d\n' "$(( xInt % nMod + nMin ))"
      (( i++ ))
    fi
  done
}
