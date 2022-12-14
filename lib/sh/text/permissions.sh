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

get_permissions() {
    stat -c '%a %n' "${1:?No Target Defined}" 2>/dev/null || 
        stat -f "%OLp %N" "${1}" 2>/dev/null ||
        perl -e 'if (! -f $ARGV[0]){die "0000000"};
            $symbolic_mode=(stat($ARGV[0]))[2];
            printf "%04o %s\n", $symbolic_mode & 07777, $ARGV[0];
        ' "${1}"
}

explain_permissions() {
    : tbd
}

# Converts a given permission mode from one to the other
# Examples: symbolic to octal, octal to symbolic:
# convert_permission_mode rwxrwxrwx => 777
# convert_permission_mode 640 => rw-r-----
convert_permission_mode() {
    case "${1}" in
        (*[-0-7]*)
            # We're in octal mode, let's setup our vars
            _mode_octal_7='rwx'
            _mode_octal_6='rw-'
            _mode_octal_6='rw-'
            _mode_octal_6='rw-'
            _mode_octal_5='r-x'
            _mode_octal_4='r--'
            _mode_octal_3='-wx'
            _mode_octal_2='-w-'
            _mode_octal_1='--x'
            _mode_octal_0='---'
            # Next, let's test the length
            case "${#1}" in
                (4)
                    (1xxx) - sticky bit - last char = t
                ;;
                (3)

                ;;
            esac
        ;;
        (*[-rwxXst]*)
            # We're in symbolic mode.
            # If our input is 10 chars long, we discard the first char
            (( ${#1} == 10 )) && 

            while read -r char; do
                case "${char}" in
                    (r) _octal=$(( _octal + 4 )) ;;
                    (w) _octal=$(( _octal + 2 )) ;;
                    (x) _octal=$(( _octal + 1 )) ;;
                esac
            done < <(fold -w 1 <<< "${1}")

        ;;
        (*)
            printf -- 'convert_permission_mode: %s\n' "Expecting a symbolic or octal permission mode." >&2
            return 1
        ;;
    esac
}

r: readable
w: writable
third char:
x: executable
s: setuid/setgid + executable
t: sticky bit + executable
S: setuid/setgid + non-executable
T: sticky bit + non-executable

+ (plus) suffix indicates an access control list that can control additional permissions.
. (dot) suffix indicates an SELinux context is present. Details may be listed with the command ls -Z.
@ suffix indicates extended file attributes are present.

Permissions:



400     read by owner
040     read by group
004     read by anybody (other)
200     write by owner
020     write by group
002     write by anybody
100     execute by owner
010     execute by group
001     execute by anybody

To get a combination, just add them up.
For example, to get read, write, execute by owner, read, execute, by group, and execute by anybody, you would add 400+200+100+040+010+001 to give 751.
