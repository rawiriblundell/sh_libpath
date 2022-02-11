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

debug_trap_err() {
  set -o errtrace
  trap 'err_handler ${?}' ERR
}

debug_err_handler() {
  trap - ERR
  i=0
  printf -- '%s\n' "Aborting on error ${1}:" \
    "--------------------" >&2
  while caller $i; do
    ((i++))
  done
  exit "${?}"
}

debug() {

}

# As above but with a pause 
step() {

}

case "${1}" in
  (-d|--debug)
    set -xv
    export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
    readonly debug_mode=true
    trap 'set +x' EXIT
  ;;
esac

# shellcheck disable=SC2183
debug() {
  [[ "${debug_mode}" != "true" ]] && return 0
  : [DEBUG] "${*}"
  : ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  read -n 1 -s -r -p "Press any key to continue"
}

echo a
debug breakpoint one
echo b
debug breakpoint two

---

breakpoint(){
    local REPLY
    echo 'Breakpoint hit. [opaAxXq]'
    while read -r -k1; do case $REPLY in
        o) shopt -s; set -o ;;   # list options
        p) declare -p | less ;;  # list parameters
        a) declare -a ;;
        A) declare -A ;;
        x) set -x ;;             # toggle xtrace
        X) set +x ;;
        q) return ;;             # quit
    esac; done
}
