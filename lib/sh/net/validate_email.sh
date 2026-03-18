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
# Adapted from labbots/bash-utility (MIT) https://github.com/labbots/bash-utility

[ -n "${_SHELLAC_LOADED_net_validate_email+x}" ] && return 0
_SHELLAC_LOADED_net_validate_email=1

# @description Validate whether a string is a plausible email address.
#   Checks structural format only — does not perform DNS or deliverability checks.
#
# @arg $1 string String to test
#
# @example
#   net_validate_email "user@example.com"    # => exit 0
#   net_validate_email "notanemail"           # => exit 1
#
# @exitcode 0 Valid email format
# @exitcode 1 Invalid format
# @exitcode 2 Missing argument
net_validate_email() {
  local email_re
  [[ $# -eq 0 ]] && { printf -- '%s\n' "net_validate_email: missing argument" >&2; return 2; }
  email_re="^([A-Za-z]+[A-Za-z0-9]*\+?((\.|\-|\_)?[A-Za-z]+[A-Za-z0-9]*)*)@(([A-Za-z0-9]+)+((\.|\-|\_)?([A-Za-z0-9]+)+)*)+\.([A-Za-z]{2,})+$"
  [[ "${1}" =~ ${email_re} ]]
}
