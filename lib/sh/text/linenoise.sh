
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

connectssh() {
  local target failmsg
  target="${1:?No target specified}"
  failmsg="(connectssh) FATAL ERROR: ${target} unreachable!"
  len=20

  printf -- '%s ' "Connecting to ${target}, using additional hashing:"

  for (( i=0; i<len; ++i )); do
    until (( xInt <= 88 )); do
      xInt="${RANDOM}"
    done
    xInt="$(( xInt % 95 + 32 ))"

    tput sc
    for (( j=32; j<xInt; j++ )); do 
      tput rc
      printf "\\$(printf -- '%03o' "${j}")"
    done
    tput rc && tput bold; printf "\\$(printf -- '%03o' "${j}")"; tput sgr0
    tput rc && printf "\\$(printf -- '%03o' "${j}")"
  done

  tput setaf 1
  printf -- '\n%s\n' "${failmsg}" 
  tput sgr0
}

# Instead of flooding the screen with garbage, just give the illusion of something happening.

# The above code selects a (hopefully) modulo-debiased number between 32 and 126 and cycles through the ASCII table, printing through every character until it reaches the desired character.

# For example, let's say we get a number of 38, which corresponds with `&`, it will cycle through like this:

# * Save location
# * print dec 32: ` `
# * Return to saved location
# * print dec 33: `!`
# * Return to saved location
# * print dec 34: `"`
# * and so on through these characters: ` !"#$%&`

# Because we're always returning to the saved location, it will appear as if each character is overwriting the previous one in place, giving a cycling effect.  Ultimately, you'll get an output that looks like:

#     ▓▒░$ connectssh remotepants
#     Connecting to remotepants, using additional hashing: CcJjeTt+KkEeWwpeJj9Y
#     (connectssh) FATAL ERROR: remotepants unreachable!


# Because it's called `connectssh` it looks legit-ish without being Mr Robot levels of accuracy.

# It's a bit `bash`y so it may need adjustment for mobile usage, and it could do with a little more polish.
