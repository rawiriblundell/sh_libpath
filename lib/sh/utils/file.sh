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

# Provenance: https://raw.githubusercontent.com/mietek/bashmenot/master/src/file.sh

[ -n "${_SHELLAC_LOADED_utils_file+x}" ] && return 0
_SHELLAC_LOADED_utils_file=1

# @description Generate a unique temporary filename using mktemp -u.
#   Uses BASHMENOT_INTERNAL_TMP as the base directory if set, otherwise /tmp.
#
# @arg $1 string Base name prefix for the temp file (via expect_args)
#
# @stdout Path to the temporary filename (not yet created)
# @exitcode 0 Success
# @exitcode 1 mktemp failed
get_tmp_file () {
	local base
	expect_args base -- "$@"

	local template
	if [[ -z "${BASHMENOT_INTERNAL_TMP:-}" ]]; then
		template="/tmp/${base}.XXXXXXXXXX"
	else
		template="${BASHMENOT_INTERNAL_TMP}/${base}.XXXXXXXXXX"
	fi

	local tmp_file
	if ! tmp_file=$( mktemp -u "${template}" ); then
		log_error 'Failed to create temporary file'
		return 1
	fi

	printf -- '%s\n' "${tmp_file}"
}


# @description Generate a unique temporary directory name using mktemp -du.
#   Uses BASHMENOT_INTERNAL_TMP as the base directory if set, otherwise /tmp.
#
# @arg $1 string Base name prefix for the temp directory (via expect_args)
#
# @stdout Path to the temporary directory name (not yet created)
# @exitcode 0 Success
# @exitcode 1 mktemp failed
get_tmp_dir () {
	local base
	expect_args base -- "$@"

	local template
	if [[ -z "${BASHMENOT_INTERNAL_TMP:-}" ]]; then
		template="/tmp/${base}.XXXXXXXXXX"
	else
		template="${BASHMENOT_INTERNAL_TMP}/${base}.XXXXXXXXXX"
	fi

	local tmp_dir
	if ! tmp_dir=$( mktemp -du "${template}" ); then
		log_error 'Failed to create temporary directory'
		return 1
	fi

	printf -- '%s\n' "${tmp_dir}"
}


# @description Print the disk usage of a file or directory in human-readable form.
#   Normalises K/M/G suffixes to KB/MB/GB.
#
# @arg $1 string Path to file or directory (via expect_args)
#
# @stdout Human-readable size, e.g. "1.2MB"
# @exitcode 0 Success
# @exitcode 1 du failed
get_size () {
	local thing
	expect_args thing -- "$@"

	du -sh "${thing}" |
		awk '{ print $1 }' |
		sed 's/K$/KB/;s/M$/MB/;s/G$/GB/' || return 1
}


case $( uname -s ) in
'Linux')
	# @description Return the modification time of a file as a Unix epoch integer.
	#   Uses 'stat -c %Y' on Linux and 'stat -f %m' on other systems.
	#
	# @arg $1 string File or directory path (via expect_args)
	#
	# @stdout Modification time as epoch seconds
	# @exitcode 0 Success
	# @exitcode 1 stat failed
	get_modification_time () {
		local thing
		expect_args thing -- "$@"

		stat -c "%Y" "${thing}" || return 1
	}
	;;
*)
	get_modification_time () {
		local thing
		expect_args thing -- "$@"

		stat -f "%m" "${thing}" || return 1
	}
esac


# @description Return the absolute physical path of a directory, resolving symlinks.
#
# @arg $1 string Directory path (via expect_args)
#
# @stdout Absolute path with symlinks resolved
# @exitcode 0 Success
# @exitcode 1 Directory does not exist or cd/pwd failed
get_dir_path () {
	local dir
	expect_args dir -- "$@"

	expect_existing "${dir}" || return 1

	( cd "${dir}" && pwd -P ) || return 1
}


# @description Return the final path component (basename) of a directory.
#
# @arg $1 string Directory path (via expect_args)
#
# @stdout Directory name (last component only)
# @exitcode 0 Success
# @exitcode 1 Directory does not exist
get_dir_name () {
	local dir
	expect_args dir -- "$@"

	expect_existing "${dir}" || return 1

	local path
	path=$( get_dir_path "${dir}" ) || return 1

	basename "${path}" || return 1
}


# TODO: Use realpath instead of readlink.
case $( uname -s ) in
'Linux')
	# @description Resolve a symlink to its canonical absolute path.
	#   Uses 'readlink -m' on Linux (resolves even non-existent paths) and
	#   'greadlink -m' on other platforms (requires GNU coreutils).
	#
	# @arg $1 string Symlink path (via expect_args)
	#
	# @stdout Canonical absolute path
	# @exitcode 0 Success
	# @exitcode 1 readlink failed
	get_link_path () {
		local link
		expect_args link -- "$@"

		readlink -m "${link}" || return 1
	}
	;;
*)
	get_link_path () {
		local link
		expect_args link -- "$@"

		greadlink -m "${link}" || return 1
	}
esac


# @description Run find inside a directory and strip the leading './' from results.
#   Returns silently (exit 0) if the directory does not exist.
#   Additional find arguments can be passed after the directory.
#
# @arg $1 string Directory path (via expect_args)
# @arg $2 string Additional arguments passed to find
#
# @stdout Relative file paths, one per line, without leading './'
# @exitcode 0 Always
find_tree () {
	local dir
	expect_args dir -- "$@"
	shift

	if [[ ! -d "${dir}" ]]; then
		return 0
	fi

	( cd "${dir}" && find '.' "$@" 2>'/dev/null' ) |
		sed 's:^\./::' || return 0
}


