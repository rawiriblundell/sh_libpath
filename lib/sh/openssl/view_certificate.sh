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

# This function absorbs code from 
# https://github.com/rawiriblundell/scripts/blob/master/ssl_audit
# (c) 2019 Rawiri Blundell, Datacom Compute.  MIT License.
view_certificate () {
    local _view_certificate_algorithm _view_certificate_host _view_certificate_port _view_certificate_in
    _view_certificate_in="${2}"

    if (( "${#_view_certificate_in}" == 0 )); then
        printf -- 'view_certificate: %s\n' "No input file provided" >&2
        return 1
    fi

    case "${1}" in
        ([Aa]lgorithm)
            _view_certificate_algorithm=$(
                openssl x509 -text -noout -in "${_view_certificate_in}" | 
                    awk -F ': ' '/Signature Algorithm/{print $2; exit}'
            )

            # Sometimes openssl isn't new enough to recognise a human friendly name
            # and returns an oid instead.  We map these cases here, reference: http://oid-info.com
            case "${_view_certificate_algorithm}" in
                ('1.2.840.10045.4.3.1') _view_certificate_algorithm="ecdsa-with-SHA224" ;;
                ('1.2.840.10045.4.3.2') _view_certificate_algorithm="ecdsa-with-SHA256" ;;
                ('1.2.840.10045.4.3.3') _view_certificate_algorithm="ecdsa-with-SHA384" ;;
                ('1.2.840.10045.4.3.4') _view_certificate_algorithm="ecdsa-with-SHA512" ;;
                (*) : ;;
            esac

            printf -- '%s\n' "${_view_certificate_algorithm:-UNKNOWN}"
        ;;
        (CN|cn|[Cc]ommon[Nn]ame)
            openssl x509 -in "${_view_certificate_in}" -subject -noout -nameopt multiline |
                awk -F '= ' '/commonName/{print $2}' |
                paste -sd "," -
        ;;
        ([Ee]mail)
            openssl x509 -in "${_view_certificate_in}" -subject -noout -nameopt multiline |
                awk -F '= ' '/emailAddress/{print $2}'
        ;;
        ([Ee]xpiry|[Ee]nd)
            # First we test if it's a local file
            if [ -r "${_view_certificate_in}" ]; then
                openssl x509 -in "${_view_certificate_in}" -enddate -noout |
                    sed -e "s/^notAfter=//" -e "s/GMT//" |
                    awk '{printf("%s %02d %d %s\n", $1,$2,$4,$3)}'
            # Otherwise, we assume a connection to a remote host
            else
                _view_certificate_host="${1}"
                _view_certificate_port="${2:-443}"
                echo | openssl s_client -showcerts -host "${_view_certificate_host}" -port "${_view_certificate_port}" 2>&1 \
                    | openssl x509 -inform pem -noout -enddate \
                    | cut -d "=" -f 2
            fi
        ;;
        ([Ff]ingerprint)
            openssl x509 -in "${_view_certificate_in}" -fingerprint -noout
        ;;
        ([Ii]ssuer)
            openssl x509 -in "${_view_certificate_in}" -issuer -noout |
                sed -e "s/^issuer=//"
        ;;
        ([Mm]odulus)
            openssl x509 -noout -modulus -in "${_view_certificate_in}" | shasum -a 256
        ;;
        ([Oo][Uu]|[Oo]rg|[Oo]rg[Nn]ame)
            openssl x509 -in "${_view_certificate_in}" -subject -noout -nameopt multiline |
                awk -F '= ' '/organizationalUnitName/{print $2}' |
                paste -s -
        ;;
        ([Ss][Aa][Nn][Ss])
            openssl x509 -in "${_view_certificate_in}" -text -noout |
                grep "DNS:" |
                trim |
                paste -sd ' ' - |
                grep .
        ;;
        ([Ss]erial)
            openssl x509 -in "${_view_certificate_in}" -serial -noout |
                sed -e "s/^serial=//"
        ;;
        ([Ss]tart)
            openssl x509 -in "${_view_certificate_in}" -startdate -noout |
                sed -e "s/^notBefore=//" -e "s/GMT//" |
                awk '{printf("%s %02d %d %s\n", $1,$2,$4,$3)}'
        ;;
        ([Ss]tate)
            case "$(openssl x509 -in "${_view_certificate_in}" -checkend "${2:-0}")" in
                (*'not expire'*)  printf -- '%s\n' "OK" ;;
                (*'will expire')  printf -- '%s\n' "EXPIRED" ;;
            esac
        ;;
        (*)
            openssl x509 -text -noout -in "${_view_certificate_in}"
        ;;
    esac
}
