# FUNCTION_NAME

## Description

## Synopsis

## Options

## Examples

## Output
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

# Number of physical processors [int]
# /sys and physical_package_id files proved to be unreliable, don't use those options
get_cpu_slots() {
  if command -v lscpu >/dev/null 2>&1; then
    cpuPhysCount=$(lscpu | awk 'BEGIN{IGNORECASE=1} /Socket\(s\):/{print $2; exit}')
  # Next we try dmidecode
  elif dmidecode --type processor | grep -q "Status: Populated, Enabled"; then
    cpuPhysCount=$(dmidecode --type processor | grep -c "Status: Populated, Enabled")
  # Otherwise, we try to figure it out from /proc/cpuinfo
  elif grep -q "^physical id.*:" /proc/cpuinfo; then
    cpuPhysCount=$(grep "^physical id.*:" /proc/cpuinfo | uniq | wc -l)
  # Finally, default it to 1
  else
    printInf "Could not determine physical CPU count, defaulting to '1'"
    cpuPhysCount=1
  fi
}

# Number of cores per socket [int]
# /sys and core_id proved to be unreliable, don't use those options
get_cpu_cores() {
  if command -v lscpu >/dev/null 2>&1; then
    cpuCoreCount=$(lscpu | awk '/^Core\(s\) per socket:/{print $4}')
  # Otherwise, we try dmidecode
  elif dmidecode --type processor 2>/dev/null | grep -q "Core Count"; then
    cpuCoreCount=$(dmidecode --type processor | awk '/Core Count/{print $3; exit}')
  # Otherwise, we try to figure it out from /proc/cpuinfo
  # Alternative: $(grep -c "core id" /proc/cpuinfo | uniq | wc -l)
  elif grep -q "cpu cores" /proc/cpuinfo; then
    cpuCoreCount=$(awk '/cpu cores/{print $4; exit}' /proc/cpuinfo)
  # It's possible that /proc/cpuinfo might not have that detail, so we try another angle
  elif grep -q "^core id.*:" /proc/cpuinfo; then
    cpuCoreCount=$(grep "^core id.*:" /proc/cpuinfo | sort | uniq | wc -l)
  # If we really can't figure it out, default it to 1
  else
    printInf "Could not determine CPU core count, defaulting to '1'"
    cpuCoreCount=1
  fi
  # We use dmidecode to test enabled cores - this is a Sybase licensing curveball!
  if dmidecode --type processor 2>/dev/null | grep -q "Core Enabled"; then
    cpuCoreEnabled=$(dmidecode --type processor | awk '/Core Enabled/{print $3; exit}')
  fi
  # One last adjustment for the core count
  if [[ -n ${cpuCoreEnabled} ]]; then
    cpuCoreCount="${cpuCoreCount} (${cpuCoreEnabled} enabled)"
  fi
}

# Number of threads per core [int]
get_cpu_threads() {
  # First we try lscpu
  if command -v lscpu  >/dev/null 2>&1 && lscpu 2>/dev/null | grep -q "^Thread(s) per core"; then
    cpuThreadCount=$(lscpu | awk '/^Thread\(s\) per core:/{print $4}')
  # Next we try to calculate using /proc/cpuinfo
  # First we see if Threads per core info is available
  elif grep -q "Thread(s) per core:" /proc/cpuinfo; then
    cpuThreadCount=$(awk '/Thread\(s\) per core:/{print $4; exit}' /proc/cpuinfo)
  # In older versions of /proc/cpuinfo, that info isn't actually available
  # So we try to calculate it using the "siblings" information
  # see: http://linuxhunt.blogspot.co.nz/2010/03/understanding-proccpuinfo.html
  elif grep -q "siblings" /proc/cpuinfo; then
    # Grab the number of siblings from /proc/cpuinfo
    siblingCount=$(awk '/siblings/{print $3; exit}' /proc/cpuinfo)

    # If siblings is greater than cpuCoreCount, then we've got multiple threads
    # Divide the number of siblings by the number of cores to get the threads-per-core
    if (( siblingCount > cpuCoreCount )); then
      cpuThreadCount=$(( siblingCount / cpuCoreCount ))
    # Otherwise we don't have multiple threads and we default to 1
    elif (( siblingCount <= cpuCoreCount )); then
      cpuThreadCount=1
    fi
  # Now we're getting desperate, let's try to count the thread mapping
  elif [[ -f /sys/devices/system/cpu/cpu0/topology/thread_siblings ]]; then
    siblingCount=$(awk -F ',' '{printf NF; exit}' /sys/devices/system/cpu/cpu0/topology/thread_siblings)
    if (( siblingCount > cpuCoreCount )); then
      cpuThreadCount=$(( siblingCount / cpuCoreCount ))
    elif (( siblingCount <= cpuCoreCount )); then
      cpuThreadCount=1
    fi
  # Finally, fail back to 1
  else
    printInf "Could not determine CPU thread count, defaulting to '1'"
    cpuThreadCount=1
  fi
}

# Total vCPU's i.e. slots x cores x threads [int]
get_cpu_count() {
  cpuTotal=$(( cpuPhysCount * cpuCoreCount * cpuThreadCount ))
}

# CPU speed in MHz [int]
# We assume this is the same across multiple CPU's, so we just grab the first result
get_cpu_mhz() {
  if command -v lscpu >/dev/null 2>&1 && lscpu 2>/dev/null | grep -q "^CPU MHz"; then
    cpuMhz=$(lscpu | grep "^CPU MHz" | awk '{print $3}' | cut -d "." -f1)
  elif [[ -f "/sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq" ]]; then
    cpuMhz=$(</sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq)
    cpuMhz=$(( cpuMhz / 1000 ))
  # Otherwise, we try to figure it out from the Model Number in /proc/cpuinfo
  # We ignore the 'cpu MHz' line as this shows a realtime value i.e. proc scaling
  else
    cpuMhz=$(awk '/^model name/{print $NF; exit}' /proc/cpuinfo)
    scale=$(sed -e 's/^[0-9\.]*//g' <<< "${cpuMhz}")
    value=$(sed -e 's/[A-Za-z]*$//g' <<< "${cpuMhz}")
    # If we have a GHz value, we convert it to MHz like so:
    if [[ "$scale" = "GHz" ]]; then
      cpuMhz=$(awk -v cpughz="${value}" 'BEGIN{print cpughz * 1000}' | sed -e 's/\.[0-9]*$//')
    fi
  fi
}

# CPU Manufacturer [str]
# We assume this is the same across multiple CPU's, so we just grab the first result
get_cpu_manufacturer() {
  if [ -r /proc/cpuinfo ]; then
    awk -F ':' '/^vendor_id/{print $2; exit}' /proc/cpuinfo | trim
  fi
}

# CPU Model [str]
# We assume this is the same across multiple CPU's, so we just grab the first result
get_cpu_model() {
  if [ -r /proc/cpuinfo ]; then
    awk -F ':' '/^model name/{print $2; exit}' /proc/cpuinfo | trim
  fi
}

get_cpu() {
  case "${1}" in
    (slots)           get_cpu_slots ;;
    (cores)           get_cpu_cores ;;
    (threads)         get_cpu_threads ;;
    (count)           get_cpu_count ;;
    (mhz)             get_cpu_mhz ;;
    (manufacturer)    get_cpu_manufacturer ;;
    (model)           get_cpu_model ;;
    (*)
      printf -- '%s\n' "$(get_cpu_manufacturer) $(get_cpu_model) $(get_cpu_mhz) (x$(get_cpu_count))"
    ;;
  esac 
}
