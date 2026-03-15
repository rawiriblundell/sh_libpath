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

[ -n "${_SHELLAC_LOADED_users_get_gid+x}" ] && return 0
_SHELLAC_LOADED_users_get_gid=1

# @description Print the primary GID of a user by looking up the global variable
#   $username in /etc/passwd.
#
# @stdout Primary GID of the user
# @exitcode 0 User found
# @exitcode 1 User not found (calls func.Erruser)
get_gid() {
  if awk -F : '{print $0}' /etc/passwd | grep ^"${username}" >/dev/null 2>&1; then
    gid=$(grep ^"${username}" /etc/passwd | awk -F : '{print $4}' )
    printf "%s\n" "${gid}"
  else
    func.Erruser
  fi
}
