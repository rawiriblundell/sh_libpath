# LIBRARY_NAME

## Description

## Provides
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
# Provenance: https://raw.githubusercontent.com/rawiriblundell/dotfiles/master/.bashrc
# SPDX-License-Identifier: Apache-2.0

# Display the fingerprint for a host
ssh-fingerprint() {
  local fingerprint keyscanargs
  fingerprint=$(mktemp)

  trap 'rm -f "${fingerprint:?}" 2>/dev/null' RETURN

  # Test if the local host supports ed25519
  # Older versions of ssh don't have '-Q' so also likely won't have ed25519
  # If you wanted a more portable test: 'man ssh | grep ed25519' might be it
  ssh -Q key 2>/dev/null | grep -q ed25519 && keyscanargs=( -t "ed25519,rsa,ecdsa" )

  # If we have an arg "-a" or "--append", we add our findings to known_hosts
  case "${1}" in
    (-a|--append)
      shift 1
      ssh-keyscan "${keyscanargs[@]}" "${*}" > "${fingerprint}" 2> /dev/null
      # If the fingerprint file is empty, then quietly fail
      [[ -s "${fingerprint}" ]] || return 1
      cp "${HOME}"/.ssh/known_hosts{,."$(date +%Y%m%d)"}
      cat "${fingerprint}" ~/.ssh/known_hosts."$(date +%Y%m%d)" |
        sort | 
        uniq > "${HOME}"/.ssh/known_hosts
    ;;
    (''|-h|--help)
      printf -- '%s\n' "Usage: ssh-fingerprint (-a|--append) [list of hostnames]"
      return 1
    ;;
    (*)
      ssh-keyscan "${keyscanargs[@]}" "${*}" > "${fingerprint}" 2> /dev/null
      [[ -s "${fingerprint}" ]] || return 1
      ssh-keygen -l -f "${fingerprint}"
    ;;
  esac
}
