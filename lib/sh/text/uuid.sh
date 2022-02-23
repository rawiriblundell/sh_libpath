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
}

# Date-time and mac address, DCE security version
uuid_v2() {
  :
}

# Namespace hash, md5
uuid_v3() {
  if command -v uuidgen >/dev/null 2>&1; then
    uuidgen --md5
    return 0
  fi
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

  _uuid_i=0
  while read -r _uuid_char; do
    _uuid_chars[_uuid_i]="${_uuid_char}"
    (( _uuid_i++ ))
  done < <(tr -dc a-f0-9 < /dev/urandom | fold -w 1 | head -n 36)

  for (( _uuid_i=1; _uuid_i<36; _uuid_i++ )); do
    case "${_uuid_i}" in
      (9|18|23) printf -- '%s' "-" ;;
      (14)      printf -- '%s' "-4" ;;
      (*)       printf -- '%s' "${_uuid_chars[_uuid_i]}" ;;
    esac
  done
  printf -- '%s\n' ""
  unset -v _uuid_i _uuid_char _uuid_chars
}

# Namespace hash, sha-1
uuid_v5() {
  if command -v uuidgen >/dev/null 2>&1; then
    uuidgen --sha1
    return 0
  fi
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