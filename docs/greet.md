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

get_greeting() {
  local greet_moment
  if (( "${DayGreet:-$(date +%H)}" >= 18 )); then
    greet_moment="evening"
  elif (( "${DayGreet:-$(date +%H)}" >= 12 )); then
    greet_moment="afternoon"
  else
    greet_moment="morning"
  fi
  printf -- 'Good %s!\n' "${greet_moment}"
}
