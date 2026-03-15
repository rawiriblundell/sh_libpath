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

[ -n "${_SHELLAC_LOADED_text_prefix_suffix+x}" ] && return 0
_SHELLAC_LOADED_text_prefix_suffix=1

# @description Remove a prefix from a string. If the string does not start
#   with the prefix, the original string is returned unchanged.
#
# @arg $1 string The string to process
# @arg $2 string The prefix to remove
#
# @example
#   str_remove_prefix "foobar" "foo"   # => bar
#   str_remove_prefix "foobar" "baz"   # => foobar
#
# @stdout String with prefix removed
# @exitcode 0 Always
str_remove_prefix() {
  local _str _prefix
  _str="${1:?No string given}"
  _prefix="${2:?No prefix given}"
  printf -- '%s\n' "${_str#"${_prefix}"}"
}

# @description Remove a suffix from a string. If the string does not end
#   with the suffix, the original string is returned unchanged.
#
# @arg $1 string The string to process
# @arg $2 string The suffix to remove
#
# @example
#   str_remove_suffix "foobar" "bar"   # => foo
#   str_remove_suffix "foobar" "baz"   # => foobar
#
# @stdout String with suffix removed
# @exitcode 0 Always
str_remove_suffix() {
  local _str _suffix
  _str="${1:?No string given}"
  _suffix="${2:?No suffix given}"
  printf -- '%s\n' "${_str%"${_suffix}"}"
}

# @description Append a suffix to a string if the string does not already
#   end with that suffix.
#
# @arg $1 string The string to process
# @arg $2 string The suffix to append if missing
#
# @example
#   str_append_if_missing "/etc/hosts" "s"   # => /etc/hostss
#   str_append_if_missing "/etc/hosts" "/"   # => /etc/hosts/
#   str_append_if_missing "/etc/hosts/" "/"  # => /etc/hosts/
#
# @stdout String with suffix appended if it was missing
# @exitcode 0 Always
str_append_if_missing() {
  local _str _suffix
  _str="${1:?No string given}"
  _suffix="${2:?No suffix given}"
  [[ "${_str}" = *"${_suffix}" ]] || _str="${_str}${_suffix}"
  printf -- '%s\n' "${_str}"
}

# @description Prepend a prefix to a string if the string does not already
#   start with that prefix.
#
# @arg $1 string The string to process
# @arg $2 string The prefix to prepend if missing
#
# @example
#   str_prepend_if_missing "etc/hosts" "/"   # => /etc/hosts
#   str_prepend_if_missing "/etc/hosts" "/"  # => /etc/hosts
#
# @stdout String with prefix prepended if it was missing
# @exitcode 0 Always
str_prepend_if_missing() {
  local _str _prefix
  _str="${1:?No string given}"
  _prefix="${2:?No prefix given}"
  [[ "${_str}" = "${_prefix}"* ]] || _str="${_prefix}${_str}"
  printf -- '%s\n' "${_str}"
}
