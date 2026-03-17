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
# Provenance: https://github.com/rawiriblundell/sh_libpath
# SPDX-License-Identifier: Apache-2.0

[ -n "${_SHELLAC_LOADED_path_readlink_f+x}" ] && return 0
_SHELLAC_LOADED_path_readlink_f=1

include path/realpaths

# @description Compatibility stub for 'readlink -f'. Delegates to
#   realpath.portable_follow, which resolves symlink chains portably without
#   requiring readlink -f support.
#
# @arg $1 string Path to resolve
#
# @stdout Absolute canonical path
# @exitcode 0 Success
# @exitcode 1 Path not found or resolution failed
readlink_f() {
  realpath.portable_follow "${1:?No path specified}"
}
