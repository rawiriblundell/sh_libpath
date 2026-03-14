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

[ -n "${_SH_LOADED_text_csvwrap+x}" ] && return 0
_SH_LOADED_text_csvwrap=1

# Wrap long comma separated lists by element count (default: 8 elements)
csvwrap() {
  local split_count
  export split_count="${1:-8}"
  perl -pe 's{,}{++$n % $ENV{split_count} ? $& : ",\\\n"}ge'
}
