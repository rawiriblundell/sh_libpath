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

[ -n "${_SH_LOADED_core_logging+x}" ] && return 0
_SH_LOADED_core_logging=1

log_info() {
 :
}

log_error() {
 :
}

log_warn() {
 :
}

# A function to log messages to the system log
# http://hacking.elboulangero.com/2015/12/06/bash-logging.html may be useful
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
