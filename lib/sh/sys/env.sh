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

[ -n "${_SHELLAC_LOADED_sys_env+x}" ] && return 0
_SHELLAC_LOADED_sys_env=1

# @description Remove the directory containing the current script from PATH
#   to prevent infinite recursion when a script shadows a system command.
#
# @exitcode 0 Always
prevent_path_recursion() {
    local curdir
    local _element
    local _new_path
    local _old_ifs
    curdir=$(realpath "$(dirname "${BASH_SOURCE[0]}")")
    _new_path=
    _old_ifs="${IFS}"
    IFS=:
    for _element in ${PATH}; do
        [ "${_element}" = "${curdir}" ] && continue
        _new_path="${_new_path:+${_new_path}:}${_element}"
    done
    IFS="${_old_ifs}"
    export PATH="${_new_path}"
}
