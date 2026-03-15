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

[ -n "${_SHELLAC_LOADED_users_get_passwd_state+x}" ] && return 0
_SHELLAC_LOADED_users_get_passwd_state=1

# @description Print the password state for a user from /etc/shadow.
#   Returns 'P' (password set), 'LK' (locked), or 'NP' (no password).
#
# @arg $1 string Username to check
#
# @stdout 'P', 'LK', or 'NP'
# @exitcode 0 Always
get_passwd_state() {
  case $(awk -F ':' -v user="${1}" '{if ($1 == user) print $2}' /etc/shadow) in
    (\$[1256]*)
      printf '%s\n' "P" # Password found
    ;;
    (\!|\*|\!\!|\!\*|\*LK\*)
      printf '%s\n' "LK" # Password or account locked
    ;;
    (NP|"")
      printf '%s\n' "NP" # No password set
    ;;
  esac
}
