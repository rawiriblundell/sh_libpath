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

[ -n "${_SHELLAC_LOADED_core_logging+x}" ] && return 0
_SHELLAC_LOADED_core_logging=1

# @description Log an informational message. Stub implementation.
#
# @exitcode 0 Always
log_info() {
 :
}

# @description Log an error message. Stub implementation.
#
# @exitcode 0 Always
log_error() {
 :
}

# @description Log a warning message. Stub implementation.
#
# @exitcode 0 Always
log_warn() {
 :
}

# @description Log a message to the system log using systemd-cat, logger, or a fallback
#   file. Accepts an optional -t tag and -s flag to also print to stdout.
#
# @arg $1 string Optional: -s to echo to stdout
# @arg $1 string Optional: -t <tag> to set a syslog identifier
# @arg $@ string Message text
#
# @stdout Message line when -s is given
# @exitcode 0 Message logged successfully
# @exitcode 1 Invalid option
logmsg() {
    local _opt
    local _log_ident
    local _print_fmt
    local _std_out
    local _log_file
    local OPTIND

    while getopts ":t:s" _opt; do
        case "${_opt}" in
            (s)     _std_out=1 ;;
            (t)     _log_ident="${OPTARG}" ;;
            (\?|:|*)
                printf -- '%s\n' "Usage: logmsg [-s(tdout) -t tag] message" >&2
                return 1
            ;;
        esac
    done
    shift "$(( OPTIND - 1 ))"

    case "${_log_ident:-}" in
        ('')  _print_fmt="$(date '+%b %d %T') ${HOSTNAME%%.*}:" ;;
        (*)   _print_fmt="$(date '+%b %d %T') ${HOSTNAME%%.*} ${_log_ident}:" ;;
    esac

    if command -v systemd-cat >/dev/null 2>&1; then
        (( _std_out )) && printf -- '%s\n' "${_print_fmt} ${*}"
        case "${_log_ident:-}" in
            ('') systemd-cat <<< "${*}" ;;
            (*)  systemd-cat -t "${_log_ident}" <<< "${*}" ;;
        esac
    elif command -v logger >/dev/null 2>&1; then
        (( _std_out )) && printf -- '%s\n' "${_print_fmt} ${*}"
        case "${_log_ident:-}" in
            ('') logger "${*}" ;;
            (*)  logger -t "${_log_ident}" "${*}" ;;
        esac
    else
        [[ -w /var/log/messages ]] && _log_file=/var/log/messages
        [[ -z "${_log_file}" && -w /var/log/syslog ]] && _log_file=/var/log/syslog
        : "${_log_file:=/var/log/logmsg}"
        if (( _std_out )); then
            printf -- '%s\n' "${_print_fmt} ${*}" | tee -a "${_log_file}"
        else
            printf -- '%s\n' "${_print_fmt} ${*}" >> "${_log_file}"
        fi
    fi
}
