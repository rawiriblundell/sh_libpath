# FUNCTION_NAME

## Description

## Synopsis

## Options

## Examples

## Output
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

# Convert comma separated list to long format e.g. id user | tr "," "\n"
# See also n2c() and n2s() for the opposite behaviour
c2n() {
  while read -r; do 
    printf -- '%s\n' "${REPLY}" | tr "," "\\n"
  done < "${1:-/dev/stdin}"
}

# Convert multiple lines to comma separated format
# See also c2n() for the opposite behaviour
n2c() { paste -sd ',' "${1:--}"; }

# Convert multiple lines to space separated format
n2s() { paste -sd ' ' "${1:--}"; }

# noext=${basename%%.*}
