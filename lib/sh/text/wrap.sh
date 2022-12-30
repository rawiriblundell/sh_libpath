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

# Written for https://github.com/bash-my-aws/bash-my-aws/issues/216#issuecomment-1198807593
# Convert long command to multi-line with vertically aligned continuation separators e.g.
# aws s3api copy-object --copy-source "${example/release-$BUILD_NUMBER/index.html" --bucket "${DEPLOYMENT_BUCKET}" --key "search/" --content-type text/html --cache-control public,max-age=60,s-maxage=60 --metadata-directive REPLACE
#
# Becomes:
#
# aws s3api copy-object                                        \
#   --copy-source "${example/release-$BUILD_NUMBER/index.html" \
#   --bucket "${DEPLOYMENT_BUCKET}"                            \
#   --key "search/"                                            \
#   --content-type text/html                                   \
#   --cache-control public,max-age=60,s-maxage=60              \
#   --metadata-directive REPLACE
wrap_code_block() {
  # Search for a leading space and a dash, to capture ` -a` and `--arg` style options
  # Replace with a newline and two space indentation, slurp each line into an array
  mapfile -t < <(sed 's/ -/\n  -/g' <<< "${*}")

  # Get the length of the longest line
  right_bound=$(for element in "${MAPFILE[@]}"; do printf -- '%d\n' "${#element}"; done | sort -n | tail -n 1)

  # Pad it
  right_bound=$(( right_bound + 2 ))

  # Generate our output
  for (( i=0; i<"${#MAPFILE[@]}"; i++ )); do
    if (( i == ("${#MAPFILE[@]}" - 1) )); then
      printf -- '%s\n' "${MAPFILE[i]}"
    else
      printf -- '%s%*s%s\n' "${MAPFILE[i]}" $(( right_bound - "${#MAPFILE[i]}" )) '\'
    fi
  done
}

