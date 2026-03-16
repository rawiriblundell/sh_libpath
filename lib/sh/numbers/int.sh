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

[ -n "${_SHELLAC_LOADED_numbers_int+x}" ] && return 0
_SHELLAC_LOADED_numbers_int=1

# @description Parse a string into a base-10 integer.
#   Auto-detects numeric representation from prefix or format, or accepts an explicit source base.
#   Handles: decimal, hex (0x/0X), binary (0b/0B), octal (0o/0O), scientific notation, floats (truncated).
#
# @arg $1 string The value to parse
# @arg $2 int    Optional: source base for the input string (default: auto-detect)
#
# @example
#   num_parse "0xFF"    # => 255
#   num_parse "FF" 16   # => 255
#   num_parse "1.5e3"   # => 1500
#   num_parse "3.7"     # => 3
#
# @stdout Base-10 integer
# @exitcode 0 Always
# @exitcode 1 No input given
num_parse() {
    local _input _base _stripped
    _input="${1:?No value given}"
    _base="${2:-}"

    # Explicit base: use bash's base#value arithmetic syntax
    if [[ -n "${_base}" ]]; then
        printf -- '%d\n' "$(( ${_base}#${_input} ))"
        return
    fi

    # Auto-detect representation from prefix or format
    case "${_input}" in
        # Scientific notation: 1.5e3, 2E10, -1.0e-3 etc.
        (*[eE]*)
            awk -v v="${_input}" 'BEGIN { printf "%d\n", v }'
        ;;
        # Hex prefix 0x or 0X
        (0[xX]*)
            _stripped="${_input#0[xX]}"
            printf -- '%d\n' "$(( 16#${_stripped} ))"
        ;;
        # Binary prefix 0b or 0B
        (0[bB]*)
            _stripped="${_input#0[bB]}"
            printf -- '%d\n' "$(( 2#${_stripped} ))"
        ;;
        # Octal prefix 0o or 0O
        (0[oO]*)
            _stripped="${_input#0[oO]}"
            printf -- '%d\n' "$(( 8#${_stripped} ))"
        ;;
        # Float: truncate (do not round) the fractional part
        (*.*)
            printf -- '%s\n' "${_input}" | awk -F '.' '{print $1}'
        ;;
        # Plain integer (possibly signed)
        (*)
            printf -- '%d\n' "${_input}"
        ;;
    esac
}

# @description Format an integer in the given base.
#   Supports bases 2-36. Bases 8, 10, and 16 use printf directly; others use a digit-string loop.
#
# @arg $1 int The integer to format
# @arg $2 int Target base (default: 10)
#
# @example
#   num_format 255 16   # => ff
#   num_format 255 2    # => 11111111
#   num_format 255 8    # => 377
#
# @stdout Integer represented in the target base
# @exitcode 0 Always
# @exitcode 1 No input given
num_format() {
    local _n _base _digits _result _rem _neg
    _n="${1:?No integer given}"
    _base="${2:-10}"
    _neg=""

    case "${_base}" in
        (10) printf -- '%d\n' "${_n}" ;;
        (16) printf -- '%x\n' "${_n}" ;;
        (8)  printf -- '%o\n' "${_n}" ;;
        (*)
            _digits="0123456789abcdefghijklmnopqrstuvwxyz"
            _result=""
            if (( _n < 0 )); then
                _n=$(( _n * -1 ))
                _neg="-"
            fi
            if (( _n == 0 )); then
                printf -- '0\n'
                return
            fi
            while (( _n > 0 )); do
                _rem=$(( _n % _base ))
                _result="${_digits:${_rem}:1}${_result}"
                _n=$(( _n / _base ))
            done
            printf -- '%s\n' "${_neg}${_result}"
        ;;
    esac
}

# @description Convenience alias for num_parse(). Parses a string to a base-10 integer.
#   Equivalent to Go's strconv.Atoi.
#
# @arg $@ Forwarded to num_parse
#
# @stdout Base-10 integer
# @exitcode 0 Always
# @exitcode 1 No input given
int() {
    num_parse "${@}"
}

# @description Test whether a value can be interpreted as an integer.
#   Guards against leading quote characters that printf %d treats as octal.
#
# @arg $1 string Value to test
#
# @exitcode 0 Value is an integer
# @exitcode 1 Value is not an integer
num_is_integer() {
    case "${1:-null}" in
        ("'"*|'"'*) return 1 ;;
    esac
    printf -- '%d' "${1:-null}" >/dev/null 2>&1
}

# @description Test whether a value can be interpreted as a float.
#
# @arg $1 string Value to test
#
# @exitcode 0 Value is a float
# @exitcode 1 Value is not a float
num_is_float() {
    printf -- '%f' "${1:-null}" >/dev/null 2>&1
}

# @description Test whether an integer is odd.
#
# @arg $1 int Integer to test
#
# @exitcode 0 Number is odd
# @exitcode 1 Number is even
num_is_odd() {
    (( (${1:?No number specified} % 2) != 0 ))
}

# @description Test whether an integer is even.
#
# @arg $1 int Integer to test
#
# @exitcode 0 Number is even
# @exitcode 1 Number is odd
num_is_even() {
    (( (${1:?No number specified} % 2) == 0 ))
}
