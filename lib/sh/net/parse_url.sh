# shellcheck shell=bash

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
# Adapted from kvz/bash3boilerplate (MIT) https://github.com/kvz/bash3boilerplate
# Original author: Kevin van Zonneveld

[ -n "${_SHELLAC_LOADED_net_parse_url+x}" ] && return 0
_SHELLAC_LOADED_net_parse_url=1

# @description Parse a URL into its component parts.
#   With one argument, prints all components as key: value lines.
#   With a second argument, prints only the requested field.
#   Default ports are inferred for http, https, mysql, redis if not explicitly set.
#
# @arg $1 string URL to parse (e.g. "https://user:pw@example.com:8080/some/path")
# @arg $2 string Optional field: proto user pass host port path
#
# @example
#   net_parse_url 'https://user:pw@host.com:8080/path' host   # => host.com
#   net_parse_url 'https://example.com/foo' port               # => 443
#
# @stdout Requested field value, or all fields
# @exitcode 0 Success; 1 Unknown field selector; 2 Missing argument
net_parse_url() {
  local url proto userpass user pass hostport host port path need

  [[ $# -eq 0 ]] && { printf -- '%s\n' "net_parse_url: missing argument" >&2; return 2; }

  url="${1}"
  need="${2:-}"

  proto=""
  userpass=""
  user=""
  pass=""
  host=""
  port=""
  path=""

  if [[ "${url}" = *"://"* ]]; then
    proto="${url%%://*}://"
    url="${url#*://}"
  fi

  if [[ "${url}" = *"@"* ]]; then
    userpass="${url%%@*}"
    url="${url#*@}"
  fi

  hostport="${url%%/*}"
  if [[ "${url}" = */* ]]; then
    path="${url#*/}"
  fi

  if [[ "${userpass}" = *":"* ]]; then
    user="${userpass%%:*}"
    pass="${userpass#*:}"
  else
    user="${userpass}"
  fi

  if [[ "${hostport}" = *":"* ]]; then
    host="${hostport%%:*}"
    port="${hostport#*:}"
  else
    host="${hostport}"
  fi

  [[ -z "${user}" ]] && user="${userpass}"
  [[ -z "${host}" ]] && host="${hostport}"

  if [[ -z "${port}" ]]; then
    case "${proto}" in
      (http://)  port="80"   ;;
      (https://) port="443"  ;;
      (mysql://) port="3306" ;;
      (redis://) port="6379" ;;
      (*) ;;
    esac
  fi

  if [[ -n "${need}" ]]; then
    case "${need}" in
      (proto|user|pass|host|port|path)
        printf -- '%s\n' "${!need}"
      ;;
      (*)
        printf -- 'net_parse_url: unknown field selector: %s\n' "${need}" >&2
        return 1
      ;;
    esac
  else
    printf -- 'proto: %s\n' "${proto}"
    printf -- 'user:  %s\n' "${user}"
    printf -- 'pass:  %s\n' "${pass}"
    printf -- 'host:  %s\n' "${host}"
    printf -- 'port:  %s\n' "${port}"
    printf -- 'path:  %s\n' "${path}"
  fi
}
