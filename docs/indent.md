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

# Function to indent text by n spaces (default: 2 spaces)
str_indent() {
  _ident_width="${1:-2}"
  _ident_width=$(eval "printf -- '%.0s ' {1..${_ident_width}}")
  sed "s/^/${_ident_width}/" "${2:-/dev/stdin}"
}

indent() {
  _ident_width="${1:-2}"
  _ident_width=$(eval "printf -- '%.0s ' {1..${_ident_width}}")
  sed "s/^/${_ident_width}/" "${2:-/dev/stdin}"
}