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

[ -n "${_SH_LOADED_units_temperature+x}" ] && return 0
_SH_LOADED_units_temperature=1

if ! command -v bc >/dev/null 2>&1; then
    printf -- 'temperature: %s\n' "This library requires 'bc', which was not found in PATH" >&2
    return 1
fi

# Validate that the input is a number (integer or float, signed or unsigned)
_temp_validate() {
    printf -- '%d' "${1:-null}" >/dev/null 2>&1 && return 0
    printf -- '%f' "${1:-null}" >/dev/null 2>&1 && return 0
    return 1
}

########## Celsius <-> Fahrenheit
# Formula: F = (C * 9/5) + 32
celsius_to_fahrenheit() {
    _temp_validate "${1}" || { printf -- '%s\n' "null"; return 1; }
    printf -- '%s\n' "scale=2;(${1} * 9 / 5) + 32" | bc
}

# Formula: C = (F - 32) * 5/9
fahrenheit_to_celsius() {
    _temp_validate "${1}" || { printf -- '%s\n' "null"; return 1; }
    printf -- '%s\n' "scale=2;(${1} - 32) * 5 / 9" | bc
}

########## Celsius <-> Kelvin
# Formula: K = C + 273.15
celsius_to_kelvin() {
    _temp_validate "${1}" || { printf -- '%s\n' "null"; return 1; }
    printf -- '%s\n' "scale=2;${1} + 273.15" | bc
}

# Formula: C = K - 273.15
kelvin_to_celsius() {
    _temp_validate "${1}" || { printf -- '%s\n' "null"; return 1; }
    printf -- '%s\n' "scale=2;${1} - 273.15" | bc
}

########## Fahrenheit <-> Kelvin (via Celsius)
fahrenheit_to_kelvin() {
    local _c
    _temp_validate "${1}" || { printf -- '%s\n' "null"; return 1; }
    _c=$(printf -- '%s\n' "scale=10;(${1} - 32) * 5 / 9" | bc)
    printf -- '%s\n' "scale=2;${_c} + 273.15" | bc
}

kelvin_to_fahrenheit() {
    local _c
    _temp_validate "${1}" || { printf -- '%s\n' "null"; return 1; }
    _c=$(printf -- '%s\n' "scale=10;${1} - 273.15" | bc)
    printf -- '%s\n' "scale=2;(${_c} * 9 / 5) + 32" | bc
}

########## Celsius <-> Rankine
# Formula: R = (C + 273.15) * 9/5
celsius_to_rankine() {
    _temp_validate "${1}" || { printf -- '%s\n' "null"; return 1; }
    printf -- '%s\n' "scale=2;(${1} + 273.15) * 9 / 5" | bc
}

# Formula: C = R * 5/9 - 273.15
rankine_to_celsius() {
    _temp_validate "${1}" || { printf -- '%s\n' "null"; return 1; }
    printf -- '%s\n' "scale=2;${1} * 5 / 9 - 273.15" | bc
}

########## Fahrenheit <-> Rankine (direct: no intermediate needed)
# Formula: R = F + 459.67
fahrenheit_to_rankine() {
    _temp_validate "${1}" || { printf -- '%s\n' "null"; return 1; }
    printf -- '%s\n' "scale=2;${1} + 459.67" | bc
}

# Formula: F = R - 459.67
rankine_to_fahrenheit() {
    _temp_validate "${1}" || { printf -- '%s\n' "null"; return 1; }
    printf -- '%s\n' "scale=2;${1} - 459.67" | bc
}

########## Kelvin <-> Rankine (direct: no intermediate needed)
# Formula: R = K * 9/5
kelvin_to_rankine() {
    _temp_validate "${1}" || { printf -- '%s\n' "null"; return 1; }
    printf -- '%s\n' "scale=2;${1} * 9 / 5" | bc
}

# Formula: K = R * 5/9
rankine_to_kelvin() {
    _temp_validate "${1}" || { printf -- '%s\n' "null"; return 1; }
    printf -- '%s\n' "scale=2;${1} * 5 / 9" | bc
}

########## Celsius <-> Newton
# Formula: N = C * 33/100
celsius_to_newton() {
    _temp_validate "${1}" || { printf -- '%s\n' "null"; return 1; }
    printf -- '%s\n' "scale=2;${1} * 33 / 100" | bc
}

# Formula: C = N * 100/33
newton_to_celsius() {
    _temp_validate "${1}" || { printf -- '%s\n' "null"; return 1; }
    printf -- '%s\n' "scale=2;${1} * 100 / 33" | bc
}

########## Celsius <-> Rømer
# Formula: Ro = C * 21/40 + 7.5
celsius_to_romer() {
    _temp_validate "${1}" || { printf -- '%s\n' "null"; return 1; }
    printf -- '%s\n' "scale=2;${1} * 21 / 40 + 7.5" | bc
}

