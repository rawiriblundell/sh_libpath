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

# Algorithm used in this function as described here:
# https://www.quora.com/Is-every-prime-number-other-than-2-and-3-of-the-form-6k%C2%B11-Is-this-a-proven-result-What-are-other-resources-about-it

# To quote:
# If a number leaves a remainder of 0, 2 or 4 when divided by 6, then it is even and therefore non-prime (unless it is 2).
# If it leaves a remainder of 3 when divided by 6 then it is divisible by 3 and therefore non-prime (unless it is 3).
# That leaves just the remainders 1 and 5, or in other words, numbers of the form  6k±1 .
is_prime() {
    # Check whether we're in verbose mode or not
    case "${1}" in
        (-v|--verbose)
            _prime_verbose="true"
            shift 1
        ;;
    esac
    # Ensure that _prime_verbose is set - default to 'false'
    _prime_verbose="${_prime_verbose:-false}"

    # Ensure that what's to be tested is actually a number
    _prime_test="${1:?No input number specified}"
    if ! printf -- '%d' "${_prime_test}" >/dev/null 2>&1; then
        if [[ "${_prime_verbose}" = "true" ]]; then
            printf -- '%s\n' "'${_prime_test}' does not appear to be a number" >&2
        fi
        unset -v _prime_verbose _prime_test
        return 1
    fi

    # Less than 2?  Not a prime.
    # Also prevents divide-by-0 opening up a rift in space/time.
    if (( _prime_test < 2 )); then
        if [[ "${_prime_verbose}" = "true" ]]; then
            printf -- '%s\n' "'${_prime_test}' is not a prime"
        fi
        unset -v _prime_verbose _prime_test
        return 1
    fi

    # 2 or 3?  Prime.
    if (( _prime_test == 2 )) || (( _prime_test == 3 )); then
        if [[ "${_prime_verbose}" = "true" ]]; then
            printf -- '%s\n' "'${_prime_test}' is a prime"
        fi
        unset -v _prime_verbose _prime_test
        return 0
    fi

    case "$(( _prime_test % 6 ))" in
        (0|2|3|4)
            if [[ "${_prime_verbose}" = "true" ]]; then
                printf -- '%s\n' "'${_prime_test}' is not a prime"
            fi
            unset -v _prime_verbose _prime_test
            return 1
        ;;
        (*)
            if [[ "${_prime_verbose}" = "true" ]]; then
                printf -- '%s\n' "'${_prime_test}' is a prime"
            fi
            unset -v _prime_verbose _prime_test
            return 0
        ;;
    esac
}
