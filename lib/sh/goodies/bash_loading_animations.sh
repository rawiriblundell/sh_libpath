# shellcheck shell=bash
# shellcheck disable=SC2034

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
# Provenance: https://github.com/rawiriblundell/shellac
# SPDX-License-Identifier: Apache-2.0
#
# Animation arrays and loop/start/stop logic adapted from:
# https://ants-gitlab.inf.um.es/fluidos-old/fluidos/-/raw/main/installation/bash_loading_animations.sh
#
# MIT License
#
# Copyright (c) 2021 Alejandro Molina Zarca, Antonio Skarmeta, Jorge Bernal,
# Jordi Ortíz
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

[ -n "${_SHELLAC_LOADED_goodies_bash_loading_animations+x}" ] && return 0
_SHELLAC_LOADED_goodies_bash_loading_animations=1

### Loading animations list ###
# The first value of an array is the interval (in seconds) between each frame

## ASCII animations ##
# Will work in any terminal, including the TTY.
BLA_classic=( 0.25 '-' "\\" '|' '/' )
BLA_box=( 0.2 ┤ ┴ ├ ┬ )
BLA_bubble=( 0.6 · o O O o · )
BLA_breathe=( 0.9 '  ()  ' ' (  ) ' '(    )' ' (  ) ' )
BLA_growing_dots=( 0.5 '.  ' '.. ' '...' '.. ' '.  ' '   ' )
BLA_passing_dots=( 0.25 '.  ' '.. ' '...' ' ..' '  .' '   ' )
BLA_metro=( 0.2 '[    ]' '[=   ]' '[==  ]' '[=== ]' '[ ===]' '[  ==]' '[   =]' )
BLA_snake=( 0.4 '[=     ]' '[~<    ]' '[~~=   ]' '[~~~<  ]' '[ ~~~= ]' '[  ~~~<]' '[   ~~~]' '[    ~~]' '[     ~]' '[      ]' )
BLA_filling_bar=( 0.25 '█▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒' '██▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒' '███▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒' '████▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒' '█████▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒' '██████▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒' '███████▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒' '████████▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒' '█████████▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒' '██████████▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒' '███████████▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒' '████████████▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒' '█████████████▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒' '██████████████▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒' '███████████████▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒' '████████████████▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒' '█████████████████▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒' '██████████████████▒▒▒▒▒▒▒▒▒▒▒▒▒▒' '███████████████████▒▒▒▒▒▒▒▒▒▒▒▒▒' '████████████████████▒▒▒▒▒▒▒▒▒▒▒▒' '█████████████████████▒▒▒▒▒▒▒▒▒▒▒' '██████████████████████▒▒▒▒▒▒▒▒▒▒' '███████████████████████▒▒▒▒▒▒▒▒▒' '████████████████████████▒▒▒▒▒▒▒▒' '█████████████████████████▒▒▒▒▒▒▒' '██████████████████████████▒▒▒▒▒▒' '███████████████████████████▒▒▒▒▒' '████████████████████████████▒▒▒▒' '█████████████████████████████▒▒▒' '██████████████████████████████▒▒' '███████████████████████████████▒' '████████████████████████████████')

