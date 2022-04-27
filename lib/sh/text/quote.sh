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

# TODO: Add stdin parsing
str_quote() {
    case "${1}" in
        (-s|--single)
            _str_quote_left="'"; _str_quote_right="'"; shift 1
        ;;
        (-b|--backticks|--graves)
            _str_quote_left="\`"; _str_quote_right="\`"; shift 1
        ;;
        (-P|--parens)
            _str_quote_left="("; _str_quote_right=")"; shift 1
        ;;
        (-C|--braces)
            _str_quote_left="{"; _str_quote_right="}"; shift 1
        ;;
        (-S|--brackets)
            _str_quote_left="["; _str_quote_right="]"; shift 1
        ;;
        (-A|--chevrons)
            _str_quote_left="<"; _str_quote_right=">"; shift 1
        ;;
        (-d|--double)
            _str_quote_left='"'; _str_quote_right='"'; shift 1
        ;;
        (*)
            _str_quote_left='"'; _str_quote_right='"'
        ;;
    esac
    printf -- '%s\n' "${_str_quote_left}${*}${_str_quote_right}"
    unset -v _str_quote_left _str_quote_right
}
