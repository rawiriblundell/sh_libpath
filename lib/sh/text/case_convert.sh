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

[ -n "${_SH_LOADED_text_case_convert+x}" ] && return 0
_SH_LOADED_text_case_convert=1

# @description Convert a string to snake_case. Handles space-separated words,
#   hyphen-separated words, and camelCase input.
#
# @arg $@ string The string to convert
#
# @example
#   str_snake_case "Hello World"   # => hello_world
#   str_snake_case "fooBar"        # => foo_bar
#   str_snake_case "kebab-case"    # => kebab_case
#
# @stdout snake_case string
# @exitcode 0 Always
str_snake_case() {
  local _input
  _input="${*}"
  printf -- '%s\n' "${_input}" |
    sed 's/\([A-Z]\)/_\1/g' |
    tr '[:upper:] -' '[:lower:]__' |
    sed 's/_\+/_/g; s/^_//; s/_$//'
}

# @description Convert a string to camelCase. Handles space-separated,
#   underscore-separated, and hyphen-separated words. Input that is already
#   camelCase will be normalised to all-lowercase then re-cased.
#
# @arg $@ string The string to convert
#
# @example
#   str_camel_case "hello world"   # => helloWorld
#   str_camel_case "foo_bar_baz"   # => fooBarBaz
#   str_camel_case "kebab-case"    # => kebabCase
#
# @stdout camelCase string
# @exitcode 0 Always
str_camel_case() {
  local _input _result _word _first
  _input="${*}"
  _input="${_input//[_-]/ }"
  _result=""
  _first=1
  for _word in ${_input}; do
    if (( _first )); then
      _result+="${_word,,}"
      _first=0
    else
      _result+="${_word^}"
    fi
  done
  printf -- '%s\n' "${_result}"
}

# @description Convert a string to kebab-case. Handles space-separated words,
#   underscore-separated words, and camelCase input.
#
# @arg $@ string The string to convert
#
# @example
#   str_kebab_case "Hello World"   # => hello-world
#   str_kebab_case "fooBar"        # => foo-bar
#   str_kebab_case "snake_case"    # => snake-case
#
# @stdout kebab-case string
# @exitcode 0 Always
str_kebab_case() {
  local _input
  _input="${*}"
  printf -- '%s\n' "${_input}" |
    sed 's/\([A-Z]\)/-\1/g' |
    tr '[:upper:] _' '[:lower:]--' |
    sed 's/-\+/-/g; s/^-//; s/-$//'
}

# @description Convert a string to a URL-safe slug: lowercase alphanumeric
#   characters only, with runs of non-alphanumeric characters replaced by
#   a single hyphen.
#
# @arg $@ string The string to convert
#
# @example
#   str_slug "Hello, World!"       # => hello-world
#   str_slug "My Blog Post Title"  # => my-blog-post-title
#   str_slug "  extra  spaces  "   # => extra-spaces
#
# @stdout URL slug string
# @exitcode 0 Always
str_slug() {
  local _input
  _input="${*}"
  printf -- '%s\n' "${_input}" |
    tr '[:upper:]' '[:lower:]' |
    sed 's/[^a-z0-9]\+/-/g; s/^-//; s/-$//'
}
