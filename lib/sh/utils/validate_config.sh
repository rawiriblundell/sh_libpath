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

# Ensure a config file is only made up of shell-importable key=vals
# Otherwise fail out.  Ignores blanks and comments.
validate_config() {
  local conf_file conf_errcount
  conf_file="${1:?No config file defined}"
  [[ -r "${conf_file}" ]] || die "Could not read ${conf_file}"
  conf_errcount="$(grep -Evc '^dark_.*=|^light_.*=|^lights_.*=|^$|^#' "${conf_file}")"
  (( conf_errcount > 0 )) && die "Invalid config found in ${conf_file}"
}

    validate_config() {
      local config_file
      config_file="${1:?No config file defined}"
    
      count=$(
        grep -Ev "^#|^$" "${config_file}" |
          grep -Evc "^[a-zA-Z0-9]+={1}[a-zA-Z0-9]+$"
      )
    
      (( count == 0 )) && return 0
      return 1
    }
    