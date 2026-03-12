#!/usr/bin/env bash

[ -n "${_SH_LOADED_goodies_bash_loading_animations+x}" ] && return 0
_SH_LOADED_goodies_bash_loading_animations=1

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
#%% Add the code between this box and its twin to the top of your script %%#
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#

### List of available loading animations
## You can safely remove the lines of the animations you don't want to use
## The first value of an array is the interval (in seconds) between each frame

# ASCII - The following animations will work in any terminal, including TTY:
classic=( 0.25 '-' '\' '|' '/' )
box=( 0.2 ┤ ┴ ├ ┬ )
bubble=( 0.6 · o O O o · )
breathe=( 0.9 '  ()  ' ' (  ) ' '(    )' ' (  ) ' )
growing_dots=( 0.5 '.  ' '.. ' '...' '.. ' '.  ' '   ' )
passing_dots=( 0.25 '.  ' '.. ' ' ..' '  .' '   ' )
metro=( 0.2 '[    ]' '[=   ]' '[==  ]' '[=== ]' '[ ===]' '[  ==]' '[   =]' )

# UTF-8 - The following animations require a terminal that supports Unicode (most modern terminals do), they will NOT work in TTY:
classic_utf8=( 0.25 '—' '\' '|' '/' )
bounce=( 0.3 . · ˙ · )
vertical_block=( 0.25 ▁ ▂ ▃ ▄ ▅ ▆ ▇ █ █ ▇ ▆ ▅ ▄ ▃ ▁ )
horizontal_block=( 0.25 ▏ ▎ ▍ ▌ ▋ ▊ ▉ ▉ ▊ ▋ ▌ ▍ ▎ ▏ )
quarter=( 0.25 ▖ ▘ ▝ ▗ )
triangle=( 0.45 ◢ ◣ ◤ ◥)
semi_circle=( 0.1 ◐ ◓ ◑ ◒ )
rotating_eyes=( 0.4 ◡◡ ⊙⊙ ⊙⊙ ◠◠ )
firework=( 0.4 '⢀' '⠠' '⠐' '⠈' '*' '*' ' ' )
braille=( 0.2 ⠁ ⠂ ⠄ ⡀ ⢀ ⠠ ⠐ ⠈ )
braille_whitespace=( 0.2 ⣾ ⣽ ⣻ ⢿ ⡿ ⣟ ⣯ ⣷ )
trigram=( 0.25 ☰ ☱ ☳ ☶ ☴ )
arrow=( 0.15 ▹▹▹▹▹ ▸▹▹▹▹ ▹▸▹▹▹ ▹▹▸▹▹ ▹▹▹▸▹ ▹▹▹▹▸ ▹▹▹▹▹ ▹▹▹▹▹ ▹▹▹▹▹ ▹▹▹▹▹ ▹▹▹▹▹ ▹▹▹▹▹ ▹▹▹▹▹ )
bouncing_ball=( 0.4 '( ●    )' '(  ●   )' '(   ●  )' '(    ● )' '(     ●)' '(    ● )' '(   ●  )' '(  ●   )' '( ●    )' '(●     )' )
big_dot=( 0.7 ∙∙∙ ●∙∙ ∙●∙ ∙∙● )
modern_metro=( 0.15 ▰▱▱▱▱▱▱ ▰▰▱▱▱▱▱ ▰▰▰▱▱▱▱ ▱▰▰▰▱▱▱ ▱▱▰▰▰▱▱ ▱▱▱▰▰▰▱ ▱▱▱▱▰▰▰ ▱▱▱▱▱▰▰ ▱▱▱▱▱▱▰ ▱▱▱▱▱▱▱ ▱▱▱▱▱▱▱ ▱▱▱▱▱▱▱ ▱▱▱▱▱▱▱ )
pong=( 0.35 '▐⠂       ▌' '▐⠈       ▌' '▐ ⠂      ▌' '▐ ⠠      ▌' '▐  ⡀     ▌' '▐  ⠠     ▌' '▐   ⠂    ▌' '▐   ⠈    ▌' '▐    ⠂   ▌' '▐    ⠠   ▌' '▐     ⡀  ▌' '▐     ⠠  ▌' '▐      ⠂ ▌' '▐      ⠈ ▌' '▐       ⠂▌' '▐       ⠠▌' '▐       ⡀▌' '▐      ⠠ ▌' '▐      ⠂ ▌' '▐     ⠈  ▌' '▐     ⠂  ▌' '▐    ⠠   ▌' '▐    ⡀   ▌' '▐   ⠠    ▌' '▐   ⠂    ▌' '▐  ⠈     ▌' '▐  ⠂     ▌' '▐ ⠠      ▌' '▐ ⡀      ▌' '▐⠠       ▌' )
earth=( 0.45 🌍 🌎 🌏 )
clock=( 0.2 🕛 🕐 🕑 🕒 🕓 🕔 🕕 🕖 🕗 🕘 🕙 🕚 )
moon=( 0.8 🌑 🌒 🌓 🌔 🌕 🌖 🌗 🌘 )
orange_pulse=( 0.35 🔸 🔶 🟠 🟠 🔶 )
blue_pulse=( 0.35 🔹 🔷 🔵 🔵 🔷 )
football=( 0.25 ' 🧑⚽️       🧑' '🧑  ⚽️      🧑' '🧑   ⚽️     🧑' '🧑    ⚽️    🧑' '🧑     ⚽️   🧑' '🧑      ⚽️  🧑' '🧑       ⚽️🧑 ' '🧑      ⚽️  🧑' '🧑     ⚽️   🧑' '🧑    ⚽️    🧑' '🧑   ⚽️     🧑' '🧑  ⚽️      🧑' )
blink=( 0.25 😐 😐 😐 😐 😐 😐 😐 😐 😐 😑 )
sick=( 0.9 🤢 🤢 🤮 )
monkey=( 0.4 🙉 🙈 🙊 🙈 )
bomb=( 0.25 '💣   ' ' 💣  ' '  💣 ' '   💣' '   💣' '   💣' '   💣' '   💣' '   💥' '    ' '    ' )

####################################################
### Edit the line below to choose your animation ###
####################################################
active_loading_animation=("${classic[@]}")
####################################################
### Edit the line above to choose your animation ###
####################################################

# Extract the delay between each frame from the active_loading_animation array
loading_animation_frame_interval="${active_loading_animation[0]}"
unset "active_loading_animation[0]"

# Stop the animation and restore the normal cursor if the script is interrupted
trap stop_loading_animation SIGINT

loading_animation() {
  tput civis
  while true ; do
    for frame in "${active_loading_animation[@]}" ; do
      printf "\r%s" "${frame}"
      sleep "${loading_animation_frame_interval}"
    done
  done
}

start_loading_animation() {
  loading_animation &
  loading_animation_id="${!}"
}

stop_loading_animation() {
  kill "${loading_animation_id}" &> /dev/null
  printf "\n"
  tput cnorm
}

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
#%% Add the code between this box and its twin to the top of your script %%#
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#

# Demo the loading animation
start_loading_animation
sleep 10
stop_loading_animation
exit 0

##############
### How-to ###
##############

# Use the chosen loading animation this way:
start_loading_animation
your_command_here
stop_loading_animation

# If your command prints some output in the terminal, it will mess with the loading animation.
# To hide all output, do the following:
your_command_here &> /dev/null
# To hide error messages only, do the following:
your_command_here 2> /dev/null
# To hide standard output only, do the following:
your_command_here 1> /dev/null


####################
### COMPACT MODE ###
####################
active_loading_animation=("${classic[@]}") ; loading_animation_frame_interval="${active_loading_animation[0]}" ; unset "active_loading_animation[0]" ; trap stop_loading_animation SIGINT
loading_animation() { tput civis ; while true ; do for frame in "${active_loading_animation[@]}" ; do printf "\r%s" "${frame}" ; sleep "${loading_animation_frame_interval}" ; done ; done ; }
start_loading_animation() { loading_animation & loading_animation_id="${!}" ; }
stop_loading_animation() { kill "${loading_animation_id}" &> /dev/null ; printf "\n" ; tput cnorm ; }


##########################
### ULTRA-COMPACT MODE ###
##########################
active_loading_animation=("${classic[@]}") ; loading_animation_frame_interval="${active_loading_animation[0]}" ; unset "active_loading_animation[0]" ; trap stop_loading_animation SIGINT ; loading_animation() { tput civis ; while true ; do for frame in "${active_loading_animation[@]}" ; do printf "\r%s" "${frame}" ; sleep "${loading_animation_frame_interval}" ; done ; done ; } ; start_loading_animation() { loading_animation & loading_animation_id="${!}" ; } ; stop_loading_animation() { kill "${loading_animation_id}" &> /dev/null ; printf "\n" ; tput cnorm ; }
