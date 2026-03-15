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

# Provenance: https://raw.githubusercontent.com/mietek/bashmenot/master/src/hash.sh

[ -n "${_SHELLAC_LOADED_utils_hash+x}" ] && return 0
_SHELLAC_LOADED_utils_hash=1

# @description Compute a SHA1 hash of stdin content.
#   Returns silently (exit 0) if stdin is empty.
#
# @stdout SHA1 hex digest of the input
# @exitcode 0 Success or empty input
# @exitcode 1 openssl command failed
get_hash () {
	local input
	input=$( cat ) || true

	if [[ -z "${input}" ]]; then
		return 0
	fi

	openssl sha1 <<<"${input}" |
		sed 's/^.* //' || return 1
}


# @description Compute a single SHA1 hash representing the contents of all files
#   in a directory tree. Returns silently (exit 0) if the directory does not exist.
#   Additional find arguments can be passed after the directory.
#
# @arg $1 string Directory path to hash (via expect_args)
# @arg $2 string Additional arguments passed to find
#
# @stdout SHA1 hex digest of the sorted concatenation of all file hashes
# @exitcode 0 Success or directory not found
# @exitcode 1 Hashing failed
hash_tree () {
	local dir
	expect_args dir -- "$@"
	shift

	if [[ ! -d "${dir}" ]]; then
		return 0
	fi

	(
		cd "${dir}" &&
		find '.' "$@" -type f -exec openssl sha1 '{}' ';' 2>'/dev/null'
	) |
		sort_natural |
		get_hash || return 1
}
