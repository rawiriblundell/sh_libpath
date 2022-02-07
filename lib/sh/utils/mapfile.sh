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

# A portability function for older systems that don't have the mapfile builtin
if ! command -v mapfile >/dev/null 2>&1; then
  mapfile() {
    local _arrName i IFS
    unset MAPFILE

    set -f        # Turn off globbing
    set +H        # Prevent parsing of '!' via history substitution

    # We use the behaviour of '-t' by default, so if it's given, skip it
    while getopts ":t" flags; do
      case "${flags}" in
        (t) :;; # Only here for compatibility
        (*) :;; # Dummy action
      esac
    done
    shift "$(( OPTIND - 1 ))"

    # If an argument is left, it's our array name, otherwise this
    # function will export an array named MAPFILE (as the real 'mapfile' does)
    _arrName="${1}"

    # Read all of the input
    i=0
    while IFS=$'\n' read -r; do
      MAPFILE[i]="${REPLY}"
      ((i++))
    done
    # Sometimes there's a trailing line in a while read loop, if so catch it
    [[ "${REPLY}" ]] && MAPFILE[i]="${REPLY}"

    export MAPFILE

    # Finally, rename the array if required
    # I would love to know a better way to handle this
    if [[ -n "${_arrName}" ]]; then
      # shellcheck disable=SC2034
        eval "${_arrName}=( \"\${MAPFILE[@]}\" )"
    fi

    # Set f and H back to normal
    set +f
    set -H
  }
fi
