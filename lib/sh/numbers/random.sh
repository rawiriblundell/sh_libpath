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

[ -n "${_SH_LOADED_numbers_random+x}" ] && return 0
_SH_LOADED_numbers_random=1

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
        secs_var=$(TZ=GMT0 date +%S)
        mins_var=$(TZ=GMT0 date +%M)
        hour_var=$(TZ=GMT0 date +%H)
        day_var=$(TZ=GMT0 date +%j | sed 's/^0*//')
        yr_offset=$(( $(TZ=GMT0 date +%Y) - 1600 ))
        year_var=$(( (yr_offset * 365 + yr_offset / 4 - yr_offset / 100 + yr_offset / 400 + day_var - 135140) * 86400 ))

        printf -- '%s\n' "$(( year_var + (${hour_var#0} * 3600) + (${mins_var#0} * 60) + ${secs_var#0} ))"
    fi
}

# A BSD-style Linear Congruential Generator, range 0-32767, just like $RANDOM
# See: https://rosettacode.org/wiki/Linear_congruential_generator
# Usage: lcgrng (optional: number count, default:1) (optional: seed, default: epoch in seconds)
random_lcg() {
    rn_count="${1:-1}"
    rn_seed="${2:-$(random_seed)}"

    # Here's an unnecessary nod to FreeBSD's rand.c
    if [ "${rn_seed}" = 0 ]; then
        rn_seed=123459876
    fi

    while [ "${rn_count}" -gt 0 ]; do
        # BSD style modulus'ed against 2^31
        rn_seed=$(( (1103515245 * rn_seed + 12345) % 2147483648 ))

        # Microsoft style
        #rn_seed=$(( (214013 * rn_seed + 2531011) % 2147483648 ))

        # print the generated number as an unsigned int (i.e. positive decimal)
        # Divided by 2^16
        printf -- "%u\n" "$(( rn_seed / 65536 ))"

        # Decrement the counter
        rn_count=$(( rn_count - 1 ))
    done
}

random_xorshift128plus() {
    n_count="${1:-1}"
    n_min="${2:-1}"
    seed0=4          # RFC 1149.5
    seed1="${4:-$(random_Seed)}"

    # Figure out our default max_rand, using 'getconf'
    case "$(getconf LONG_BIT 2>/dev/null)" in
        (64)
            # 2^63-1
            max_rand=9223372036854775807
        ;;
        (32)
            # 2^31-1
            max_rand=2147483647
        ;;
        (*)
            # 2^15-1
            max_rand=32767
        ;;
    esac

    n_max="${3:-max_rand}"

    nRange=$(( n_max - n_min + 1 ))

    int0="${seed0}"
    int1="${seed1}"
    while (( n_count > 0 )); do
        # This is required for modulo de-biasing
        # We figure out the number of problematic integers to skip
        # in order to bring modulo back into uniform alignment
        # This is significantly faster than naive rejection sampling
        #skip_ints=$(( ((max_rand % n_max) + 1) % n_max ))
        skip_ints=$(( (max_rand - nRange) % nRange ))

        # xorshift128+ with preselected triples
        int1=$(( int1 ^ int1 << 23 ))
        int1=$(( int1 ^ int1 >> 17 ))
        int1=$(( int1 ^ int0 ))
        int1=$(( int1 ^ int0 >> 26 ))
        seed1="${int1}"
        
        # If our generated int is larger than the number of problematic ints
        # Then we can modulo it safely, otherwise drop it and generate again
        if (( (seed0 + seed1) > skip_ints )); then
            #printf '%u\n' "$(( ((seed0 + seed1) % n_max) + 1 ))"
            printf -- '%u\n' "$(( ((seed0 + seed1) % nRange) + n_min))"
            n_count=$(( n_count - 1 ))
        fi
    
    done 
}

# Get a number of random integers using $RANDOM with debiased modulo
randInt() {
  local n_count n_min n_max n_mod rand_thres i x_int
  n_count="${1:-1}"
  n_min="${2:-1}"
  n_max="${3:-32767}"
  n_mod=$(( n_max - n_min + 1 ))
  if (( n_mod == 0 )); then return 3; fi
  # De-bias the modulo as best as possible
  rand_thres=$(( -(32768 - n_mod) % n_mod ))
  if (( rand_thres < 0 )); then
    (( rand_thres = rand_thres * -1 ))
  fi
  i=0
  while (( i < n_count )); do
    x_int="${RANDOM}"
    if (( x_int > ${rand_thres:-0} )); then
      printf -- '%d\n' "$(( x_int % n_mod + n_min ))"
      (( i++ ))
    fi
  done
}
