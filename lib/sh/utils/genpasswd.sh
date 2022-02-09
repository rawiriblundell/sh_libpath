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
# genpasswd password generator
################################################################################
# Password generator function for when 'pwgen' or 'apg' aren't available
# Koremutake mode inspired by:
# https:#raw.githubusercontent.com/lpar/kpwgen/master/kpwgen.go
# http://shorl.com/koremutake.php
genpasswd() {
  export LC_CTYPE=C
  # localise variables for safety
  local OPTIND pwdChars pwdDigit pwdNum pwdSet pwdKoremutake pwdUpper \
    pwdSpecial pwdSpecialChars pwdSyllables n t u v tmpArray

  # Default the vars
  pwdChars=10
  pwdDigit="false"
  pwdNum=1
  pwdSet="[:alnum:]"
  pwdKoremutake="false"
  pwdUpper="false"
  pwdSpecial="false"
  # shellcheck disable=SC1001
  pwdSpecialChars=(\! \@ \# \$ \% \^ \( \) \_ \+ \? \> \< \~)

  # Filtered koremutake syllables
  # http:#shorl.com/koremutake.php
  pwdSyllables=( ba be bi bo bu by da de di 'do' du dy fe 'fi' fo fu fy ga ge \
    gi go gu gy ha he hi ho hu hy ja je ji jo ju jy ka ke ko ku ky la le li \
    lo lu ly ma me mi mo mu my na ne ni no nu ny pa pe pi po pu py ra re ri \
    ro ru ry sa se si so su sy ta te ti to tu ty va ve vi vo vu vy bra bre \
    bri bro bru bry dra dre dri dro dru dry fra fre fri fro fru fry gra gre \
    gri gro gru gry pra pre pri pro pru pry sta ste sti sto stu sty tra tre \
    er ed 'in' ex al en an ad or at ca ap el ci an et it ob of af au cy im op \
    co up ing con ter com per ble der cal man est 'for' mer col ful get low \
    son tle day pen pre ten tor ver ber can ple fer gen den mag sub sur men \
    min out tal but cit cle cov dif ern eve hap ket nal sup ted tem tin tro
  )

  while getopts ":c:DhKn:SsUY" Flags; do
    case "${Flags}" in
      (c)  pwdChars="${OPTARG}";;
      (D)  pwdDigit="true";;
      (h)  printf -- '%s\n' "" "genpasswd - a poor sysadmin's pwgen" \
             "" "Usage: genpasswd [options]" "" \
             "Optional arguments:" \
             "-c [Number of characters. Minimum is 4. (Default:${pwdChars})]" \
             "-D [Require at least one digit (Default:off)]" \
             "-h [Help]" \
             "-K [Koremutake mode.  Uses syllables rather than characters, meaning more phonetical pwds." \
             "    Note: In this mode, character counts = syllable count and different defaults are used]" \
             "-n [Number of passwords (Default:${pwdNum})]" \
             "-s [Strong mode, seeds a limited amount of special characters into the mix (Default:off)]" \
             "-S [Stronger mode, complete mix of characters (Default:off)]" \
             "-U [Require at least one uppercase character (Default:off)]" \
             "-Y [Require at least one special character (Default:off)]" \
             "" "Note1: Broken Pipe errors, (older bash versions) can be ignored" \
             "Note2: If you get umlauts, cyrillic etc, export LC_ALL= to something like en_US.UTF-8"
           return 0;;
      (K)  pwdKoremutake="true";;
      (n)  pwdNum="${OPTARG}";;
      # Attempted to randomise special chars using 7 random chars from [:punct:] but reliably
      # got "reverse collating sequence order" errors.  Seeded 9 special chars manually instead.
      (s)  pwdSet="[:alnum:]#$&+/<}^%@";;
      (S)  pwdSet="[:graph:]";;
      (U)  pwdUpper="true";;
      (Y)  pwdSpecial="true";;
      (\?)  printf -- '%s\n' "[ERROR] genpasswd: Invalid option: $OPTARG.  Try 'genpasswd -h' for usage." >&2
            return 1;;
      (:)  echo "[ERROR] genpasswd: Option '-$OPTARG' requires an argument, e.g. '-$OPTARG 5'." >&2
           return 1;;
    esac
  done

  # We need to check that the character length is more than 4 to protect against
  # infinite loops caused by the character checks.  i.e. 4 character checks on a 3 character password
  if (( pwdChars < 4 )); then
    printf -- '%s\n' "[ERROR] genpasswd: Password length must be greater than four characters." >&2
    return 1
  fi

  if [[ "${pwdKoremutake}" = "true" ]]; then
    for (( i=0; i<pwdNum; i++ )); do
      n=0
      for int in $(randInt "${pwdChars:-7}" 1 $(( ${#pwdSyllables[@]} - 1 )) ); do
        tmpArray[n]=$(printf -- '%s\n' "${pwdSyllables[int]}")
        (( n++ ))
      done
      read -r t u v < <(randInt 3 0 $(( ${#tmpArray[@]} - 1 )) | paste -s -)
      #pwdLower is effectively guaranteed, so we skip it and focus on the others
      if [[ "${pwdUpper}" = "true" ]]; then
        tmpArray[t]=$(capitalise "${tmpArray[t]}")
      fi
      if [[ "${pwdDigit}" = "true" ]]; then
        while (( u == t )); do
          u="$(randInt 1 0 $(( ${#tmpArray[@]} - 1 )) )"
        done
        tmpArray[u]="$(randInt 1 0 9)"
      fi
      if [[ "${pwdSpecial}" = "true" ]]; then
        while (( v == t )); do
          v="$(randInt 1 0 $(( ${#tmpArray[@]} - 1 )) )"
        done
        randSpecial=$(randInt 1 0 $(( ${#pwdSpecialChars[@]} - 1 )) )
        tmpArray[v]="${pwdSpecialChars[randSpecial]}"
      fi
      printf -- '%s\n' "${tmpArray[@]}" | paste -sd '\0' -
    done
  else
    for (( i=0; i<pwdNum; i++ )); do
      n=0
      while read -r; do
        tmpArray[n]="${REPLY}"
        (( n++ ))
      done < <(tr -dc "${pwdSet}" < /dev/urandom | tr -d ' ' | fold -w 1 | head -n "${pwdChars}")
      read -r t u v < <(randInt 3 0 $(( ${#tmpArray[@]} - 1 )) | paste -s -)
      #pwdLower is effectively guaranteed, so we skip it and focus on the others
      if [[ "${pwdUpper}" = "true" ]]; then
        if ! printf -- '%s\n' "tmpArray[@]}" | grep "[A-Z]" >/dev/null 2>&1; then
          tmpArray[t]=$(capitalise "${tmpArray[t]}")
        fi
      fi
      if [[ "${pwdDigit}" = "true" ]]; then
        while (( u == t )); do
          u="$(randInt 1 0 $(( ${#tmpArray[@]} - 1 )) )"
        done
        if ! printf -- '%s\n' "tmpArray[@]}" | grep "[0-9]" >/dev/null 2>&1; then
          tmpArray[u]="$(randInt 1 0 9)"
        fi
      fi
      # Because special characters aren't sucked up from /dev/urandom,
      # we have no reason to test for them, just swap one in
      if [[ "${pwdSpecial}" = "true" ]]; then
        while (( v == t )); do
          v="$(randInt 1 0 $(( ${#tmpArray[@]} - 1 )) )"
        done
        randSpecial=$(randInt 1 0 $(( ${#pwdSpecialChars[@]} - 1 )) ) 
        tmpArray[v]="${pwdSpecialChars[randSpecial]}"
      fi
      printf -- '%s\n' "${tmpArray[@]}" | paste -sd '\0' -
    done
  fi
} 
