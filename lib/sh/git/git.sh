# shellcheck shell=bash

# Copyright 2023 Rawiri Blundell
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
# Provenance: https://github.com/rawiriblundell/shellac
# SPDX-License-Identifier: Apache-2.0

[ -n "${_SHELLAC_LOADED_git_git+x}" ] && return 0
_SHELLAC_LOADED_git_git=1

# @description Print the commit date of the most recent commit that touched a file,
#   in epoch seconds followed by a relative date string, for easy sorting.
#
# @arg $1 string File path to query
#
# @example
#   get_newest_commit_date README.md   # => 1710000000 (3 weeks ago)
#
# @stdout Epoch time and relative date, e.g. "1710000000 (3 weeks ago)"
# @exitcode 0 Always
get_newest_commit_date() {
    git --no-pager log -1 --pretty=format:'%ct (%cr)' -- "${1:?No file specified}"
}

# @description Change directory to the top of the current git repository tree,
#   optionally appending a subdirectory path.
#
# @arg $1 string Optional subdirectory path relative to the repo root
#
# @exitcode 0 Success
# @exitcode 1 Not in a git repository or cd failed
gcd() {
  case "$(git rev-parse --show-toplevel 2>&1)" in
    (fatal*) return 1 ;;
    (*)      cd "$(git rev-parse --show-toplevel)/${1}" || return 1 ;;
  esac
}

# @description Delete one or more git branches locally, remotely, or both. With no
#   branch argument, launches an fzf multi-select prompt.
#
# @arg $1 string Optional mode flag: --local (default), --remote, or --both
# @arg $2 string Branch name(s) to delete, or omit to use fzf interactive selection
#
# @exitcode 0 Always (individual git commands may fail silently)
delete_branch() {
  local unwanted_branches current_branch mode
  current_branch="$(git symbolic-ref -q HEAD)"
  current_branch="${current_branch##refs/heads/}"
  current_branch="${current_branch:-HEAD}"

  case "${1}" in
    (--local)  shift 1; mode=local ;;
    (--remote) shift 1; mode=remote ;;
    (--both)   shift 1; mode=both ;;
    (*)        mode=local ;;
  esac

  case "${1}"  in
    ('')
      unwanted_branches=$(
        git branch |
          grep --invert-match '^\*' |
          cut -c 3- |
          fzf --multi --preview="git log {}"
      )
    ;;
    (*)  unwanted_branches="${*}" ;;
  esac

  case "${mode}" in
    (local)
      for branch in ${unwanted_branches}; do
        git branch --delete --force "${branch}"
      done
    ;;
    (remote)
      for branch in ${unwanted_branches}; do
        git push origin --delete "${branch}"
      done
    ;;
    (both)
      for branch in ${unwanted_branches}; do
        git branch --delete --force "${branch}"
        git push origin --delete "${branch}"
      done
    ;;
  esac
}

# Let 'git' take the perf hit of setting GIT_BRANCH rather than PROMPT_COMMAND.
# There's no one true way to get the current git branch; they all have pros/cons.
# See e.g. https://stackoverflow.com/q/6245570
if command -v git >/dev/null 2>&1; then
  # @description Wrapper around the 'git' command that keeps GIT_BRANCH up to date
  #   after every invocation and warns if a command references 'master' when the repo
  #   uses 'main' instead.
  #
  # @arg $1 string Git subcommand and arguments (passed through to git)
  #
  # @exitcode 0 Git command succeeded
  # @exitcode 1 'master' reference detected in a 'main'-only repo
  git() {
    # If the args contain any mention of a master branch, we check for the newer
    # 'main' nomenclature.  We take no other position than to suggest the correct command.
    if [[ "${*}" =~ 'master' ]]; then
      if command git branch 2>/dev/null | grep -qw "main"; then
        printf -- '%s\n' "This repo uses 'main' rather than 'master'." \
          "Try: 'git ${*/master/main}'" \
          "To override this warning, try: 'command git ${*}'" >&2
        return 1
      fi
    fi
    command git "${@}"
    GIT_BRANCH="$(command git branch 2>/dev/null| sed -n '/\* /s///p')"
    export GIT_BRANCH
  }
fi
