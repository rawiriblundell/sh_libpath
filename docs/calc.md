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

# A stupidly simple wrapper for 'bc'
# Requires its inputs to be quoted or put into a variable

# ▓▒░$ calc "4.2 + 2.6"
# 6.8
# ▓▒░$ calc "(4.2 + 2.6) - 3.5"
# 3.3

# Unquoted = the shell tries to interpret it and fails:

# ▓▒░$ calc (4.2 + 2.6) - 3.5
# bash: syntax error near unexpected token `4.2'

# Hide it away in a var though:

# ▓▒░$ calc="(4.2 + 2.6) - 3.5"
# ▓▒░$ calc "${calc}"
# 3.3

# Even an unquoted var, a practice normally to be frowned on:

# ▓▒░$ calc ${calc}
# 3.3

calc() { bc -l <<< "${*:?No input supplied}"; }
