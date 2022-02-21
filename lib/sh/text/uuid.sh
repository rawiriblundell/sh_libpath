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

uuid_nil() {
  printf -- '%s\n' "00000000-0000-0000-0000-000000000000"

}

# date-time and mac address
uuid_v1() {
  :
}


uuid_v2() {
  :
}

# Namespace hash, md5
uuid_v3() {
  :
}

# Fully random using /dev/urandom
# Not fully RFC4122 compliant (yet?)
uuid_v4() {
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
  :
}

uuid_pseudo() {
  od -x /dev/urandom | head -n 1 | awk '{OFS="-"; print $2$3,$4,$5,$6,$7$8$9}'
}

uuid_gen() {
  case "${1}" in
    (0|nil|null) uuid_stdout="$(uuid_nil)" ;;
    (1) uuid_stdout="$(uuid_v1)" ;;
    (2) uuid_stdout="$(uuid_v2)" ;;
    (3) uuid_stdout="$(uuid_v3)" ;;
    (4) uuid_stdout="$(uuid_v4)" ;;
    (5) uuid_stdout="$(uuid_v5)" ;;
    ('')
      if [[ -r /proc/sys/kernel/random/uuid ]]; then
        uuid_stdout="$(</proc/sys/kernel/random/uuid)"
      else
        uuid_stdout="$(uuid_pseudo)"
      fi
    ;;
  esac
  printf -- '%s\n' "${uuid_stdout}"
  # Retvals
  uuid_rc=0
  export uuid_stdout uuid_rc
}
