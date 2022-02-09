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

# Try to emit a certificate expiry date from openssl
get_certexpiry() {
  local host="${1}"
  local hostport="${2:-443}"
  echo | openssl s_client -showcerts -host "${host}" -port "${hostport}" 2>&1 \
    | openssl x509 -inform pem -noout -enddate \
    | cut -d "=" -f 2
}
