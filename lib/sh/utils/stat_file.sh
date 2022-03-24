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

stat_file() {
  case "${1}" in
    (atime)
      stat -c %X "${2:?No Target Defined}" 2>/dev/null || 
        stat -f %a "${2}" 2>/dev/null ||
        perl -e 'if (! -f $ARGV[0]){die "0000000"};$atime=(stat($ARGV[0]))[8];print $atime."\n";' "${2}"
    ;;
    (ctime)
      stat -c %Z "${2:?No Target Defined}" 2>/dev/null || 
        stat -f %c "${2}" 2>/dev/null ||
        perl -e 'if (! -f $ARGV[0]){die "0000000"};$ctime=(stat($ARGV[0]))[10];print $ctime."\n";' "${2}"
    ;;
    (mtime)
      stat -c %Y "${2:?No Target Defined}" 2>/dev/null || 
        stat -f %m "${2}" 2>/dev/null ||
        perl -e 'if (! -f $ARGV[0]){die "0000000"};$mtime=(stat($ARGV[0]))[9];print $mtime."\n";' "${2}"
    ;;
    (size)
      stat -c %s "${2:?No Target Defined}" 2>/dev/null ||
        stat -f %z "${2}" 2>/dev/null ||
        perl -e 'if (! -f $ARGV[0]){die "0000000"};$size=(stat($ARGV[0]))[7];print $size."\n";' "${2}"
    ;;
    (owner)
      # shellcheck disable=SC2012
      stat -c %U "${2:?No Target Defined}" 2>/dev/null ||
        stat -f %Su "${2}" 2>/dev/null ||
        ls -ld "${2}" | awk 'NR==1 {print $3}'
    ;;
  esac
}

# Function to get the owner of a file
whoowns() {
  stat_file owner "${1}"
}

# Test a file's age in seconds
get_file_age() {
  if [[ -f "${1:?No file specified}" ]]; then
    printf -- '%s\n' "$(( $(date +%s) - $(stat_file mtime "${1}") ))"
  else
    printf -- '%s\n' "No such file or unreadable: '${1}'"
    return 1
  fi
}
