# shellcheck shell=bash

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

[ -n "${_SHELLAC_LOADED_path_path+x}" ] && return 0
_SHELLAC_LOADED_path_path=1

# @description Test whether a path exists (any type).
#
# @arg $1 string Path to test
#
# @exitcode 0 Path exists
# @exitcode 1 Path does not exist
path_exists() {
    [ -e "${1:-$RANDOM}" ] >/dev/null 2>&1
}

# @description Test whether a path is a regular file.
#
# @arg $1 string Path to test
#
# @exitcode 0 Path is a regular file
# @exitcode 1 Path is not a regular file
path_is_file() {
    [ -f "${1:-$RANDOM}" ] >/dev/null 2>&1
}

# @description Test whether a path is a directory.
#
# @arg $1 string Path to test
#
# @exitcode 0 Path is a directory
# @exitcode 1 Path is not a directory
path_is_directory() {
    [ -d "${1:-$RANDOM}" ] >/dev/null 2>&1
}

# TODO: path_is_hardlink()
# @description Test whether a path is a symbolic link.
#
# @arg $1 string Path to test
#
# @exitcode 0 Path is a symlink
# @exitcode 1 Path is not a symlink
path_is_symlink() {
    [ -L "${1:-$RANDOM}" ] >/dev/null 2>&1
}

# @description Test whether a path is readable by the current process.
#
# @arg $1 string Path to test
#
# @exitcode 0 Path is readable
# @exitcode 1 Path is not readable
path_is_readable() {
    [ -r "${1:-$RANDOM}" ] >/dev/null 2>&1
}

# @description Test whether a path is writeable by the current process.
#
# @arg $1 string Path to test
#
# @exitcode 0 Path is writeable
# @exitcode 1 Path is not writeable
path_is_writeable() {
    [ -w "${1:-$RANDOM}" ] >/dev/null 2>&1
}

# @description Test whether a path is executable by the current process.
#
# @arg $1 string Path to test
#
# @exitcode 0 Path is executable
# @exitcode 1 Path is not executable
path_is_executable() {
    [ -x "${1:-$RANDOM}" ] >/dev/null 2>&1
}

# @description Test whether a path is absolute (starts with /).
#
# @arg $1 string Path to test
#
# @exitcode 0 Path is absolute
# @exitcode 1 Path is not absolute
path_is_absolute() {
    case "${1:-}" in
        (/*) return 0 ;;
        (*)  return 1 ;;
    esac
}

# @description Test whether a path is relative (does not start with /).
#
# @arg $1 string Path to test
#
# @exitcode 0 Path is relative
# @exitcode 1 Path is not relative
path_is_relative() {
    case "${1:-}" in
        (/*) return 1 ;;
        (*)  return 0 ;;
    esac
}

# @description Test whether a path is a directory that contains no files.
#
# @arg $1 string Path to test
#
# @exitcode 0 Path is an empty directory
# @exitcode 1 Path is not an empty directory or does not exist
path_is_empty_dir() {
    [ -d "${1:-$RANDOM}" ] || return 1
    [ -z "$(find "${1}" -maxdepth 0 -empty 2>/dev/null)" ] && return 1
    return 0
}

# @description Test whether a path is inside a git repository.
#   Defaults to the current directory if no path is given.
#
# @arg $1 string Path to test (default: current directory)
#
# @exitcode 0 Path is inside a git repository
# @exitcode 1 Path is not inside a git repository
path_is_gitdir() {
    local _path
    _path="${1:-.}"
    [ -e "${_path}/.git" ] && return 0
    git -C "${_path}" rev-parse --git-dir >/dev/null 2>&1
}
