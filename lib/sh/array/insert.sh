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

#TODO
# Insert into element position and reindex
array_insert() {
    local _array_insert_index _array_insert_name _array_insert_value
    _array_insert_index="${1}"
    _array_insert_name="${2}"
    shift 2
    _array_insert_value="${*}"
    _array_insert_name=( "${_array_insert_name[@]:0:_array_insert_index}" "${_array_insert_value}" "${_array_insert_name[@]:$_array_insert_index}" )
}
 #output: new
