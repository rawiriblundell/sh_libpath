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

# Description: Test whether the number of given parameters is correct
# Parameter 1: Desired number of parameters
# Parameter 2: Actual number of parameters (usually "${#}")
opt_count() {
    local desired_count actual_count
    # Prevent irony
    (( "${#}" != 2 )) && die "Incorrect number of parameters to check"
    # Validate that our vars are actually integers
    is_integer "${desired_count}" || die "${desired_count} is not an integer"
    is_integer "${actual_count}" || die "${actual_count} is not an integer"
    # Finally, run the actual testing
    (( actual_count < desired_count )) && die "Not enough parameters supplied"
    (( actual_count > desired_count )) && die "Too many parameters supplied."
}
