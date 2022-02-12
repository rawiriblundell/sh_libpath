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

# TODO: Create a function that splits chained cert files
# I likely have the code for this already - must check my archives...

# If it's in a binary format, first convert to PEM
# Then count the certs indicated by 'BEGIN CERTIFICATE'
# If it's more than one, make a temporary directory and extract the certs into it
# ... OR... build an array and put each cert into an element?

# https://github.com/rawiriblundell/scripts/blob/master/ssl_audit
# (c) 2019 Rawiri Blundell, Datacom Compute.  MIT License.

#   cert_count=$(grep -E '\-BEGIN CERTIFICATE\-' "${cert_path}" | wc -l)

# if (( cert_count > 1 )); then

# extract_cert_bundle() {
#   awk '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/{ if(/BEGIN/){a++}; out="cert"a".pem"; print >out}' "${1:?No Cert Defined}"
# }
