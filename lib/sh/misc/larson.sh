Your problem is that size can't really be done, *emphasis* is the closest text manipulation to what you're after.  I mean I *get*, conceptually, what you're trying to emulate (three bouncing dots that you've seen on plenty of mobile apps, right?) but the terminal by its very nature won't allow what you want.  Not without a LOT of work.

Try something like this:

    for em in dim sgr0 bold sgr0 dim sgr0 bold sgr0 dim sgr0; do
      tput "${em}"
      printf -- '%s' '*'
    done | paste -sd '' -

If you're happy with the emphasis differences shown, then we can work with that. 

I think you might have an easier time with a classic spinning wheel (I have code for that ready to go), or maybe something like a moving pipe symbol (think `--|----`, or `*|**`), or using a foreground/background colour combination via `tput` (e.g.: a green square cursor moving around)

   
Ok, OP, you piqued my interest.  Here's my half-hearted attempt at it... I call it a "half-Larson", because it works its way left to right then starts at the left-most point again.  If it went left to right, then right to left, that would be a full Larson.  Named for the guy who developed the effect for the Cylons in Battlestar Galactica and KITT in Knight Rider.

    #!/bin/bash
    
    progWidth="${1:-3}"
    sleepTime="0.2"
    
    resetTerm() {
      tput sgr0     # Unset as many things that we've set as possible
      tput cnorm    # Display the cursor again
      printf '%s\n' ""
      exit 0
    }
    
    # Try to set things back the way they were, however we exit
    trap resetTerm HUP INT QUIT TERM EXIT
    
    # GNU sleep can handle fractional seconds, non-GNU cannot
    # so we default to 1 second resolution in that scenario
    if ! sleep "${sleepTime}" &amp;&gt;/dev/null; then
      sleepTime=1
    fi
    
    tput sc                                    # Capture position
    tput civis                                 # Hide cursor
    tput dim                                   # Set base emphasis
    printf '%*s' "${progWidth}" | tr ' ' "*"   # Setup base char width
    while true; do                             # Infinite loop
      tput rc                                  # Return to saved position
      for ((i=0;i&lt;progWidth;i++)); do          # Iterate horizontally
        for em in dim sgr0 bold sgr0 dim; do   # Emphasis sequence
          printf -- '%s' "$(tput "${em}")*"    # Output emphasised char
          sleep "${sleepTime}"                 # Pause for effect
          tput cub1                            # Move left one char
        done
        tput cuf1                              # Move right one char
      done
    done
    
A 0.1s sleepTime looks good too.

/edit: Full Larson... kinda...  same as before but with an extra loop:

    while true; do                             # Infinite loop
      tput rc                                  # Return to saved position
      for ((i=0;i&lt;progWidth;i++)); do          # Iterate horizontally
        for em in dim sgr0 bold sgr0 dim; do   # Emphasis sequence
          printf -- '%s' "$(tput "${em}")*"    # Output emphasised char
          sleep "${sleepTime}"                 # Pause for effect
          tput cub1                            # Move left one char
        done
        tput cuf1                              # Move right one char
      done
      tput cub1
      for ((i=progWidth;i&gt;0;i--)); do
        for em in dim sgr0 bold sgr0 dim; do
          printf -- '%s' "$(tput "${em}")*"
          sleep "${sleepTime}"
          tput cub1
        done
        tput cub1
      done
    done
