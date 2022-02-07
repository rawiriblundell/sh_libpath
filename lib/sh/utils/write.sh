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

# 'write()' abstracts the portability of 'printf' and solves the major portability headaches 
# caused by various implementations of 'echo'.  This is called 'write()' rather than using 
# 'echo()' as  an override function, because some shells protect their builtins and complain.
# Fun exercise: look at Oracle's man page for 'echo', specifically the USAGE section.
# This also adds the '-j' option to output in json keypair format (no type-based formatting though)
write() {
    case "${1}" in
        (-e)
            case "${2}" in
                (-n|--end) shift 2; printf -- '%b' "${*}" ;;
                (*)        shift; printf -- '%b\n' "${*}" ;;
            esac
        ;;
        (-E)
            case "${2}" in
                (-n|--end) shift 2; printf -- '%s' "${*}" ;;
                (*)        shift; printf -- '%s\n' "${*}" ;;
            esac
        ;;
        (-j)               shift; printf -- '{"%s": "%s"}\n' "${1}" "${2}" ;;
        (-n|--end)
            case "${2}" in
                (-e)       shift 2; printf -- '%b' "${*}" ;;
                (-E)       shift 2; printf -- '%s' "${*}" ;;
                (*)        shift; printf -- '%s' "${*}" ;;
            esac
        ;;
        (-en|-ne)          shift; printf -- '%b' "${*}" ;;
        (-En|-nE)          shift; printf -- '%s' "${*}" ;;
        (*)                printf -- '%s\n' "${*}" ;;
    esac
}

# Alternative implementation:
# write() {
#     while (( "${#}" > 1 )); do
#         case "${1}" in
#             (-e)        _write_fmt='%b' ;;
#             (-E)        _write_fmt='%s' ;;
#             (-j)        _write_fmt='{"%s": "%s"}' ;;
#             (-n|--end)  _write_newlines='' ;;
#             (-en|-ne)   _write_fmt='%b'; _write_newlines='' ;;
#             (-En|nE)    _write_fmt='%s'; _write_newlines='' ;;
#             (--|*)      break ;;
#         esac
#         shift 1
#     done

#     # shellcheck disable=SC2059
#     printf -- "${_write_fmt:-%b}${_write_newlines:-\n}" "${*}"
#
#     unset -v _write_fmt _write_newlines
# }
