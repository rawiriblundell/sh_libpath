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
# Provenance: https://raw.githubusercontent.com/rawiriblundell/dotfiles/master/.bashrc
# SPDX-License-Identifier: Apache-2.0

[ -n "${_SH_LOADED_line_line_immutable+x}" ] && return 0
_SH_LOADED_line_line_immutable=1

# @description Ensure a line is present in a file (idempotent). If the line
#   already exists verbatim, nothing is done. Otherwise the line is appended,
#   inserted before a given line number, or inserted after the first line
#   matching a given pattern.
#
# @arg $1 string Optional: -a|--after <pattern> — insert after first matching line
# @arg $1 string Optional: -n|--line-number <n> — insert before line number n
# @arg $1 string The line to ensure is present
# @arg $2 string The file to operate on
#
# @example
#   line_immutable "nameserver 1.1.1.1" /etc/resolv.conf
#   line_immutable --after "^Host \*" "  ServerAliveInterval 60" ~/.ssh/config
#   line_immutable --line-number 3 "# inserted" /etc/myconfig
#
# @exitcode 0 Line was already present or successfully inserted
# @exitcode 1 File not found, not writable, or pattern not matched
line_immutable() {
  local _line _file _after _linenum _mode _tmp
  _mode="append"

  while (( ${#} > 0 )); do
    case "${1}" in
      (-a|--after)
        _after="${2:?--after requires a pattern}"
        _mode="after"
        shift 2
      ;;
      (-n|--line-number)
        _linenum="${2:?--line-number requires a number}"
        _mode="linenum"
        shift 2
      ;;
      (--) shift; break ;;
      (-*)
        printf -- '%s\n' "line_immutable: unknown option: ${1}" >&2
        return 1
      ;;
      (*) break ;;
    esac
  done

  _line="${1:?No line given}"
  _file="${2:?No file given}"

  if [[ ! -f "${_file}" ]]; then
    printf -- '%s\n' "line_immutable: ${_file}: file not found" >&2
    return 1
  fi
  if [[ ! -w "${_file}" ]]; then
    printf -- '%s\n' "line_immutable: ${_file}: not writable" >&2
    return 1
  fi

  # Line already present verbatim — nothing to do
  grep -qF -- "${_line}" "${_file}" && return 0

  case "${_mode}" in
    (append)
      printf -- '%s\n' "${_line}" >> "${_file}"
    ;;
    (after)
      if ! grep -q -- "${_after}" "${_file}"; then
        printf -- '%s\n' "line_immutable: pattern not found: ${_after}" >&2
        return 1
      fi
      _tmp="$(mktemp)"
      awk -v after="${_after}" -v line="${_line}" '
        { print }
        !inserted && $0 ~ after { print line; inserted=1 }
      ' "${_file}" > "${_tmp}" && mv -- "${_tmp}" "${_file}"
      rm -f "${_tmp}"
    ;;
    (linenum)
      case "${_linenum}" in
        (*[!0-9]*)
          printf -- '%s\n' "line_immutable: not an integer: ${_linenum}" >&2
          return 1
        ;;
      esac
      _tmp="$(mktemp)"
      awk -v n="${_linenum}" -v line="${_line}" '
        NR == n { print line }
        { print }
      ' "${_file}" > "${_tmp}" && mv -- "${_tmp}" "${_file}"
      rm -f "${_tmp}"
    ;;
  esac
}
