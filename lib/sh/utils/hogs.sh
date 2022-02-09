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

swaphogs() {
  {
    for file in /proc/*/status ; do
      awk '/VmSwap|Name/{printf $2 " " $3}END{ print ""}' "${file}" 2>/dev/null
    done
  } | grep " kB$" | sort -k 2 -n | column -t
}

# Function to display a list of users and their memory and cpu usage
# Non-portable swap: for file in /proc/*/status ; do awk '/VmSwap|Name/{printf $2 " " $3}END{ print ""}' $file; done | sort -k 2 -n -r
what() {
  case "${1}" in
    (-h|--help)
      printf -- '%s\n' "what - list all users and their memory/cpu usage (think 'who' and 'what')" \
        "Usage: what [-c (sort by cpu usage) -m (sort by memory usage)]"
    ;;
    (-c)
      ps -eo pcpu,vsz,user | 
        tail -n +2 | 
        awk '{ cpu[$3]+=$1; vsz[$3]+=$2 } END { for (user in cpu) printf("%-10s - Memory: %10.1f KiB, CPU: %4.1f%\n", user, vsz[user]/1024, cpu[user]); }' | 
        sort -k7 -rn
    ;;
    (-m)
      ps -eo pcpu,vsz,user | 
        tail -n +2 | 
        awk '{ cpu[$3]+=$1; vsz[$3]+=$2 } END { for (user in cpu) printf("%-10s - Memory: %10.1f KiB, CPU: %4.1f%\n", user, vsz[user]/1024, cpu[user]); }' | 
        sort -k4 -rn
    ;;
    ('')
      ps -eo pcpu,vsz,user |
        tail -n +2 | 
        awk '{ cpu[$3]+=$1; vsz[$3]+=$2 } END { for (user in cpu) printf("%-10s - Memory: %10.1f KiB, CPU: %4.1f%\n", user, vsz[user]/1024, cpu[user]); }'
    ;;
  esac
}
