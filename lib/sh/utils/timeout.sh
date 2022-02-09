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

# Check if 'timeout' is available, if not, enable a stop-gap function
if ! get_command timeout; then
  timeout() {
    local duration

    # $# should be at least 1, if not, print a usage message
    if (( $# == 0 )); then
      printf -- '%s\n' "Usage:  timeout DURATION COMMAND" ""
      printf -- '\t%s\n' \
        "Start COMMAND, and kill it if still running after DURATION." "" \
        "DURATION is an integer with an optional suffix:" \
        "  's'  for seconds (the default)" \
        "  'm' for minutes" \
        "  'h' for hours" \
        "  'd' for days" "" \
        "Note: This is a bash function that mimics the command 'timeout'"
      return 0
    fi
    
    # Is $1 good?  If so, sanitise and convert to seconds
    case "${1}" in
      (*[!0-9smhd]*|'')
        printf -- '%s\n' \
          "timeout: '${1}' is not valid.  Run 'timeout' for usage." >&2
        return 1
      ;;
      (*m)
        duration="${1//[!0-9]/}"; duration=$(( duration * 60 ))
      ;;
      (*h)
        duration="${1//[!0-9]/}"; duration=$(( duration * 60 * 60 ))
      ;;
      (*d)
        duration="${1//[!0-9]/}"; duration=$(( duration * 60 * 60 * 24 ))
      ;;
      (*)
        duration="${1//[!0-9]/}"
      ;;
    esac
    # shift so that the rest of the line is the command to execute
    shift

    # If 'perl' is available, it has a few pretty good one-line options
    # see: http://stackoverflow.com/q/601543
    if get_command perl; then
      perl -e '$s = shift; $SIG{ALRM} = sub { kill INT => $p; exit 77 }; exec(@ARGV) unless $p = fork; alarm $s; waitpid $p, 0; exit ($? >> 8)' "${duration}" "$@"
      #perl -MPOSIX -e '$SIG{ALRM} = sub { kill(SIGTERM, -$$); }; alarm shift; $exit = system @ARGV; exit(WIFEXITED($exit) ? WEXITSTATUS($exit) : WTERMSIG($exit));' "$@"

    # Otherwise we offer a shell based failover.
    # I tested a few, this one works nicely and is fairly simple
    # http://stackoverflow.com/a/24413646
    else
      # Run in a subshell to avoid job control messages
      ( "$@" &
        child=$! # Grab the PID of the COMMAND
        
        # Avoid default notification in non-interactive shell for SIGTERM
        trap -- "" SIGTERM
        ( sleep "${duration}"
          kill "${child}" 
        ) 2> /dev/null &
        
        wait "${child}"
      )
    fi
  }
fi
