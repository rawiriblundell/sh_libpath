# FUNCTION_NAME

## Description

## Synopsis

## Options

## Examples

## Output
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
  local optFlags logIdent printFmt stdOutArg OPTIND
  unset optFlags logIdent printFmt stdOutArg OPTIND
  while getopts ":t:s" optFlags; do
    case "${optFlags}" in
      (s)   stdOutArg='-s' ;;
      (t)   logIdent="-t ${OPTARG}" ;;
      (\?|:|*)  
        printf -- '%s\n' "Usage: logmsg [-s(tdout) -t tag] message" >&2
        return 1
      ;;
    esac
  done
  shift "$(( OPTIND - 1 ))"
  case "${logIdent}" in
    ('')  printFmt="$(date '+%b %d %T') ${HOSTNAME%%.*}:" ;;
    (*)   printFmt="$(date '+%b %d %T') ${HOSTNAME%%.*} ${logIdent/-t /}:" ;;
  esac
  if command -v systemd-cat >/dev/null 2>&1; then
    [[ "${stdOutArg}" = "-s" ]] && printf -- '%s\n' "${printFmt} ${*}"
    case "${logIdent}" in
      ('') systemd-cat <<< "${*}" ;;
      (*)  systemd-cat "${logIdent}" <<< "${*}" ;;
    esac
  elif command -v logger >/dev/null 2>&1; then
    [[ "${stdOutArg}" = "-s" ]] && printf -- '%s\n' "${printFmt} ${*}"
    logger "${logIdent}" "${*}"
  else
    [[ -w /var/log/messages ]] && logFile=/var/log/messages
    [[ -z "${logFile}" && -w /var/log/syslog ]] && logFile=/var/log/syslog
    [[ -z "${logFile}" ]] && logFile=/var/log/logmsg
    if [[ "${stdOutArg}" = "-s" ]]; then
      printf -- '%s\n' "${printFmt} ${*}" | tee -a "${logFile}" 2>&1
    else
      printf -- '%s\n' "${printFmt} ${*}" >> "${logFile}" 2>&1
    fi
  fi  
}
