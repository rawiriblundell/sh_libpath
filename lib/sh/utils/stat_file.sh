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
            stat -c %X "${1}" 2>/dev/null || 
                stat -f %a "${1}" 2>/dev/null ||
                perl -e 'if (! -f $ARGV[0]){die "0000000"};$atime=(stat($ARGV[0]))[8];print $atime."\n";' "${1}"
        ;;
        (ctime)
            stat -c %Z "${1}" 2>/dev/null || 
                stat -f %c "${1}" 2>/dev/null ||
                perl -e 'if (! -f $ARGV[0]){die "0000000"};$ctime=(stat($ARGV[0]))[10];print $ctime."\n";' "${1}"        
        ;;
        (mtime)
            stat -c %Y "${1}" 2>/dev/null || 
                stat -f %m "${1}" 2>/dev/null ||
                perl -e 'if (! -f $ARGV[0]){die "0000000"};$mtime=(stat($ARGV[0]))[9];print $mtime."\n";' "${1}"
        ;;
    esac
}
