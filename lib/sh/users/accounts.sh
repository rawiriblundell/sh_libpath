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

[ -n "${_SHELLAC_LOADED_users_accounts+x}" ] && return 0
_SHELLAC_LOADED_users_accounts=1

# Lowest UID considered a regular user account; falls back to 500 for older distros
_uid_min=$(awk '/^UID_MIN/{print $2}' /etc/login.defs)
_uid_min="${_uid_min:-500}"

# @description Print the usernames of all regular user accounts (UIDs >= UID_MIN).
#
# @stdout One username per line
# @exitcode 0 Always
user_accounts() {
  awk -F: -v min="${_uid_min}" '$3 >= min {print $1}' /etc/passwd
}

# @description Print the UIDs of all regular user accounts (UIDs >= UID_MIN).
#
# @stdout One UID per line
# @exitcode 0 Always
user_uids() {
  awk -F: -v min="${_uid_min}" '$3 >= min {print $3}' /etc/passwd
}

# @description Print the UID of a named user.
#
# @arg $1 string Username to look up
#
# @stdout UID of the user
# @exitcode 0 User found
# @exitcode 1 No argument given or user not found
user_uid() {
  local _username _uid
  _username="${1:?No username given}"
  _uid="$(awk -F: -v u="${_username}" '$1 == u {print $3}' /etc/passwd)"
  if [[ -z "${_uid}" ]]; then
    printf -- 'user_uid: user %s not found\n' "'${_username}'" >&2
    return 1
  fi
  printf -- '%s\n' "${_uid}"
}

# @description Print the primary GID of a named user.
#
# @arg $1 string Username to look up
#
# @stdout Primary GID of the user
# @exitcode 0 User found
# @exitcode 1 No argument given or user not found
user_gid() {
  local _username _gid
  _username="${1:?No username given}"
  _gid="$(awk -F: -v u="${_username}" '$1 == u {print $4}' /etc/passwd)"
  if [[ -z "${_gid}" ]]; then
    printf -- 'user_gid: user %s not found\n' "'${_username}'" >&2
    return 1
  fi
  printf -- '%s\n' "${_gid}"
}

# @description Print the password state for a user from /etc/shadow.
#   Returns 'P' (password set), 'LK' (locked), or 'NP' (no password).
#
# @arg $1 string Username to check
#
# @stdout 'P', 'LK', or 'NP'
# @exitcode 0 Always
user_passwd_state() {
  case $(awk -F: -v user="${1:?No username given}" '$1 == user {print $2}' /etc/shadow) in
    (\$[1256]*)    printf -- '%s\n' "P"  ;;
    (\!|\*|\!\!|\!\*|\*LK\*) printf -- '%s\n' "LK" ;;
    (NP|"")        printf -- '%s\n' "NP" ;;
  esac
}

# @description Print the usernames of all system accounts (UIDs < UID_MIN).
#
# @stdout One username per line
# @exitcode 0 Always
sysuser_accounts() {
  awk -F: -v min="${_uid_min}" '$3 < min {print $1}' /etc/passwd
}

# @description Print the UIDs of all system accounts (UIDs < UID_MIN).
#
# @stdout One UID per line
# @exitcode 0 Always
sysuser_uids() {
  awk -F: -v min="${_uid_min}" '$3 < min {print $3}' /etc/passwd
}

# @description Print the UID of a named system account.
#
# @arg $1 string Username to look up
#
# @stdout UID of the account
# @exitcode 0 Account found
# @exitcode 1 No argument given or account not found
sysuser_uid() {
  local _username _uid
  _username="${1:?No username given}"
  _uid="$(awk -F: -v u="${_username}" '$3 < '"${_uid_min}"' && $1 == u {print $3}' /etc/passwd)"
  if [[ -z "${_uid}" ]]; then
    printf -- 'sysuser_uid: system account %s not found\n' "'${_username}'" >&2
    return 1
  fi
  printf -- '%s\n' "${_uid}"
}

# @description Print the primary GID of a named system account.
#   Alias of user_gid; GID lookup is identical regardless of account type.
#
# @arg $1 string Username to look up
sysuser_gid() { user_gid "$@"; }

# @description Print the password state for a system account.
#   Alias of user_passwd_state; lookup is identical regardless of account type.
#
# @arg $1 string Username to check
sysuser_passwd_state() { user_passwd_state "$@"; }
