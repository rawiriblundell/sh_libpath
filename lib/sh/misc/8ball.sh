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

8ball() {
  ansArray=(
    "It is certain" "It is decidedly so" "Without a doubt"
    "Yes definitely" "You may rely on it" "You can count on it"
    "As I see it, yes" "Most likely" "Outlook good" "Yes"
    "Signs point to yes" "Absolutely" "Reply hazy try again"
    "Ask again later" "Better not tell you now" "Cannot predict now"
    "Concentrate and ask again" "Don't count on it" "My reply is no"
    "My sources say no" "Outlook not so good" "Very doubtful"
    "Chances aren't good"
  )
  printf -- '%s\n' "${ansArray[$(( RANDOM % ${#ansArray[@]} ))]}"
}
