#!/bin/false
# shellcheck shell=bash

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

[ -n "${_SH_LOADED_core_requires+x}" ] && return 0
_SH_LOADED_core_requires=1

# Work through a list of commands and/or files and fail on any unmet requirements.
# Usage: requires curl sed awk /etc/someconf.cfg
requires() {
    local _item
    local _key
    local _val
    local _bashver
    local _target_lib
    local _failures

    for _item in "${@}"; do
        # First, is this a variable check?
        # There has to be a cleaner/safer way to do this
        case "${_item}" in
            (*=*)
            _key="${_item%%=*}" # Everything left of the first '='
            _val="${_item#*=}"  # Everything right of the first '='
            eval [ \$"${_key}" = "${_val}" ] && continue
            ;;
            (BASH*)
            # Shell version check e.g. 'requires BASH32' = we check for bash 3.2 or newer
            # To strictly require a specific version, you could use the keyval test above
            # TODO: Expand the "is greater than" logic, add extra shells
            if [ "${#BASH_VERSION}" -gt 0 ]; then
                # Get first three chars e.g. '4.3'
                _bashver="${BASH_VERSION%${BASH_VERSION#???}}"
                # Concat and remove dot e.g. 'BASH43'
                _bashver="BASH${_bashver/./}"
                # Test on string (e.g. BASH44 = BASH44)
                [ "${_item}" = "${_bashver}" ] && continue
                # Test on integer by stripping "BASH" (e.g. 51 -ge 44)
                [ "${_item/BASH/}" -ge "${_bashver/BASH/}" ] && continue
            fi
            ;;
            (KSH)
            # At present we just check that we have one of the following env vars
            [ "${#KSH_VERSION}" -gt 0 ] && continue
            [ "${#.sh.version}" -gt 0 ] && continue
            ;;
            (ZSH*)
            if [ "${#ZSH_VERSION}" -gt 0 ]; then
                # ZSH_VERSION outputs a semantic number e.g. 5.7.1
                # We use parameter expansion to pull out the dots e.g. ZSH571
                # We do a string, then an int comparison just as with bash
                [ "${_item}" = "ZSH${ZSH_VERSION//./}" ] && continue
                [ "${_item/ZSH/}" -ge "${ZSH_VERSION//./}" ] && continue
            fi
            ;;
            (root)
            [ "${EUID:-$(id -u)}" -eq "0" ] && continue
            ;;
        esac

        # Next, try to determine if it's a command
        command -v "${_item}" >/dev/null 2>&1 && continue

        # Next, see if it's an executable file e.g. a script to call
        [ -x "./${_item}" ] && continue

        # Next, let's see if it's a library in SH_LIBPATH
        for _target_lib in ${SH_LIBPATH//://$_item }/${_item}; do
            [ -r "${_target_lib}" ] && continue
        done

        # Next, let's see if it's a readable file e.g. a cfg file to load
        [ -r "${_item}" ] && continue

        # If we get to this point, add it to our list of failures
        _failures="${_failures} ${_item}"
    done

    _failures="${_failures# }"

    if [ "${#_failures}" -eq "0" ]; then
        return 0
    else
        printf -- '%s\n' "The following requirements were not met:" "${_failures}" >&2
        return 1
    fi
}
