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

get_dns() {
  case "${OSSTR:-$(uname -s)}" in
    (mac|Darwin)
      printf -- '%s\n' "Attempting lookup test using 'scutil' command..." >&2
      scutil --dns |
        awk '/nameserver/{ a[$3]++} END { for (b in a) {print b } }'
      return 0
    ;;
    ([Ll]inux)
      # TODO: Update to test against IP addresses rather than 'Global'
      if command -v resolvectl >/dev/null 2>&1; then
        printf -- '%s\n' "Attempting lookup test using 'resolvectl' command..." >&2
        # shellcheck disable=SC2046
        set -- $(resolvectl dns | grep Global)
        printf -- '%s\n' "${@:2}"
        return 0
      fi
      if command -v systemd-resolv >/dev/null 2>&1; then
        printf -- '%s\n' "Attempting lookup test using 'systemd-resolve' command..." >&2
        # shellcheck disable=SC2046
        set -- $(
          systemd-resolve --status |
            awk '/DNS Server:/{flag=1;next}/DNS Domain/{flag=0}flag' |
            paste -sd ' ' - |
            tr -s '[:space:]'
        )
        printf -- '%s\n' "${@:3}"
        return 0
      fi
      if command -v nm-tool >/dev/null 2>&1; then
        nm-tool | awk '/DNS/{print $2}' | paste -sd ',' -
        return 0
      fi
      if command -v nmcli >/dev/null 2>&1; then
        # printf -- '%s\n' "Attempting lookup test using 'nmcli' command..." >&2
        if nmcli dev list >/dev/null 2>&1; then
          nmcli dev list | awk 'tolower($0) ~ /dns/{print $2}' | paste -sd ',' -
          return 0
        elif nmcli device show >/dev/null 2>&1; then
          nmcli --fields ip4.dns dev show | awk '/./{print $2}' | paste -sd ',' -
          return 0
        fi
      fi
    ;;
  esac
  if command -v host >/dev/null 2>&1; then
    printf -- '%s\n' "Attempting lookup test using 'host' command..." >&2
    host -v something.unknown | awk -F "[ #]" '/Received /{print$5}' | uniq
    return 0
  fi
  if [ -r /etc/resolv.conf ]; then
    printf -- '%s\n' "Parsing /etc/resolv.conf..." >&2
    awk '/nameserver/{print $2}' /etc/resolv.conf | paste -sd ',' -
    return 0
  fi
  # As above, but for OSX
  if [ -r /var/run/resolv.conf ]; then
    printf -- '%s\n' "Parsing /etc/resolv.conf..." >&2
    awk '/nameserver/{print $2}' /etc/resolv.conf | paste -sd ',' -
    return 0
  fi
  # If we get to this point, we have failed.
  printf -- '%s\n' "Unable to determine any dns servers" >&2
  return 1
}
