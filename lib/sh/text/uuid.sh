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

# RFC4122-style UUIDs
# I just thought I'd take a brief moment for a shout-out. intl-spectrum.com had
# a couple of great articles by Nathan Rector that I referenced for v1 and v4.
# They managed to dumb this down enough _and_ throw in a couple of non-obvious
# nuggets of technical information that other resources didn't clearly articulate

# UUID's are basically strings of hex with _at least_ the following byte features
# adc763c3-e5cb-43bd-a0ae-5d11615562bf
# Version ------^    ^    ^^-- Must be '17' if user generated
#                    ^-------- Must be '8', '9', 'a' or 'b'.

# Helper function to pull a bunch of hex-ish looking chars from /dev/urandom
# Takes one arg: the number of chars to pull.  Defaults to 36.
_uuid_randchars() {
  tr -dc a-f0-9 < /dev/urandom | fold -w 1 | head -n "${1:-36}"
}

# Helper function for pulling the first mac address from 'ifconfig'
_uuid_getmac() {
  ifconfig | 
    grep -Eo '([[:xdigit:]]{1,2}[:-]){5}[[:xdigit:]]{1,2}' | 
    head -n 1 | 
    tr -d ':'
}

# Helper function to convert hostname to a hex string
_uuid_getnode() {
  # Initialise our hostname var
  _uuid_hostname="${HOSTNAME:-$(uname -n)}"
  # Stack the var until it's more than 5 chars long
  # Each char when output takes two chars for hex 
  # representation.  Ergo, 5 ascii chars = 10 in hex
  while (( "${#_uuid_hostname}" < 5 )); do
    _uuid_hostname="${_uuid_hostname}${HOSTNAME:-$(uname -n)}"
  done
  
  # We start with '17' to indicate that this is a user generated value
  # Then we churn out our 10 extra chars, totalling 12
  printf -- '%s' "17"
  printf -- '%s\n' "${_uuid_hostname}" |
    fold -w 1 | 
    head -n 5 | 
    while read -r _uuid_char; do
      printf -- '%02x' \'"${_uuid_char}"
    done
  printf -- '%s\n' ""
}

# Helper function to generate/iterate a clock sequence for v1 UUID's
_uuid_clockseq() {
  # If we have a UUID_CLOCK env var, then we iterate it
  if (( "${#UUID_CLOCK}" > 0 )); then
    UUID_CLOCK=$(printf -- '%x\n' $(( 0x"${UUID_CLOCK}" + 1 )) )
  # Otherwise, we generate it
  else
    _uuid_9th_byte=( 8 9 a b )
    UUID_CLOCK="${_uuid_9th_byte[RANDOM%4]}$(_uuid_randchars 3 | paste -sd '' -)"
  fi
  export UUID_CLOCK
}

# Helper function to try to ensure outputs are consistent and wihin 
_uuid_format() {
  case "${1}" in
    (v[1-8]|[1-8]) _uuid_7th_byte="${1/v/}" ;;
    (*)
    ;;
  esac
  _uuid_9th_byte=( 8 9 a b )

  _uuid_i=1
  while read -r _uuid_char; do
    (( _uuid_i == 37 )) && break
    (( _uuid_i == 13 )) && _uuid_char="4"
    case "${_uuid_i}" in
      (9|14|19|24) printf -- '%s' "-" ;;
      (15)         printf -- '%s' "${_uuid_7th_byte}" ;;
      (20)         printf -- '%s' "${_uuid_9th_byte[RANDOM%4]}" ;;
      (*)          printf -- '%s' "${_uuid_char}" ;;
    esac
    (( _uuid_i++ ))
  done
  printf -- '%s\n' ""
}

# Helper function to get time in a usable format
# i.e. the number of 100's of nanoseconds since 15 Oct 1582.
# The UUID Epoch is 00:00:00, 15 Oct 1582.
# Reason: The date of the Gregorian reform to the Christian calendar.
# See: https://datatracker.ietf.org/doc/html/rfc4122
_uuid_gettime() {
  # TODO: Rope in get_epoch()
  if ! date +%s 2>&1 | grep "^[0-9].*$" >/dev/null 2>&1; then
    printf -- 'uuid: %s\n' "This library requires a version of 'date' that supports epoch time" >&2
    exit 1
  fi

  # TODO: Failover to simply multiplying the output of get_epoch()
  if ! date +%N 2>&1 | grep "^[0-9].*$" >/dev/null 2>&1; then
    printf -- 'uuid: %s\n' "This library requires a version of 'date' that supports nanosecond time" >&2
    exit 1
  fi

  # The following magical numbers sourced from Go's UUID implementation
  # Copyright (c) 2009,2014 Google Inc. BSD 3-Clause License
  _uuid_lillian=2299160                            # Julian day of 15 Oct 1582
  _uuid_unix=2440587                               # Julian day of 1 Jan 1970
  _uuid_epoch="$(( _uuid_unix - _uuid_lillian ))"  # Days between epochs
  _uuid_g1582="$(( _uuid_epoch * 86400 ))"         # seconds between epochs
  _uuid_g1582ns100="$(( _uuid_g1582 * 10000000 ))" # 100s of a nanoseconds between epochs

  # We throw in our own magic numbers
  # TODO: I don't think these are quite exact, I'll need some deeper focus on this
  _uuid_ns100_now="$(( $(date -u +%s) * 10000000 ))"
  _uuid_nano_100="$(( $(date -u +%N) / 100 ))"

  # We pre-prend with '1', add the lot and emit it in hex format
  printf -- '1%x' "$(( _uuid_ns100_now + _uuid_nano_100 + _uuid_g1582ns100 ))"

  unset -v _uuid_lillian _uuid_unix _uuid_epoch _uuid_g1582 _uuid_g1582ns100
  unset -v _uuid_ns100_now _uuid_nano_100
}

