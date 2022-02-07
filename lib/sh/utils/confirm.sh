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

# A function to prompt/read an interactive y/n response
# Stops reading after one character, meaning only 'y' or 'Y' will return 0
# _anything_ else will return 1
confirm() {
  read -rn 1 -p "${*:-Continue} [Y/N]? "
  printf -- '%s\n' ""
  case "${REPLY}" in
    ([yY]) return 0 ;;
    (*)    return 1 ;;
  esac
}

# For a version that features a timeout:

# A function to prompt/read an interactive y/n response
# Stops reading after one character, meaning only 'y' or 'Y' will return 0
# Any other character, or an optional timeout (-t|--timeout) will return 1
confirm() {
  local confirm_args
  case "${1}" in
    (-t|--timeout)
      confirm_args=( -t "${2}" )
      set -- "${@:3}"
    ;;
  esac
  
  read "${confirm_args[@]}" -rn 1 -p "${*:-Continue} [Y/N]? "
  printf -- '%s\n' ""
  case "${REPLY}" in
    ([yY]) return 0 ;;
    (*)    return 1 ;;
  esac
}
