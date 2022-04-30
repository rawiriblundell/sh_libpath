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
# Provenance: https://raw.githubusercontent.com/rawiriblundell/dotfiles/master/.bashrc
# SPDX-License-Identifier: Apache-2.0

# Provide a very simple 'tac' step-in function
if ! command -v tac >/dev/null 2>&1; then
  tac() {
    if command -v perl >/dev/null 2>&1; then
      perl -e 'print reverse<>' < "${1:-/dev/stdin}"
    elif command -v awk >/dev/null 2>&1; then
      awk '{line[NR]=$0} END {for (i=NR; i>=1; i--) print line[i]}' < "${1:-/dev/stdin}"
    elif command -v sed >/dev/null 2>&1; then
      sed -e '1!G;h;$!d' < "${1:-/dev/stdin}"
    fi
  }
fi
