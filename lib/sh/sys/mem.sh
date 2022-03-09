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

  # Start by checking for 'top'
  if iscommand top; then
    printMdSubHead "Memory information from 'top'"
    top -n 1 -b | grep -E "Mem|Swap"
    printMdTags
  else
    printInf "'top' was not found on this host"
  fi

  # Pad the output
  printBlankLine

  # Now try to cull the info from /proc
  if [[ -f /proc/meminfo ]]; then
    printMdSubHead "Memory information from '/proc'"
    grep -E "MemTotal|SwapTotal" /proc/meminfo 2>/dev/null
    printMdTags
  else
    printInf "'/proc/meminfo' was not found on this host"
  fi

  # Pad the output
  printBlankLine

  # And finally try to cull more info from 'free'
  if iscommand free; then
    printMdSubHead "Memory information from 'free'"
    free -l 2>/dev/null || printErr "no output from 'free -l'"
    printMdTags
  else
    printInf "'free' was not found on this host"
  fi

# Output all captured output
} > "${dcgBaseData}/info_mem"

# Physical Memory.  'dmidecode' is the gold standard here
if dmidecode -t 17 2>/dev/null | nullgrep "Size.*MB"; then
  hwMemory=$(dmidecode -t 17 | awk '/Size.*MB/{ s+=$2 } END { print s "MB" }')
# If we're on a VM, sometimes dmidecode won't give us the detail we need
else
  # Firstly, /proc/meminfo does not correctly report the physical memory size
  # This affects methods like 'free' and 'vmstat' etc that depend on /proc/meminfo
  # The best alternative to dmidecode we have at the moment is the DirectMap
  # entries in /proc/meminfo.  It seems that adding them gives us the physical
  # memory amount in kB, we can then simply divide to our desired scale
  # Nb: Not guaranteed to be exact!  Just closer than /proc/meminfo's MemTotal line.
  if nullgrep "^DirectMap" /proc/meminfo; then
    hwMemory=$(awk '/DirectMap/{ s+=$2 } END { printf("%0.fMB\n", s/1024) }' /proc/meminfo)
  # Otherwise we accept /proc/meminfo's inaccuracy.
  # 'free -h' seems to choose a sane point to switch from KB to MB to GB
  elif free -h >/dev/null 2>&1; then
    hwMemory=$(printf '%s\n' "$(free -h | awk '/Mem:/{print $2}')B")
  # If not, output to Megabytes
  else
    hwMemory=$(printf '%s\n' "$(free -m | awk '/Mem:/{print $2}')MB")
  fi
fi

# Total Memory
# I began approaching this from the view that "total memory" meant
# physical memory + swap.  A look at the Altiris data feed seemed to say that
# total memory = physical memory.  What's the point of this field then?
totalMemory="${hwMemory}"

# Otherwise, we might use something like:
#  totalMemory=$(egrep 'MemTotal|SwapTotal' /proc/meminfo | awk '{ s+=$2 } END { tot = s /1024/ 1024; printf "%.0fGB\n", tot}')

