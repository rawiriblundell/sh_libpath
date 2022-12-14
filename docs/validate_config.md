# LIBRARY_NAME

## Description

## Provides

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

# Ensure a config file is only made up of only shell-importable key=vals
# Otherwise fail out.  Ignores blanks and comments.
validate_config() {
  _validate_config_file="${1:?No config file defined}"

  # Filter blank lines and comments
  # Then count lines that aren't in the x=y format
  _validate_config_count=$(
    grep -Ev "^#|^$" "${_validate_config_file}" |
      grep -Evc "^[a-zA-Z0-9]+={1}[a-zA-Z0-9]+$"
  )
  
  if (( _validate_config_count == 0 )); then
    unset -v _validate_config_file _validate_config_count
    return 0
  else
    unset -v _validate_config_file _validate_config_count
    return 1
  fi
}
