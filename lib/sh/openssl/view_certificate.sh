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

if ! command -v openssl >/dev/null 2>&1; then
    printf -- 'view_certificate: %s\n' "This library requires 'openssl', which was not found in PATH" >&2
    exit 1
fi

view_certificate () {
    _view_certificate_in="${1}"

    if (( "${#_view_certificate_in}" == 0 )); then
        printf -- 'view_certificate: %s\n' "No input file provided" >&2
        return 1
    fi

    openssl x509 -text -noout -in "${_view_certificate_in}"

    unset -v _view_certificate_in
}

view_certificate_modulus() {
    _view_certificate_modulus_in="${1}"

    if (( "${#_view_certificate_modulus_in}" == 0 )); then
        printf -- 'view_certificate_modulus: %s\n' "No input file provided" >&2
        return 1
    fi

    openssl x509 -noout -modulus -in "${_view_certificate_modulus_in}" | shasum -a 256

    unset -v _view_certificate_modulus_in
}

# The functions below are modified versions from 
# https://github.com/rawiriblundell/scripts/blob/master/ssl_audit
# (c) 2019 Rawiri Blundell, Datacom Compute.  MIT License.

# Try to emit a certificate expiry date from openssl
view_certificate_expiry() {
    # First we test if it's a local file
    if [ -r "${1}" ]; then
        openssl x509 -in "${1}" -enddate -noout |
            sed -e "s/^notAfter=//" -e "s/GMT//" |
            awk '{printf("%s %02d %d %s\n", $1,$2,$4,$3)}'
    # Otherwise, we assume a connection to a remote host
    else
        _view_certificate_host="${1}"
        _view_certificate_port="${2:-443}"
        echo | openssl s_client -showcerts -host "${_view_certificate_host}" -port "${_view_certificate_port}" 2>&1 \
            | openssl x509 -inform pem -noout -enddate \
            | cut -d "=" -f 2
        unset -v _view_certificate_host _view_certificate_port
    fi
}

# I know that the functions below result in multiple calls to openssl
# This is computationally inefficient, but it's just how this script grew
read_cert() {
  openssl x509 -in "${1:?No Cert Defined}" -text -noout
}

read_cert_active() {
  openssl x509 -in "${1:?No Cert Defined}" -startdate -noout |
    sed -e "s/^notBefore=//" -e "s/GMT//" |
    awk '{printf("%s %02d %d %s\n", $1,$2,$4,$3)}'
}

read_cert_algorithm() {
  local cert_algorithm
  cert_algorithm=$(read_cert "${1:?No Cert Defined}" | 
    awk -F ': ' '/Signature Algorithm/{print $2; exit}')

  # Sometimes openssl isn't new enough to recognise a human friendly name
  # and returns an oid instead.  We map these cases here, 
  # reference: http://oid-info.com
  case "${cert_algorithm}" in
    ('1.2.840.10045.4.3.1') cert_algorithm="ecdsa-with-SHA224" ;;
    ('1.2.840.10045.4.3.2') cert_algorithm="ecdsa-with-SHA256" ;;
    ('1.2.840.10045.4.3.3') cert_algorithm="ecdsa-with-SHA384" ;;
    ('1.2.840.10045.4.3.4') cert_algorithm="ecdsa-with-SHA512" ;;
    (*) : ;;
  esac

  printf -- '%s\n' "${cert_algorithm}"
}

read_cert_cn() {
  openssl x509 -in "${1:?No Cert Defined}" -subject -noout -nameopt multiline |
    awk -F '= ' '/commonName/{print $2}' |
    paste -sd "," -
}

read_cert_email() {
  openssl x509 -in "${1:?No Cert Defined}" -subject -noout -nameopt multiline |
    awk -F '= ' '/emailAddress/{print $2}'
}

read_cert_expiry() {
  openssl x509 -in "${1:?No Cert Defined}" -enddate -noout |
    sed -e "s/^notAfter=//" -e "s/GMT//" |
    awk '{printf("%s %02d %d %s\n", $1,$2,$4,$3)}'
}

read_cert_issuer() {
  openssl x509 -in "${1:?No Cert Defined}" -issuer -noout |
    sed -e "s/^issuer=//"
}

read_cert_ou_name() {
  openssl x509 -in "${1:?No Cert Defined}" -subject -noout -nameopt multiline |
    awk -F '= ' '/organizationalUnitName/{print $2}' |
    paste -s -
}

# shellcheck disable=SC2119
read_cert_sans() {
  openssl x509 -in "${1:?No Cert Defined}" -text -noout |
    grep "DNS:" |
    trim |
    paste -sd ' ' - |
    grep .
}

read_cert_serial() {
  openssl x509 -in "${1:?No Cert Defined}" -serial -noout |
    sed -e "s/^serial=//"
}

read_cert_state() {
  case "$(openssl x509 -in "${1:?No Cert Defined}" -checkend "${2:-0}")" in
    (*'not expire'*)  printf -- '%s\n' "OK" ;;
    (*'will expire')  printf -- '%s\n' "EXPIRED" ;;
  esac
}

read_cert_fingerprint() {
  openssl x509 -in "${1:?No Cert Defined}" -fingerprint -noout
}
