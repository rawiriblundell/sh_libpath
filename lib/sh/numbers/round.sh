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

# Description: Round a given float to the nearest integer or fractional precision
# Example: 'round 3.4445' => 3, 'round 3.4445 2' => 3.44

# Note about common rounding vs bankers rounding
# At school, you were probably taught to always round up from a 
# next-fractional of .5 or more, and to otherwise round down
# e.g.
# 5.5 => 6
# 4.5 => 5
# 4.4 => 4
# Let's call that "common rounding"

# In computing, you can be caught off-guard by the often baked-in language 
# choice of "bankers rounding", which can be simply explained as:
# "If the leading integer is even, round down.  If it's odd, round up."
# Or, in other words: "Round to the nearest even number."
# e.g.
# 5.5 => 6
# 4.5 => 4

# Bankers rounding has been selected as the default mode for many good reasons
# incl: Financial, Statistical and IEEE standards compliance (754, section 4)
# Nonetheless, common rounding needs to be available for regular people and their regular people needs

# See, also:
# https://en.wikipedia.org/wiki/Rounding
# https://en.wikipedia.org/wiki/IEEE_754
# https://floating-point-gui.de/errors/rounding/

# Who knew that rounding could be so esoteric?!

# Usage: round [--common (optional)] [float] [precision (optional)]
round() {
  local _round_float _round_precision _round_fractional
  # First, we test if we are in common rounding mode
  case "${1}" in
    (--common*)
      shift 1
      _round_float="${1:?No float given}"
      _round_precision="${2:-0}"
      _round_fractional="${_round_float#*.}"
      # To match the behaviour of the standard mode, if the precision is longer than
      # the length of the fractional component, we zero-pad the float, then pass it on
      # e.g. "round --common 6.5 4" => 6.5000
      if (( _round_precision > "${#_round_fractional}" )); then
        _round_float="$(printf -- "%.${_round_precision}f\n" "${_round_float}")"
      fi
      # Next, we test for 1dp precision.  If found, we add 0.5 and then simply bank-round
      case "${_round_float}" in
        (*.[0-9])
          printf -- '%s\n' "${_round_float}" | 
            awk -v precision="${_round_precision}" '{ printf("%." precision "f\n", $1 + 0.5) }'
        ;;
        (*.*)
          printf -- '%s\n' "${_round_float}" | 
            awk -v precision="${_round_precision}" '{ printf("%." precision "f\n", $1) }'
        ;;
      esac
      return 0
    ;;
  esac

  # Otherwise we're in standard bankers rounding mode
  printf -- "%.${2:-0}f\n" "${1:?No float given}"
  return 0
}
