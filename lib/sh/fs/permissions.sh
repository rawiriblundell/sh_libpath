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
# Provenance: https://github.com/rawiriblundell/shellac
# SPDX-License-Identifier: Apache-2.0

[ -n "${_SHELLAC_LOADED_fs_permissions+x}" ] && return 0
_SHELLAC_LOADED_fs_permissions=1

# @description Get the octal permission mode and path for a file or directory.
#   Tries GNU stat, then BSD stat, then falls back to perl.
#
# @arg $1 string Path to the target file or directory
#
# @example
#   fs_permissions /etc/passwd   # => 644 /etc/passwd
#
# @stdout Octal mode and path separated by a space
# @exitcode 0 Success
# @exitcode 1 File not found (from perl fallback)
fs_permissions() {
  local _target
  _target="${1:?No target given}"
  stat -c '%a %n' "${_target}" 2>/dev/null ||
    stat -f '%Op %N' "${_target}" 2>/dev/null ||
    perl -e '
      if (! -e $ARGV[0]) { die "File not found\n" }
      my $mode = (stat($ARGV[0]))[2];
      printf "%04o %s\n", $mode & 07777, $ARGV[0];
    ' "${_target}"
}
