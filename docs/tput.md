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

# Detect if our version of 'tput' is so old that it uses termcap syntax
# If this is the case, overlay it so that newer terminfo style syntax works
# Inspired by 'bashlib' and 'liquidprompt'
# For performance we only implement if 'tput ce' (a harmless test) works
if tput ce 2>/dev/null; then
  tput() {
    ctput-null() { command tput "${@}" 2>/dev/null; }
    ctput() { command tput "${@}"; }
    case "${1}" in
      (blink)         ctput-null blink || ctput mb;;
      (bold)          ctput-null bold  || ctput md;;
      (civis)         ctput-null civis || ctput vi;;
      (cnorm)         ctput-null cnorm || ctput ve;;
      (cols)          ctput-null cols  || ctput co;;
      (dim)           ctput-null dim   || ctput mh;;
      (ed)            ctput-null ed    || ctput cd;;
      (el)            ctput-null el    || ctput ce;;
      (el1)           ctput-null el1   || ctput cb;;
      (lines)         ctput-null lines || ctput li;;
      (ritm)          ctput-null ritm  || ctput ZR;;
      (rmcup)         ctput-null rmcup || ctput te;;
      (rmso)          ctput-null rmso  || ctput se;;
      (rmul)          ctput-null rmul  || ctput ue;;
      (setaf)
        case $(uname) in
          (FreeBSD)   ctput AF "${2}";;
          (OpenBSD)   ctput AF "${2}" 0 0;;
          (*)         ctput setaf "${2}";;
        esac
      ;;
      (setab)
        case $(uname) in
          (FreeBSD)   ctput AB "${2}";;
          (OpenBSD)   ctput AB "${2}" 0 0;;
          (*)         ctput setab "${2}";;
        esac
      ;;
      (sgr0)          ctput-null sgr0  || ctput me;;
      (sitm)          ctput-null sitm  || ctput ZH;;
      (smcup)         ctput-null smcup || ctput ti;;
      (smso)          ctput-null smso  || ctput so;;
      (smul)          ctput-null smul  || ctput us;;
      (*)             ctput "${@}";;
    esac
  }
fi