uuid_nil() {
  printf -- '%s\n' "00000000-0000-0000-0000-000000000000"
}

# Date-time and mac address
# TODO: Figure out "value too great for base" error that pops up from time to time.
#       This looks like an issue with _uuid_gettime()
uuid_v1() {
  if command -v uuidgen >/dev/null 2>&1; then
    uuidgen --time
    return 0
  fi

  # If we get to this point, we're generating one from scratch
  # UUIDv1's have the following requirements:
  # adc763c3-e5cb-13bd-a0ae-5d11615562bf
  # Must be '1' --^    ^    ^^-- Must be '17' if user generated
  #                    ^-- Must be '8', '9', 'a' or 'b'.
  _uuid_time=$(_uuid_gettime)
  # Run _uuid_clockseq to set/update UUID_CLOCK env var
  _uuid_clockseq
  # First, we try to get a mac address from the system
  _uuid_node="$(_uuid_getmac)"
  # If that doesn't give us a result, we call _uuid_getnode
  (( "${#_uuid_node}" == 0 )) && _uuid_node=$(_uuid_getnode)

  printf -- '%s\n' "${_uuid_time}${UUID_CLOCK}${_uuid_node}" | 
    fold -w 1 | 
    _uuid_format v1

  unset -v _uuid_i _uuid_char _uuid_time _uuid_node
}

# Date-time and mac address, DCE security version
# https://pubs.opengroup.org/onlinepubs/9696989899/chap5.htm#tagcjh_08_02_01_01
uuid_v2() {
  :
}

# Looking for 'uuid_v3()'?  It's uuid_hash, keep scrolling!

# Fully random using /dev/urandom
# RFC4122 compliant as best I can tell
uuid_v4() {
  if command -v uuidgen >/dev/null 2>&1; then
    uuidgen --random
    return 0
  fi
  
  if [[ -r /proc/sys/kernel/random/uuid ]]; then
    cat /proc/sys/kernel/random/uuid
    return 0
  fi

  # If we get to this point, we're generating one from scratch
  _uuid_randchars 37 | _uuid_format 4
}

# uuid_v3 and uuid_v5 in one function.
# Namespace hash, md5 or sha-1
uuid_hash() {
  while (( "${#}" > 0 )); do
    case "${1}" in
      (md5|v3)  _uuid_hashmode=md5 ;;
      (sha1|v5) _uuid_hashmode=sha1 ;;
      (@dns)    _uuid_namespace='6ba7b810-9dad-11d1-80b4-00c04fd430c8' ;;
      (@url)    _uuid_namespace='6ba7b811-9dad-11d1-80b4-00c04fd430c8' ;;
      (@oid)    _uuid_namespace='6ba7b812-9dad-11d1-80b4-00c04fd430c8' ;;
      (@x500)   _uuid_namespace='6ba7b814-9dad-11d1-80b4-00c04fd430c8' ;;
      (@custom) _uuid_namespace="${2}" ;;
      (*)       _uuid_name="${2}" ;;
    esac
    shift 1
  done

  if (( "${#_uuid_hashmode}" )); then
    printf -- 'uuid_gen: %s\n' "A hashmode must be selected: 'md5' or 'sha1'" >&2
    exit 1
  fi

  if (( "${#_uuid_namespace}" )); then
    printf -- 'uuid_gen: %s\n' "A namespace must be selected: '@dns', '@url', '@oid', '@x500' or '@custom" >&2
    exit 1
  fi
  
  if command -v uuidgen >/dev/null 2>&1; then
    uuidgen --"${_uuid_hashmode}" --namespace "${_uuid_namespace}" --name "${_uuid_name}"
    return 0
  fi

  case "${_uuid_hashmode}" in
    (md5)
      printf -- '%s' "${_uuid_namespace}${_uuid_name}" |
        md5sum |
        _uuid_format 3
    ;;
    (sha1)
      printf -- '%s' "${_uuid_namespace}${_uuid_name}" |
        sha1sum |
        _uuid_format 5
    ;;
  esac
}

# https://datatracker.ietf.org/doc/html/draft-peabody-dispatch-new-uuid-format
uuid_v6() {
  printf -- '%s\n' "Watch this space..."
}

uuid_v7() {
  printf -- '%s\n' "Watch this space..."
}

uuid_v8() {
  printf -- '%s\n' "Watch this space..."
}

uuid_pseudo() {
  od -x /dev/urandom | head -n 1 | awk '{OFS="-"; print $2$3,$4,$5,$6,$7$8$9}'
}

uuid_gen() {
  case "${1}" in
    (-0|-nil|-null)  uuid_stdout="$(uuid_nil)" ;;
    (-1|--time)      uuid_stdout="$(uuid_v1)" ;;
    (-2)             uuid_stdout="$(uuid_v2)" ;;
    (-3|--md5)       uuid_stdout="$(uuid_hash v3)" ;;
    (-4|-r|--random) uuid_stdout="$(uuid_v4)" ;;
    (-5|--sha1)      uuid_stdout="$(uuid_hash v5)" ;;
    (--pseudo)       uuid_stdout="$(uuid_pseudo)" ;;
    ('')             uuid_stdout="$(uuid_v4)" ;;
  esac
  printf -- '%s\n' "${uuid_stdout}"
  # Retvals
  uuid_rc=0
  export uuid_stdout uuid_rc
}
