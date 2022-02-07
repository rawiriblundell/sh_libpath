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

# Iterate through a file or stream line-by-line with a delay between each line
scroll() {
  # Check that stdin isn't empty
  if [[ -t 0 ]]; then
    printf -- '%s\n' "Usage:  pipe | to | scroll [n]" ""
    printf -- '\t%s\n'  "Increment line by line through the output of other commands" "" \
      "Delay between each increment can be defined.  Default is 1 second."
    return 0
  fi

  # Default the sleep time to 1 second
  sleepTime="${1:-1}"

  # Now we output line by line with a sleep in the middle
  while read -r; do
    printf -- '%s\n' "${REPLY}"
    sleep "${sleepTime}" 2>/dev/null || sleep 1
  done 
}
