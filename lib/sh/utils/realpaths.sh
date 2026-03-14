#!/usr/bin/env bash
# CC0 1.0 Universal
# Provenance: https://raw.githubusercontent.com/bashup/realpaths/master/realpaths

[ -n "${_SH_LOADED_utils_realpaths+x}" ] && return 0
_SH_LOADED_utils_realpaths=1

# @description Resolve symlinks and return the parent directory of the target.
#   Result is written to the global REPLY variable, not stdout.
# @arg $1 string Path to resolve
realpath.location(){ realpath.follow "$1"; realpath.absolute "$REPLY" ".."; }
# @description Resolve symlinks and return the resulting absolute path.
#   Result is written to the global REPLY variable, not stdout.
# @arg $1 string Path to resolve
realpath.resolved(){ realpath.follow "$1"; realpath.absolute "$REPLY"; }
# @description Return the directory component of a path. Result is written to REPLY.
# @arg $1 string Path to process
realpath.dirname() { REPLY=.; ! [[ $1 =~ /+[^/]+/*$|^//$ ]] || REPLY="${1%${BASH_REMATCH[0]}}"; REPLY=${REPLY:-/}; }
# @description Return the filename component of a path. Result is written to REPLY.
# @arg $1 string Path to process
realpath.basename(){ REPLY=/; ! [[ $1 =~ /*([^/]+)/*$ ]] || REPLY="${BASH_REMATCH[1]}"; }

# @description Resolve all symlinks in a path without resolving path components.
#   Detects symlink loops and stops. Result is written to REPLY.
# @arg $1 string Path to follow
realpath.follow() {
	local target
	while [[ -L "$1" ]] && target=$(readlink -- "$1"); do
		realpath.dirname "$1"
		# Resolve relative to symlink's directory
		[[ $REPLY != . && $target != /* ]] && REPLY=$REPLY/$target || REPLY=$target
		# Break out if we found a symlink loop
		for target; do [[ $REPLY == "$target" ]] && break 2; done
		# Add to the loop-detect list and tail-recurse
		set -- "$REPLY" "$@"
	done
	REPLY="$1"
}

# @description Compute an absolute path by resolving path components against PWD.
#   Handles ., .., double-slash, and root. Result is written to REPLY.
# @arg $1 string Path component(s) to resolve
realpath.absolute() {
	REPLY=$PWD; local eg=extglob; ! shopt -q $eg || eg=; ${eg:+shopt -s $eg}
	while (($#)); do case $1 in
		//|//[^/]*) REPLY=//; set -- "${1:2}" "${@:2}" ;;
		/*) REPLY=/; set -- "${1##+(/)}" "${@:2}" ;;
		*/*) set -- "${1%%/*}" "${1##${1%%/*}+(/)}" "${@:2}" ;;
		''|.) shift ;;
		..) realpath.dirname "$REPLY"; shift ;;
		*) REPLY="${REPLY%/}/$1"; shift ;;
	esac; done; ${eg:+shopt -u $eg}
}

# @description Recursively canonicalise a path: resolve symlinks and normalise
#   all path components. Result is written to REPLY.
# @arg $1 string Path to canonicalise
realpath.canonical() {
	realpath.follow "$1"; set -- "$REPLY"   # $1 is now resolved
	realpath.basename "$1"; set -- "$1" "$REPLY"   # $2 = basename $1
	realpath.dirname "$1"
	[[ $REPLY != "$1" ]] && realpath.canonical "$REPLY"; # recurse unless root
	realpath.absolute "$REPLY" "$2";   # combine canon parent w/basename
}

# @description Compute the relative path from a base directory to a target path.
#   Defaults to PWD as the base if not given. Result is written to REPLY.
# @arg $1 string Target path
# @arg $2 string Optional: base directory (default: PWD)
realpath.relative() {
	local target=""
	realpath.absolute "$1"; set -- "$REPLY" "${@:2}"; realpath.absolute "${2-$PWD}" X
	while realpath.dirname "$REPLY"; [[ "$1" != "$REPLY" && "$1" == "${1#${REPLY%/}/}" ]]; do
		target=../$target
	done
	[[ $1 == "$REPLY" ]] && REPLY=${target%/} || REPLY="$target${1#${REPLY%/}/}"
	REPLY=${REPLY:-.}
}
