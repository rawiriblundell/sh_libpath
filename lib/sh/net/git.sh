# shellcheck shell=ksh

# BSD 3-Clause License

# Copyright (c) 2014-2015, Miëtek Bak
# All rights reserved.

# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:

# * Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.

# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.

# * Neither the name of the copyright holder nor the names of its
#   contributors may be used to endorse or promote products derived from
#   this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# Provenance: https://raw.githubusercontent.com/mietek/bashmenot/master/src/git.sh

validate_git_url () {
	local url
	expect_args url -- "$@"

	case "${url}" in
	'https://'*)	return 0;;
	'ssh://'*)	return 0;;
	'git@'*)	return 0;;
	'file://'*)	return 0;;
	'http://'*)	return 0;;
	'git://'*)	return 0;;
	*)		return 1
	esac
}


git_do () {
	local work_dir cmd
	expect_args work_dir cmd -- "$@"
	shift 2

	expect_existing "${work_dir}" || return 1

	(
		cd "${work_dir}" &&
		git "${cmd}" "$@"
	) || return 1
}


quiet_git_do () {
	local work_dir cmd
	expect_args work_dir cmd -- "$@"
	shift 2

	expect_existing "${work_dir}" || return 1

	git_do "${work_dir}" "${cmd}" "$@" >'/dev/null' 2>&1 || return 1
}


hash_newest_git_commit () {
	local dir
	expect_args dir -- "$@"

	expect_existing "${dir}" || return 1

	local commit_hash
	if ! commit_hash=$( git_do "${dir}" log -n 1 --pretty='format:%h' 2>'/dev/null' ); then
		return 0
	fi

	echo "${commit_hash}"
}


git_clone_over () {
	local url dir
	expect_args url dir -- "$@"

	local work_dir base_url branch
	work_dir=$( dirname "${dir}" ) || return 1
	base_url="${url%#*}"
	branch="${url#*#}"
	if [[ "${branch}" == "${base_url}" ]]; then
		branch='master';
	fi

	rm -rf "${dir}" || return 1
	mkdir -p "${work_dir}" || return 1
	quiet_git_do "${work_dir}" clone "${base_url}" "${dir}" || return 1

	local commit_hash
	commit_hash=$( hash_newest_git_commit "${dir}" ) || return 1
	if [[ -n "${commit_hash}" ]]; then
		quiet_git_do "${dir}" checkout "${branch}" || return 1
		quiet_git_do "${dir}" submodule update --init --recursive || return 1
	fi

	hash_newest_git_commit "${dir}" || return 1
}


git_update_into () {
	local url dir
	expect_args url dir -- "$@"

	expect_existing "${dir}" || return 1

	local base_url branch
	base_url="${url%#*}"
	branch="${url#*#}"
	if [[ "${branch}" == "${base_url}" ]]; then
		branch='master';
	fi

	local old_url
	old_url=$( git_do "${dir}" config --get 'remote.origin.url' ) || return 1
	if [[ "${old_url}" != "${base_url}" ]]; then
		git_do "${dir}" remote set-url 'origin' "${base_url}" || return 1
	fi

	quiet_git_do "${dir}" fetch 'origin' || return 1
	quiet_git_do "${dir}" fetch --tags 'origin' || return 1
	quiet_git_do "${dir}" reset --hard "origin/${branch}" || return 1
	quiet_git_do "${dir}" submodule update --init --recursive || return 1

	hash_newest_git_commit "${dir}" || return 1
}


git_acquire () {
	local src_dir thing dst_dir
	expect_args src_dir thing dst_dir -- "$@"

	local name
	if validate_git_url "${thing}"; then
		name=$( basename "${thing%.git}" ) || return 1

		local commit_hash
		if [[ ! -d "${dst_dir}/${name}" ]]; then
			log_begin "Cloning ${thing}..."

			if ! commit_hash=$( git_clone_over "${thing}" "${dst_dir}/${name}" ); then
				log_end 'error'
				return 1
			fi
		else
			log_begin "Updating ${thing}..."

			if ! commit_hash=$( git_update_into "${thing}" "${dst_dir}/${name}" ); then
				log_end 'error'
				return 1
			fi
		fi
		log_end "done, ${commit_hash}"
	else
		name=$( get_dir_name "${src_dir}/${thing}" ) || return 1

		copy_dir_over "${src_dir}/${thing}" "${dst_dir}/${name}" || return 1
	fi

	echo "${name}"
}


git_acquire_all () {
	local src_dir things dst_dir
	expect_args src_dir things dst_dir -- "$@"

	if [[ -z "${things}" ]]; then
		return 0
	fi

	local -a names_a
	local thing
	names_a=()
	while read -r thing; do
		local name
		name=$( git_acquire "${src_dir}" "${thing}" "${dst_dir}" ) || return 1
		names_a+=( "${name}" )
	done <<<"${things}"

	IFS=$'\n' && echo "${names_a[*]}"
}

################################################################################

get_newest_commit_date() {
    # Output in epoch time for easy sorting, followed by relative date
    git --no-pager log -1 --pretty=format:'%ct (%cr)' -- "${1:?No file specified}"
}

# Go to the top of our git tree
gcd() {
  case "$(git rev-parse --show-toplevel 2>&1)" in
    (fatal*) return 1 ;;
    (*)      cd "$(git rev-parse --show-toplevel)/${1}" || return 1 ;;
  esac
}

delete-branch() {
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

# Let 'git' take the perf hit of setting GIT_BRANCH rather than PROMPT_COMMAND
# There's no one true way to get the current git branch, they all have pros/cons
# See e.g. https://stackoverflow.com/q/6245570
if command -v git >/dev/null 2>&1; then
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
