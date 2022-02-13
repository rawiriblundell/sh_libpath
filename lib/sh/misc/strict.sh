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

################################################################################
# Please read CONTRIBUTING and research the Unofficial Strict Mode's flaws

# Enable Unofficial Strict Mode
strict_euopipefail() {
  set -o errexit
  set -o errtrace
  set -o nounset
  set -o pipefail
}

# Set IFS to '\t\n'
strict_nowhitesplitting() {
  IFS='\t\n'
}

# modernish-style 'safe' mode
# https://github.com/modernish/modernish/blob/master/lib/modernish/mdl/safe.mm
safe() {
  IFS=''
  set -o noglob
  set -o nounset
  set -o noclobber
}
