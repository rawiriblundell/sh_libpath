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

# Strip whitespace from both left and right of a string
# Additionally, compact down multiple spaces inside the string
str_ntrim() {
  LC_CTYPE=C
  ntrim_stdout=$(printf -- '%s' "${*}" | xargs)
  ntrim_rc="${?}"
  unset -v _ntrim_str
  export ntrim_stdout ntrim_rc
}

ntrim() {
  LC_CTYPE=C
  printf -- '%s' "${*}" | xargs
}
