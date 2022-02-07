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


# Usage: get_sourceforge [project] [linux|mac|windows]
fetch_sourceforge() {
  # We require 'curl' and 'jq'
  fail_count=0
  for binary in curl jq; do
    if ! command -v "${binary}" >/dev/null 2>&1; then
      printf -- '%s\n' "${binary} is required but was not found in PATH" >&2
      (( fail_count++ ))
    fi
  done
  (( fail_count > 0 )) && return 1
  unset -v binary fail_count

  local sf_proj os_str curl_opts curl_target element remote_target
  sf_proj="${1:?No sourceforge project defined}"
  os_str="${2:-auto}"
  curl_opts=( -s -L -I -o /dev/null -w '%{url_effective}' )

  mapfile -t < <(
    curl -s "https://sourceforge.net/projects/${sf_proj}/best_release.json" | 
      jq -r '.platform_releases[].url'
  )

  # shellcheck disable=SC2068
  for element in ${MAPFILE[@]}; do
    case "${element}" in
      (*[lL]inux*)           linux_src="${element}" ;;
      (*[mM]ac*|*[dD]arwin*) mac_src="${element}" ;;
      (*[wW]in*)             win_src="${element}" ;;
    esac
  done

  case "${os_str}" in
    ([lL]inux) curl_target="${linux_src}" ;;
    ([mM]ac*)  curl_target="${mac_src}" ;;
    ([wW]in*)  curl_target="${win_src}" ;;
    (auto)
      case "$(uname)" in
        (Linux)      curl_target="${linux_src}" ;;
        (Darwin)     curl_target="${mac_src}" ;;
        (Win*|*WIN*) curl_target="${win_src}" ;;
      esac
  esac

  remote_target="$(curl "${curl_opts[@]}" "${curl_target}")"
  printf -- '%s\n' "Attempting to fetch ${remote_target}..."
  curl -O "${remote_target}" || return 1
}

software::fetch() {
  local local_target remote_target
  remote_target="${1:?No target specified}"
  remote_target="$(curl "${remote_target}" -s -L -I -o /dev/null -w '%{url_effective}')"
  local_target="${remote_target##*/}"
  printf -- '%s\n' "Attempting to fetch ${remote_target}..."
  curl "${remote_target}" > "${local_dir}"/"${local_target}" || return 1  
}
