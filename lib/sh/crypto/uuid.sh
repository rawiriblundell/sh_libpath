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

[ -n "${_SHELLAC_LOADED_crypto_uuid+x}" ] && return 0
_SHELLAC_LOADED_crypto_uuid=1

# RFC4122-style UUIDs
# I just thought I'd take a brief moment for a shout-out. intl-spectrum.com had
# a couple of great articles by Nathan Rector that I referenced for v1 and v4.
# They managed to dumb this down enough _and_ throw in a couple of non-obvious
# nuggets of technical information that other resources didn't clearly articulate

# UUID's are basically strings of hex with _at least_ the following byte features
# adc763c3-e5cb-43bd-a0ae-5d11615562bf
# Version ------^    ^    ^^-- Must be '17' if user generated
#                    ^-------- Must be '8', '9', 'a' or 'b'.

# @internal
_uuid_randchars() {
  tr -dc a-f0-9 < /dev/urandom | fold -w 1 | head -n "${1:-36}"
}

# @internal
_uuid_getmac() {
  ifconfig | 
    grep -Eo '([[:xdigit:]]{1,2}[:-]){5}[[:xdigit:]]{1,2}' | 
    head -n 1 | 
    tr -d ':'
}

# @internal
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

# @internal
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

# @internal
_uuid_format() {
  case "${1}" in
    (v[1-8]|[1-8]) _uuid_7th_byte="${1/v/}" ;;
    (*)
      printf -- 'uuid: %s\n' "Unrecognised version specifier" >&2
      return 1
    ;;
  esac
  _uuid_9th_byte=( 8 9 a b )

  _uuid_i=1
  while read -r _uuid_char; do
    (( _uuid_i == 37 )) && break
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

# @internal
_uuid_gettime() {
  local _uuid_lillian _uuid_unix _uuid_epoch _uuid_g1582 _uuid_g1582ns100
  local _uuid_ns100_now _uuid_nano_100

  # TODO: Rope in time_epoch()
  if ! date +%s 2>&1 | grep "^[0-9].*$" >/dev/null 2>&1; then
    printf -- 'uuid: %s\n' "This library requires a version of 'date' that supports epoch time" >&2
    return 1
  fi

  # TODO: Failover to simply multiplying the output of time_epoch()
  if ! date +%N 2>&1 | grep "^[0-9].*$" >/dev/null 2>&1; then
    printf -- 'uuid: %s\n' "This library requires a version of 'date' that supports nanosecond time" >&2
    return 1
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
}

# @description Return the RFC4122 nil UUID (all zeros).
#
# @stdout 00000000-0000-0000-0000-000000000000
# @exitcode 0 Always
uuid_nil() {
  printf -- '%s\n' "00000000-0000-0000-0000-000000000000"
}

# @description Blindly convert a UUID between little-endian and mixed-endian (Microsoft) byte order.
#   The first three octets are byte-swapped; the remainder are unchanged.
#
# @arg $1 string A valid UUID string
#
# @stdout UUID with first three octets in reversed byte order
# @exitcode 0 Success
# @exitcode 1 No UUID supplied or invalid UUID structure/content
uuid_switch_endian() {
  local _uuid

  # If there's no arg given, there's no point continuing
  if (( $# == 0 )); then
    printf -- '%s\n' "uuid_switch_endian: No UUID supplied." >&2
    return 1
  fi

  _uuid="${1}"

  # Next we try to validate that we're dealing with a UUID
  if command -v validate_uuid >/dev/null 2>&1; then
    if ! validate_uuid "${_uuid}" >/dev/null 2>&1; then
      printf -- 'uuid_switch_endian: Does not appear to be a valid UUID: %s\n' "${_uuid}" >&2
      return 1
    fi
  # If that function's not available, we just throw this cheap length check at it:
  elif (( ${#_uuid:-0} != 36 )); then
    printf -- 'uuid_switch_endian: Does not appear to be a valid UUID: %s\n' "${_uuid}" >&2
    return 1
  fi

  # We explode the UUID to its two-char hex bytes and assign it to a var
  _uuid="$(printf -- '%s\n' "${_uuid}" | tr -d '-' | fold -w 2 | paste -sd ' ' -)"

  # We want word splitting here
  # This assigns each space delimited hex byte to a position in the positional params array
  # shellcheck disable=SC2086
  set -- ${_uuid}

  # Now we simply print out the elements of the positional params array
  # We can see with the first three octets that the positions are rotated
  printf -- '%s-%s-%s-%s-%s\n' \
    "${4}${3}${2}${1}" \
    "${6}${5}" \
    "${8}${7}" \
    "${9}${10}" \
    "${11}${12}${13}${14}${15}${16}"
}

# @description Generate a version 1 (time-based, MAC address) UUID.
#   Uses uuidgen --time if available, otherwise generates from scratch.
#
# @stdout A version 1 UUID string
# @exitcode 0 Always
uuid_v1() {
  local _uuid_i _uuid_char _uuid_time _uuid_node

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
}

# @description Generate a version 2 (DCE security) UUID. (Not yet implemented.)
#
# @exitcode 0 Always
uuid_v2() {
  :
}

# @description Generate a version 4 (fully random) UUID.
#   Uses uuidgen --random, /proc/sys/kernel/random/uuid, or a bash-native fallback.
#
# @stdout A version 4 UUID string
# @exitcode 0 Always
uuid_v4() {
  if command -v uuidgen >/dev/null 2>&1; then
    uuidgen --random
    return 0
  fi
  
  # Linux already does this for us, if it's here, just cat it
  if [[ -r /proc/sys/kernel/random/uuid ]]; then
    cat /proc/sys/kernel/random/uuid
    return 0
  fi

  # As above but for FreeBSD + Linux compat
  if [[ -r /compat/linux/proc/sys/kernel/random/uuid ]]; then
    cat /compat/linux/proc/sys/kernel/random/uuid
    return 0
  fi

  # If we get to this point, we're generating one from scratch
  # This is bash native, based on libuuid's __uuid_generate_random()
  printf -- '%04x%04x-%04x-%04x-%04x-%04x%04x%04x\n' \
    "${RANDOM}" \
    "${RANDOM}" \
    "${RANDOM}" \
    "$(( RANDOM & 0x0fff | 0x4000))" \
    "$(( RANDOM & 0x3fff | 0x8000))" \
    "${RANDOM}" \
    "${RANDOM}" \
    "${RANDOM}"
}

# @description Generate a version 3 (MD5) or version 5 (SHA-1) namespace-based UUID.
#   Select the algorithm and namespace, then provide a unique name.
#
# @arg $@ string md5|v3 or sha1|v5, @dns|@url|@oid|@x500|@custom, and a name string
#
# @stdout A version 3 or 5 UUID string
# @exitcode 0 Success
# @exitcode 1 Missing hashmode, namespace, or name
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
      (*)       _uuid_name="${1}" ;;
    esac
    shift 1
  done

  if (( "${#_uuid_hashmode}" == 0 )); then
    printf -- 'uuid_gen: %s\n' "A hashmode must be selected: 'md5' or 'sha1'" >&2
    return 1
  fi

  if (( "${#_uuid_namespace}" == 0 )); then
    printf -- 'uuid_gen: %s\n' "A namespace must be selected: '@dns', '@url', '@oid', '@x500' or '@custom" >&2
    return 1
  fi

  if (( "${#_uuid_name}" == 0 )); then
    printf -- 'uuid_gen: %s\n' "A unique name must be provided" >&2
    return 1
  fi
  
  if command -v uuidgen >/dev/null 2>&1; then
    uuidgen --"${_uuid_hashmode}" --namespace "${_uuid_namespace}" --name "${_uuid_name}"
    return 0
  fi

  # The below isn't a strict implementation just yet, but it works
  # We should really be converting @custom namespaces and names to big-endian hex
  # Concatening the namespace and name, then hashing, then converting to little-endian
  # That's still not the most strict interpretation of the RFC, but it's close...
  # Other implementations I've read extract bytes from the namespace and append name as a string, go figure!
  case "${_uuid_hashmode}" in
    (md5)
      printf -- '%s' "${_uuid_namespace}${_uuid_name}" |
        md5sum |
        awk '{print $1}' |
        fold -w 1 |
        _uuid_format 3
    ;;
    (sha1)
      printf -- '%s' "${_uuid_namespace}${_uuid_name}" |
        sha1sum |
        awk '{print $1}' |
        fold -w 1 |
        _uuid_format 5
    ;;
  esac
}

# @description Generate a version 6 UUID. (Not yet implemented.)
#
# @stdout Placeholder message
# @exitcode 0 Always
uuid_v6() {
  printf -- '%s\n' "Watch this space..."
}

# @description Generate a version 7 UUID. (Not yet implemented.)
#
# @stdout Placeholder message
# @exitcode 0 Always
uuid_v7() {
  printf -- '%s\n' "Watch this space..."
}

# @description Generate a version 8 UUID. (Not yet implemented.)
#
# @stdout Placeholder message
# @exitcode 0 Always
uuid_v8() {
  printf -- '%s\n' "Watch this space..."
}

# @description Generate a pseudo-UUID using od and /dev/urandom.
#   Not RFC4122 compliant; useful for quick non-critical identifiers.
#
# @stdout A pseudo-UUID string
# @exitcode 0 Always
uuid_pseudo() {
  od -x /dev/urandom | head -n 1 | awk '{OFS="-"; print $2$3,$4,$5,$6,$7$8$9}'
}

# @description Generate a UUID of the specified version (default: v4).
#
# @arg $1 string Optional: -0/-nil/-null, -1/--time, -2, -3/--md5, -4/-r/--random,
#   -5/--sha1, or --pseudo
#
# @stdout A UUID string
# @exitcode 0 Always
uuid_gen() {
  local uuid_stdout
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
}

# @description Validate that a string is a structurally and content-valid UUID.
#   Checks the 8-4-4-4-12 structure and that all characters are hexadecimal.
#   Known issue: 16#var will fail if a hex byte is '00'.
#
# @arg $1 string The UUID string to validate
#
# @exitcode 0 Valid UUID
# @exitcode 1 Invalid structure or non-hex characters found
validate_uuid() {
    local _uuid_hex_char _uuid_string
  _uuid_string="${1:?No UUID provided}"

  # Validate the structure
  # shellcheck disable=SC2046 # We want word splitting here
  set -- $(printf -- '%s\n' "${_uuid_string}" | tr '-' ' ')
  if (( ${#1} != 8 )) || (( ${#2} != 4 )) || (( ${#3} != 4 )) || (( ${#4} != 4 )) || (( ${#5} != 12 )); then
    printf -- '%s: invalid structure\n' "${_uuid_string}" >&2
    return 1
  fi

  # Validate the content
  while read -r _uuid_hex_char; do
    if ! (( "16#${_uuid_hex_char}" )); then
      printf -- '%s: non-hex chars found: %s\n' "${_uuid_string}" "${_uuid_hex_char}">&2
      return 1
    fi
  done < <(printf -- '%s\n' "${_uuid_string}" | tr -d '-' | fold -w 2)

  # No problems found?  Must be a legit UUID then!
  return 0
}
