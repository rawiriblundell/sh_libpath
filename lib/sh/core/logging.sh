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
  local opt_flags log_ident print_fmt std_out_arg OPTIND
  unset opt_flags log_ident print_fmt std_out_arg OPTIND
  while getopts ":t:s" opt_flags; do
    case "${opt_flags}" in
      (s)   std_out_arg='-s' ;;
      (t)   log_ident="-t ${OPTARG}" ;;
      (\?|:|*)
        printf -- '%s\n' "Usage: logmsg [-s(tdout) -t tag] message" >&2
        return 1
      ;;
    esac
  done
  shift "$(( OPTIND - 1 ))"
  case "${log_ident}" in
    ('')  print_fmt="$(date '+%b %d %T') ${HOSTNAME%%.*}:" ;;
    (*)   print_fmt="$(date '+%b %d %T') ${HOSTNAME%%.*} ${log_ident/-t /}:" ;;
  esac
  if command -v systemd-cat >/dev/null 2>&1; then
    [[ "${std_out_arg}" = "-s" ]] && printf -- '%s\n' "${print_fmt} ${*}"
    case "${log_ident}" in
      ('') systemd-cat <<< "${*}" ;;
      (*)  systemd-cat "${log_ident}" <<< "${*}" ;;
    esac
  elif command -v logger >/dev/null 2>&1; then
    [[ "${std_out_arg}" = "-s" ]] && printf -- '%s\n' "${print_fmt} ${*}"
    logger "${log_ident}" "${*}"
  else
    [[ -w /var/log/messages ]] && logFile=/var/log/messages
    [[ -z "${logFile}" && -w /var/log/syslog ]] && logFile=/var/log/syslog
    [[ -z "${logFile}" ]] && logFile=/var/log/logmsg
    if [[ "${std_out_arg}" = "-s" ]]; then
      printf -- '%s\n' "${print_fmt} ${*}" | tee -a "${logFile}" 2>&1
    else
      printf -- '%s\n' "${print_fmt} ${*}" >> "${logFile}" 2>&1
    fi
  fi
}
