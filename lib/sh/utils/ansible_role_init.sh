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

# TODO: Overlay 'ansible' command i.e. 'ansible init [rolename]' or something to that effect

# Create the file structure for an Ansible role
rolesetup() {
  if [[ -z "${1}" ]]; then
    printf -- '%s\n' "rolesetup - setup the file structure for an Ansible role." \
      "By default this creates into the current directory" \
      "and you can recursively copy the structure from there." "" \
      "Usage: rolesetup rolename" ""
    return 1
  fi

  if [[ ! -w . ]]; then
    printf -- '%s\n' "Unable to write to the current directory"
    return 1
  elif [[ -d "${1}" ]]; then
    printf -- '%s\n' "The directory '${1}' seems to already exist!"
    return 1
  else
    mkdir -p "${1}"/{defaults,files,handlers,meta,templates,tasks,vars}
    (
      cd "${1}" || return 1
      for dir in defaults files handlers meta templates tasks vars; do
        printf -- '%s\n' "---" > "${dir}/main.yml"
      done
    )
  fi
}