# Formula: C = (Ro - 7.5) * 40/21
romer_to_celsius() {
    _temp_validate "${1}" || { printf -- '%s\n' "null"; return 1; }
    printf -- '%s\n' "scale=2;(${1} - 7.5) * 40 / 21" | bc
}

########## Celsius <-> Delisle
# Note: Delisle is an inverted scale — water boils at 0°De, freezes at 150°De
# Formula: De = (100 - C) * 3/2
celsius_to_delisle() {
    _temp_validate "${1}" || { printf -- '%s\n' "null"; return 1; }
    printf -- '%s\n' "scale=2;(100 - ${1}) * 3 / 2" | bc
}

# Formula: C = 100 - De * 2/3
delisle_to_celsius() {
    _temp_validate "${1}" || { printf -- '%s\n' "null"; return 1; }
    printf -- '%s\n' "scale=2;100 - ${1} * 2 / 3" | bc
}

########## Celsius <-> Réaumur
# Formula: Ré = C * 4/5
celsius_to_reaumur() {
    _temp_validate "${1}" || { printf -- '%s\n' "null"; return 1; }
    printf -- '%s\n' "scale=2;${1} * 4 / 5" | bc
}

# Formula: C = Ré * 5/4
reaumur_to_celsius() {
    _temp_validate "${1}" || { printf -- '%s\n' "null"; return 1; }
    printf -- '%s\n' "scale=2;${1} * 5 / 4" | bc
}

########## Dispatcher helpers (internal)

# Convert any supported unit to Celsius
# Usage: _temp_to_celsius <value> <unit>
# Units: C F K R N Ro De Re (case-insensitive)
_temp_to_celsius() {
    case "${2}" in
        ([Cc])       printf -- '%s\n' "${1}" ;;
        ([Ff])       fahrenheit_to_celsius "${1}" ;;
        ([Kk])       kelvin_to_celsius "${1}" ;;
        ([Rr])       rankine_to_celsius "${1}" ;;
        ([Nn])       newton_to_celsius "${1}" ;;
        ([Rr][Oo])   romer_to_celsius "${1}" ;;
        ([Dd][Ee])   delisle_to_celsius "${1}" ;;
        ([Rr][Ee])   reaumur_to_celsius "${1}" ;;
        (*) printf -- 'temperature: unknown unit: %s\n' "${2}" >&2; return 1 ;;
    esac
}

# Convert Celsius to any supported unit
# Usage: _temp_from_celsius <value> <unit>
_temp_from_celsius() {
    case "${2}" in
        ([Cc])       printf -- '%s\n' "${1}" ;;
        ([Ff])       celsius_to_fahrenheit "${1}" ;;
        ([Kk])       celsius_to_kelvin "${1}" ;;
        ([Rr])       celsius_to_rankine "${1}" ;;
        ([Nn])       celsius_to_newton "${1}" ;;
        ([Rr][Oo])   celsius_to_romer "${1}" ;;
        ([Dd][Ee])   celsius_to_delisle "${1}" ;;
        ([Rr][Ee])   celsius_to_reaumur "${1}" ;;
        (*) printf -- 'temperature: unknown unit: %s\n' "${2}" >&2; return 1 ;;
    esac
}

########## Public API

# Convert a temperature between any two supported units
# Usage: temp_convert <value> <from_unit> <to_unit>
# Example: temp_convert 100 C F
temp_convert() {
    local _celsius
    _temp_validate "${1}" || { printf -- '%s\n' "null"; return 1; }
    _celsius=$(_temp_to_celsius "${1}" "${2}") || return 1
    _temp_from_celsius "${_celsius}" "${3}"
}

# Display a temperature converted to all supported units
# Usage: temp_convert_all <value> <from_unit>
# Example: temp_convert_all 100 C
temp_convert_all() {
    local _celsius
    _temp_validate "${1}" || { printf -- '%s\n' "null"; return 1; }
    _celsius=$(_temp_to_celsius "${1}" "${2}") || return 1
    printf -- 'Celsius    = %s°C\n'  "${_celsius}"
    printf -- 'Fahrenheit = %s°F\n'  "$(celsius_to_fahrenheit "${_celsius}")"
    printf -- 'Kelvin     = %s°K\n'  "$(celsius_to_kelvin     "${_celsius}")"
    printf -- 'Rankine    = %s°R\n'  "$(celsius_to_rankine    "${_celsius}")"
    printf -- 'Newton     = %s°N\n'  "$(celsius_to_newton     "${_celsius}")"
    printf -- 'Rømer      = %s°Ro\n' "$(celsius_to_romer      "${_celsius}")"
    printf -- 'Delisle    = %s°De\n' "$(celsius_to_delisle    "${_celsius}")"
    printf -- 'Réaumur    = %s°Ré\n' "$(celsius_to_reaumur    "${_celsius}")"
}