# @description Find files present in new_dir but not in old_dir.
#
# @arg $1 string Old directory path (via expect_args)
# @arg $2 string New directory path (via expect_args)
# @arg $3 string Additional arguments passed to find
#
# @stdout Relative paths of added files, one per line
# @exitcode 0 Always
find_added () {
	local old_dir new_dir
	expect_args old_dir new_dir -- "$@"
	shift 2

	local new_file
	find "${new_dir}" "$@" -type f -print0 2>'/dev/null' |
		sort0_natural |
		while read -rd $'\0' new_file; do
			local path old_file
			path="${new_file##${new_dir}/}"
			old_file="${old_dir}/${path}"

			if [[ ! -f "${old_file}" ]]; then
				printf -- '%s\n' "${path}"
			fi
		done || return 0
}


# @description Find files that exist in both directories but whose content differs.
#
# @arg $1 string Old directory path (via expect_args)
# @arg $2 string New directory path (via expect_args)
# @arg $3 string Additional arguments passed to find
#
# @stdout Relative paths of changed files, one per line
# @exitcode 0 Always
find_changed () {
	local old_dir new_dir
	expect_args old_dir new_dir -- "$@"
	shift 2

	local new_file
	find "${new_dir}" "$@" -type f -print0 2>'/dev/null' |
		sort0_natural |
		while read -rd $'\0' new_file; do
			local path old_file
			path="${new_file##${new_dir}/}"
			old_file="${old_dir}/${path}"

			if [[ -f "${old_file}" ]] && ! cmp -s "${old_file}" "${new_file}"; then
				printf -- '%s\n' "${path}"
			fi
		done || return 0
}


# @description Find files that exist in both directories with identical content.
#
# @arg $1 string Old directory path (via expect_args)
# @arg $2 string New directory path (via expect_args)
# @arg $3 string Additional arguments passed to find
#
# @stdout Relative paths of unchanged files, one per line
# @exitcode 0 Always
find_not_changed () {
	local old_dir new_dir
	expect_args old_dir new_dir -- "$@"
	shift 2

	local new_file
	find "${new_dir}" "$@" -type f -print0 2>'/dev/null' |
		sort0_natural |
		while read -rd $'\0' new_file; do
			local path old_file
			path="${new_file##${new_dir}/}"
			old_file="${old_dir}/${path}"

			if [[ -f "${old_file}" ]] && cmp -s "${old_file}" "${new_file}"; then
				printf -- '%s\n' "${path}"
			fi
		done || return 0
}


# @description Find files present in old_dir but not in new_dir.
#
# @arg $1 string Old directory path (via expect_args)
# @arg $2 string New directory path (via expect_args)
# @arg $3 string Additional arguments passed to find
#
# @stdout Relative paths of removed files, one per line
# @exitcode 0 Always
find_removed () {
	local old_dir new_dir
	expect_args old_dir new_dir -- "$@"
	shift 2

	local old_file
	find "${old_dir}" "$@" -type f -print0 2>'/dev/null' |
		sort0_natural |
		while read -rd $'\0' old_file; do
			local path new_file
			path="${old_file##${old_dir}/}"
			new_file="${new_dir}/${path}"

			if [[ ! -f "${new_file}" ]]; then
				printf -- '%s\n' "${path}"
			fi
		done || return 0
}


# @description Compare two directory trees and print a diff-style summary of
#   added (+), changed (*), unchanged (=), and removed (-) files.
#
# @arg $1 string Old directory path (via expect_args)
# @arg $2 string New directory path (via expect_args)
# @arg $3 string Additional arguments passed to find
#
# @stdout Lines prefixed with +, *, =, or - followed by the relative file path
# @exitcode 0 Always
compare_tree () {
	local old_dir new_dir
	expect_args old_dir new_dir -- "$@"
	shift 2

	(
		find_added "${old_dir}" "${new_dir}" "$@" | sed 's/^/+ /'
		find_changed "${old_dir}" "${new_dir}" "$@" | sed 's/^/* /'
		find_not_changed "${old_dir}" "${new_dir}" "$@" | sed 's/^/= /'
		find_removed "${old_dir}" "${new_dir}" "$@" | sed 's/^/- /'
	) |
		sort_do -k 2 || return 0
}


# @description Expand a glob pattern within a directory and print matching paths.
#   Runs in a subshell to avoid affecting the caller's IFS or current directory.
#
# @arg $1 string Directory to expand within (via expect_args)
# @arg $2 string Glob pattern to expand (via expect_args)
#
# @stdout Matching paths, one per line
# @exitcode 0 Success
# @exitcode 1 Directory does not exist
expand_glob () {
	local dir glob
	expect_args dir glob -- "$@"

	expect_existing "${dir}" || return 1

	# TODO: Use $'\0' as delimiter.

	(
		local -a files_a
		cd "${dir}" &&
			IFS=$'\n' && files_a=( ${glob} ) &&
			printf -- '%s\n' "${files_a[*]}"
	) || return 1
}


# @description Print the path of the most recently modified file under the
#   current directory. Uses GNU stat -c; not portable to BSD stat.
#
# @stdout Path of the newest file
# @exitcode 0 Always
newest() {
	find . -type f -print0 |
	xargs -0 stat -c "%Y:%n" |
	sort -n |
	tail -n 1 |
	cut -d ':' -f2-
}

#That assume GNU `stat`, switching it up for BSD `stat` isn't hard, and auto-selecting between the two is also a simple exercise, but I'll leave that to the reader.

