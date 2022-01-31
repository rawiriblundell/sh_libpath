# shellcheck shell=ksh

# Portable version of 'readlink -f' for versions that don't have '-f'

requires readlink

readlink_f() {
  (
    _count=0
    _target="${1:?No target specified}"
    # Ensure that a customised CDPATH doesn't interfere
    CDPATH=''

    # Ensure that target actually exists and is actually a symlink
    [ -e "${_target}" ] || return 1
    [ -L "${_target}" ] || return 1

    while [ -L "${_target}" ]; do
      _target="$(readlink "${_target}")"
      _count=$(( _count + 1 ))
      # This shouldn't be required, but just in case,
      # we ensure that we don't get stuck in an infinite loop
      if [ "${_count}" -gt 20 ]; then
        printf -- '%s\n' "readlink_f error: recursion limit reached" >&2
        return 1
      fi
    done
    cd "$(dirname "${_target}")" >/dev/null 2>&1 || return 1
    printf -- '%s\n' "${PWD%/}/${_target##*/}"
  )
}