## UTF-8 animations ##
# Require Unicode support (will work in most modern terminals, but not in TTY).
# Some animations may not render properly with certain fonts.
BLA_classic_utf8=( 0.25 '—' "\\" '|' '/' )
BLA_bounce=( 0.3 . · ˙ · )
BLA_vertical_block=( 0.25 ▁ ▂ ▃ ▄ ▅ ▆ ▇ █ █ ▇ ▆ ▅ ▄ ▃ ▂ ▁ )
BLA_horizontal_block=( 0.25 ▏ ▎ ▍ ▌ ▋ ▊ ▉ ▉ ▊ ▋ ▌ ▍ ▎ ▏ )
BLA_quarter=( 0.25 ▖ ▘ ▝ ▗ )
BLA_triangle=( 0.45 ◢ ◣ ◤ ◥)
BLA_semi_circle=( 0.1 ◐ ◓ ◑ ◒ )
BLA_rotating_eyes=( 0.4 ◡◡ ⊙⊙ ⊙⊙ ◠◠ )
BLA_firework=( 0.4 '⢀' '⠠' '⠐' '⠈' '*' '*' ' ' )
BLA_braille=( 0.2 ⠁ ⠂ ⠄ ⡀ ⢀ ⠠ ⠐ ⠈ )
BLA_braille_whitespace=( 0.2 ⣾ ⣽ ⣻ ⢿ ⡿ ⣟ ⣯ ⣷ )
BLA_trigram=( 0.25 ☰ ☱ ☳ ☶ ☴ )
BLA_arrow=( 0.15 ▹▹▹▹▹ ▸▹▹▹▹ ▹▸▹▹▹ ▹▹▸▹▹ ▹▹▹▸▹ ▹▹▹▹▸ ▹▹▹▹▹ ▹▹▹▹▹ ▹▹▹▹▹ ▹▹▹▹▹ ▹▹▹▹▹ ▹▹▹▹▹ ▹▹▹▹▹ )
BLA_bouncing_ball=( 0.4 '(●     )' '( ●    )' '(  ●   )' '(   ●  )' '(    ● )' '(     ●)' '(    ● )' '(   ●  )' '(  ●   )' '( ●    )' )
BLA_big_dot=( 0.7 ∙∙∙ ●∙∙ ∙●∙ ∙∙● )
BLA_modern_metro=( 0.15 ▰▱▱▱▱▱▱ ▰▰▱▱▱▱▱ ▰▰▰▱▱▱▱ ▱▰▰▰▱▱▱ ▱▱▰▰▰▱▱ ▱▱▱▰▰▰▱ ▱▱▱▱▰▰▰ ▱▱▱▱▱▰▰ ▱▱▱▱▱▱▰ ▱▱▱▱▱▱▱ ▱▱▱▱▱▱▱ ▱▱▱▱▱▱▱ ▱▱▱▱▱▱▱ )
BLA_pong=( 0.35 '▐⠂       ▌' '▐⠈       ▌' '▐ ⠂      ▌' '▐ ⠠      ▌' '▐  ⡀     ▌' '▐  ⠠     ▌' '▐   ⠂    ▌' '▐   ⠈    ▌' '▐    ⠂   ▌' '▐    ⠠   ▌' '▐     ⡀  ▌' '▐     ⠠  ▌' '▐      ⠂ ▌' '▐      ⠈ ▌' '▐       ⠂▌' '▐       ⠠▌' '▐       ⡀▌' '▐      ⠠ ▌' '▐      ⠂ ▌' '▐     ⠈  ▌' '▐     ⠂  ▌' '▐    ⠠   ▌' '▐    ⡀   ▌' '▐   ⠠    ▌' '▐   ⠂    ▌' '▐  ⠈     ▌' '▐  ⠂     ▌' '▐ ⠠      ▌' '▐ ⡀      ▌' '▐⠠       ▌' )
BLA_earth=( 0.45 🌍 🌎 🌏 )
BLA_clock=( 0.2 🕛 🕐 🕑 🕒 🕓 🕔 🕕 🕖 🕗 🕘 🕙 🕚 )
BLA_moon=( 0.8 🌑 🌒 🌓 🌔 🌕 🌖 🌗 🌘 )
BLA_orange_pulse=( 0.35 🔸 🔶 🟠 🟠 🔶 )
BLA_blue_pulse=( 0.35 🔹 🔷 🔵 🔵 🔷 )
BLA_football=( 0.25 ' 👧⚽️       👦' '👧  ⚽️      👦' '👧   ⚽️     👦' '👧    ⚽️    👦' '👧     ⚽️   👦' '👧      ⚽️  👦' '👧       ⚽️👦 ' '👧      ⚽️  👦' '👧     ⚽️   👦' '👧    ⚽️    👦' '👧   ⚽️     👦' '👧  ⚽️      👦' )
BLA_blink=( 0.25 😐 😐 😐 😐 😐 😐 😐 😐 😐 😑 )
BLA_camera=( 0.1 📷 📷 📷 📷 📷 📷 📷 📷 📷 📷 📷 📷 📷 📷 📷 📷 📷 📷 📷 📷 📸 📷 📸 )
BLA_sparkling_camera=( 0.1 '📷 ' '📷 ' '📷 ' '📷 ' '📷 ' '📷 ' '📷 ' '📷 ' '📷 ' '📷 ' '📷 ' '📷 ' '📷 ' '📷 ' '📷 ' '📷 ' '📷 ' '📷 ' '📷 ' '📷 ' '📸✨' '📷 ' '📸✨' )
BLA_sick=( 0.9 🤢 🤢 🤮 )
BLA_monkey=( 0.4 🙉 🙈 🙊 🙈 )
BLA_bomb=( 0.25 '💣   ' ' 💣  ' '  💣 ' '   💣' '   💣' '   💣' '   💣' '   💣' '   💥' '    ' '    ' )

declare -a BLA_active_loading_animation

# @internal
_anim_loop() {
  while true; do
    for frame in "${BLA_active_loading_animation[@]}"; do
      printf -- '\r%s' "${frame}"
      sleep "${BLA_loading_animation_frame_interval}"
    done
  done
}

# @description Start a loading animation in the background.
#   The first element of the animation array is the frame interval in seconds;
#   remaining elements are the animation frames.
#   Call anim_stop when the task completes.
#
# @arg $@ array Elements of a BLA_* animation array (pass with "${BLA_name[@]}")
#
# @example
#   anim_start "${BLA_classic[@]}"
#   do_some_work
#   anim_stop
anim_start() {
  BLA_active_loading_animation=( "${@}" )
  BLA_loading_animation_frame_interval="${BLA_active_loading_animation[0]}"
  unset "BLA_active_loading_animation[0]"
  tput civis
  _anim_loop &
  BLA_loading_animation_pid="${!}"
}

# @description Stop the running loading animation and restore the cursor.
#
# @example
#   anim_stop
anim_stop() {
  kill "${BLA_loading_animation_pid}" &>/dev/null
  printf -- '\n'
  tput cnorm
}
