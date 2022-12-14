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

# Provide a function to compress common compressed Filetypes
compress() {
  File=$1
  shift
  case "${File}" in
    (*.tar.bz2) tar cjf "${File}" "$@"  ;;
    (*.tar.gz)  tar czf "${File}" "$@"  ;;
    (*.tgz)     tar czf "${File}" "$@"  ;;
    (*.zip)     zip "${File}" "$@"      ;;
    (*.rar)     rar "${File}" "$@"      ;;
    (*)         echo "Filetype not recognized" ;;
  esac
}

# Function to extract common compressed file types
# TODO: Check for atool and defer to it where possible...
extract() {
  local xcmd rc fsobj

  (($#)) || return
  rc=0
  for fsobj; do
    xcmd=''

    if [[ ! -r ${fsobj} ]]; then
      printf -- '%s\n' "$0: file is unreadable: '${fsobj}'" >&2
      continue
    fi

    [[ -e ./"${fsobj#/}" ]] && fsobj="./${fsobj#/}"

    case ${fsobj} in
      (*.cbt|*.t@(gz|lz|xz|b@(2|z?(2))|a@(z|r?(.@(Z|bz?(2)|gz|lzma|xz)))))
        xcmd=(bsdtar xvf)
      ;;
      (*.7z*|*.arj|*.cab|*.chm|*.deb|*.dmg|*.iso|*.lzh|*.msi|*.rpm|*.udf|*.wim|*.xar)
        xcmd=(7z x)
      ;;
      (*.ace|*.cba)         xcmd=(unace x) ;;
      (*.cbr|*.rar)         xcmd=(unrar x) ;;
      (*.cbz|*.epub|*.zip)  xcmd=(unzip) ;;
      (*.cpio) cpio -id < "${fsobj}"; rc=$(( rc + "${?}" )); continue ;;
      (*.cso)
        ciso 0 "${fsobj}" "${fsobj}".iso; extract "${fsobj}".iso
        rm -rf "${fsobj:?}"; rc=$(( rc + "${?}" ))
        continue
      ;;
      (*.arc)   xcmd=(arc e);;
      (*.bz2)   xcmd=(bunzip2);;
      (*.exe)   xcmd=(cabextract);;
      (*.gz)    xcmd=(gunzip);;
      (*.lzma)  xcmd=(unlzma);;
      (*.xz)    xcmd=(unxz);;
      (*.Z|*.z) xcmd=(uncompress);;
      (*.zpaq)  xcmd=(zpaq x);;
      (*)
        printf -- '%s\n' "$0: unrecognized file extension: '${fsobj}'" >&2
        continue
      ;;
    esac

    command "${xcmd[@]}" "${fsobj}"
    rc=$(( rc + "${?}" ))
  done
  (( rc > 0 )) && return "${rc}"
  return 0
}
