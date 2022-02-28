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

# Name string is a fully-qualified domain name
_uuid_namespace_dns='6ba7b810-9dad-11d1-80b4-00c04fd430c8'
# Name string is a URL
_uuid_namespace_url='6ba7b811-9dad-11d1-80b4-00c04fd430c8'
# Name string is an ISO OID
_uuid_namespace_oid='6ba7b812-9dad-11d1-80b4-00c04fd430c8'
# Name string is an X.500 DN (in DER or a text output format)
_uuid_namespace_x500='6ba7b814-9dad-11d1-80b4-00c04fd430c8'

# Helper function to pull a bunch of hex-ish looking chars from /dev/urandom
# Takes one arg: the number of chars to pull.  Defaults to 36.
_uuid_randchars() {
  tr -dc a-f0-9 < /dev/urandom | fold -w 1 | head -n "${1:-36}"
}

# Helper function to convert hostname to a hex string
_uuid_getnode() {
  # Initialise our hostname var
  _uuid_hostname="${HOSTNAME:-$(uname -n)}"
  # Stack the var until it's more than 6 chars long
  # Each char when output takes two chars for hex representation
  # ergo, 6 ascii chars = 12 in hex
  while (( "${#_uuid_hostname}" < 6 )); do
    _uuid_hostname="${_uuid_hostname}${HOSTNAME:-$(uname -n)}"
  done
  
  printf -- '%s\n' "${_uuid_hostname}" |
    fold -w 1 | 
    head -n 6 | 
    while read -r _uuid_char; do
      printf -- '%02x' \'"${_uuid_char}"
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
uuid_v1() {
  if command -v uuidgen >/dev/null 2>&1; then
    uuidgen --time
    return 0
  fi

  _uuid_time=$(_uuid_gettime)
  _uuid_clock=
  _uuid_node=$(_uuid_getnode)

  _uuid_i=1
  while read -r _uuid_char; do
    case "${_uuid_i}" in
      (9|18|23) printf -- '%s' "-" ;;
      (14)      printf -- '%s' "-4" ;;
      (*)       printf -- '%s' "${_uuid_char}" ;;
    esac
    (( _uuid_i++ ))
  done < <(printf -- '%s\n' "${_uuid_time}${_uuid_clock}${_uuid_node}" | fold -w 1)
  printf -- '%s\n' ""
  unset -v _uuid_i _uuid_char _uuid_time _uuid_clock _uuid_node
}

# Date-time and mac address, DCE security version
# https://pubs.opengroup.org/onlinepubs/9696989899/chap5.htm#tagcjh_08_02_01_01
uuid_v2() {
  :
}

# Namespace hash, md5
uuid_v3() {
  if command -v uuidgen >/dev/null 2>&1; then
    uuidgen --md5
    return 0
  fi

  # Namespace+string, then md5'd, first 128 bits sliced off and some tweaks
}

# Fully random using /dev/urandom
# Native method is not fully RFC4122 compliant (yet?)
uuid_v4() {
  if command -v uuidgen >/dev/null 2>&1; then
    uuidgen --random
    return 0
  fi
  
  if [[ -r /proc/sys/kernel/random/uuid ]]; then
    cat /proc/sys/kernel/random/uuid
    return 0
  fi

  _uuid_i=1
  while read -r _uuid_char; do
    case "${_uuid_i}" in
      (9|18|23) printf -- '%s' "-" ;;
      (14)      printf -- '%s' "-4" ;;
      (*)       printf -- '%s' "${_uuid_char}" ;;
    esac
    (( _uuid_i++ ))
  done < <(_uuid_randchars 35)
  printf -- '%s\n' ""
  unset -v _uuid_i _uuid_char
}

# Namespace hash, sha-1
uuid_v5() {
  if command -v uuidgen >/dev/null 2>&1; then
    uuidgen --sha1
    return 0
  fi
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
    (-3|--md5)       uuid_stdout="$(uuid_v3)" ;;
    (-4|-r|--random) uuid_stdout="$(uuid_v4)" ;;
    (-5|--sha1)      uuid_stdout="$(uuid_v5)" ;;
    (--pseudo)       uuid_stdout="$(uuid_pseudo)" ;;
    ('')             uuid_stdout="$(uuid_v4)" ;;
  esac
  printf -- '%s\n' "${uuid_stdout}"
  # Retvals
  uuid_rc=0
  export uuid_stdout uuid_rc
}
