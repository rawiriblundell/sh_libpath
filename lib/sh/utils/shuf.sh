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

################################################################################
# NOTE: This function is a work in progress
################################################################################
# Check if 'shuf' is available, if not, provide basic shuffle functionality
# Check commit history for a range of alternative methods - ruby, perl, python etc
# Requires: randInt function
if ! command -v shuf >/dev/null 2>&1; then
  shuf() {
    local OPTIND inputRange inputStrings nMin nMax nCount shufArray shufRepeat

    # First test that $RANDOM is available
    if (( ${RANDOM}${RANDOM} == ${RANDOM}${RANDOM} )); then
      printf -- '%s\n' "shuf: RANDOM global variable required but doesn't appear to be available"
      return 1
    fi

    while getopts ":e:i:hn:rv:" optFlags; do
      case "${optFlags}" in
        (e) inputStrings=true
            shufArray=( "${OPTARG}" )
            until [[ $(eval "echo \${$OPTIND:0:1}") = "-" ]] || [[ -z $(eval "echo \${$OPTIND}") ]]; do
              # shellcheck disable=SC2207
              shufArray+=($(eval "echo \${$OPTIND}"))
              OPTIND=$((OPTIND + 1))
            done;;
        (h)  printf -- '%s\n' "" "shuf - generate random permutations" \
                "" "Options:" \
                "  -e, echo.                Treat each ARG as an input line" \
                "  -h, help.                Print a summary of the options" \
                "  -i, input-range LO-HI.   Treat each number LO through HI as an input line" \
                "  -n, count.               Output at most n lines" \
                "  -o, output FILE          This option is unsupported in this version, use '> FILE'" \
                "  -r, repeat               Output lines can be repeated" \
                "  -v, version.             Print the version information" ""
              return 0;;
        (i) inputRange=true
            nMin="${OPTARG%-*}"
            nMax="${OPTARG##*-}"
            ;;
        (n) nCount="${OPTARG}";;
        (r) shufRepeat=true;;
        (v)  printf -- '%s\n' "shuf.  This is a bashrc function knockoff that steps in if the real 'shuf' is not found."
             return 0;;
        (\?)  printf -- '%s\n' "shuf: invalid option -- '-$OPTARG'." \
                "Try -h for usage or -v for version info." >&2
              returnt 1;;
        (:)  printf -- '%s\n' "shuf: option '-$OPTARG' requires an argument, e.g. '-$OPTARG 5'." >&2
             return 1;;
      esac
    done
    shift "$(( OPTIND - 1 ))"

    # Handle -e and -i options.  They shouldn't be together because we can't
    # understand their love.  -e is handled later on in the script
    if [[ "${inputRange}" = "true" ]] && [[ "${inputStrings}" == "true" ]]; then
      printf -- '%s\n' "shuf: cannot combine -e and -i options" >&2
      return 1
    fi

    # Default the reservoir size
    # This number was unscientifically chosen using "feels right" technology
    reservoirSize=4096

    # If we're dealing with a file, feed that into file descriptor 6
    if [[ -r "${1}" ]]; then
      # Size it up first and adjust nCount if necessary
      if [[ -n "${nCount}" ]] && (( $(wc -l < "${1}") < nCount )); then
        nCount=$(wc -l < "${1}")
      fi
      exec 6< "${1}"
    # Cater for the -i option
    elif [[ "${inputRange}" = "true" ]]; then
      # If an input range is provided and repeats are ok, then simply call randInt:
      if [[ "${shufRepeat}" = "true" ]] && (( nMax <= 32767 )); then
        randInt "${nCount:-$nMax}" "${nMin}" "${nMax}"
        return "$?"
      # Otherwise, print a complete range to fd6 for later processing
      else
        exec 6< <(eval "printf -- '%d\\n' {$nMin..$nMax}")
      fi
    # If we're dealing with -e, we already have shufArray
    elif [[ "${inputStrings}" = "true" ]]; then
      # First, adjust nCount as appropriate
      if [[ -z "${nCount}" ]] || (( nCount > "${#shufArray[@]}" )); then
        nCount="${#shufArray[@]}"
      fi
      # If repeats are ok, just get it over and done with
      if [[ "${shufRepeat}" = "true" ]] && (( nCount <= 32767 )); then
        for i in $(randInt "${nCount}" 1 "${#shufArray[@]}"); do
          (( i-- ))
          printf -- '%s\n' "${shufArray[i]}"
        done
        return "$?"
      # Otherwise, dump shufArray into fd6
      else
        exec 6< <(printf -- '%s\n' "${shufArray[@]}")
      fi
    # If none of the above things are in use, then we assume stdin
    else
      exec 6<&0
    fi

    # If we reach this point, then we need to setup our output filtering
    # We use this over a conventional loop, because loops are very slow
    # So, if nCount is defined, we pipe all output to 'head -n'
    # Otherwise, we simply stream via `cat` as an overglorified no-op
    if [[ -n "${nCount}" ]]; then
      headOut() { head -n "${nCount}"; }
    else
      headOut() { cat -; }
    fi

    # Start capturing everything for headOut()
    {
      # Turn off globbing for safety
      set -f
      
      # Suck up as much input as required or possible into the reservoir
      mapfile -u 6 -n "${nCount:-$reservoirSize}" -t shufArray

      # If there's more input, we start selecting random points in
      # the reservoir to evict and replace with incoming data
      i="${#shufArray[@]}"
      while IFS=$'\n' read -r -u 6; do
        n=$(randInt 1 1 "$i")
        (( n-- ))
        if (( n < ${#shufArray[@]} )); then
          printf -- '%s\n' "${shufArray[n]}"
          shufArray[n]="${REPLY}"
        else
          printf -- '%s\n' "${REPLY}"
        fi
        (( i++ ))
      done

      # At this point we very likely have something left in the reservoir
      # so we shuffle it out.  This is effectively Satollo's algorithm
      while (( ${#shufArray[@]} > 0 )); do
        n=$(randInt 1 1 "${#shufArray[@]}")
        (( n-- ))
        if (( n < ${#shufArray[@]} )) && [[ -n "${shufArray[n]}" ]]; then
          printf -- '%s\n' "${shufArray[n]}"
          unset -- 'shufArray[n]'
          # shellcheck disable=SC2206
          shufArray=( "${shufArray[@]}" )
        fi
      done
      set +f
    } | headOut
    exec 0<&6 6<&-
  }
fi
