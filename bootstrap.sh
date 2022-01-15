# shellcheck shell=ksh
# If SH_LIBPATH is not set or null, then we try to build it
if [ -z "${SH_LIBPATH+x}" ] || [ "${#SH_LIBPATH}" -eq "0" ]; then
  for _path in /usr/local/lib/sh "${HOME}"/.local/lib/sh; do
    [ -d "${_path}" ] && SH_LIBPATH="${SH_LIBPATH}:${_path}"
  done
fi
unset -v _path
# Remove any leading colons from the construction process and export
SH_LIBPATH="${SH_LIBPATH#:}"
export SH_LIBPATH

_is_lib_loaded() {
  _lib="${1:?No library defined}"
  [ -z "${SH_LIBS_LOADED##*"$_lib"*}" ] && [ -n "${SH_LIBS_LOADED}" ]
  unset -v _lib
}

# Try to convert a relative path to an absolute one
# A slightly adjusted version sourced from
# https://stackoverflow.com/a/21188136
get_absolute_path() {
  _filename="${1}"
  _parentdir=$(dirname "${_filename}")

  # We only act further if the file actually exists
  [ -e "${_filename}" ] || return 1
  if [ -d "${_filename}" ]; then
    printf -- '%s\n' "$(cd "${_filename}" && pwd)"
  elif [ -d "${_parentdir}" ]; then
    printf -- '%s\n' "$(cd "${_parentdir}" && pwd)/$(basename "${_filename}")"
  fi
  unset -v _filename _parentdir
}

# Function to work through a list of commands and/or files
# and fail on any unmet requirements.  Example usage:
# requires curl sed awk /etc/someconf.cfg
requires() {
  # shellcheck disable=SC2048
  for _item in ${*}; do
    # First, is this a variable check?
    # There has to be a cleaner/safer way to do this
    case "${1}" in
      (*=*)
        _key="${_item%%=*}" # Everything left of the first '='
        _val="${_item#*=}"  # Everything right of the first '='
        eval [ \$"${_key}" = "${_val}" ] && continue
      ;;  
    esac
    
    # Next, try to determine if it's a command
    command -v "${_item}" >/dev/null 2>&1 && continue

    # Next, see if it's an executable file e.g. a script to call
    [ -x ./"${_item}" ] && continue

    # Next, let's see if it's a library in SH_LIBPATH
    for _lib in ${SH_LIBPATH//://$_item }/${_item}; do
      [ -r "${_lib}" ] && continue
    done

    # Next, let's see if it's a readable file e.g. a cfg file to load
    [ -r "${_item}" ] && continue

    # If we get to this point, add it to our list of failures
    _failures="${_failures} ${_item}"
  done
  # Strip any leading space from the construction of _failures
  _failures="${_failures# }"

  # If we have no failures, then no news is good news - return quietly
  if [ "${#_failures}" -eq "0" ]; then
    unset -v _item _failures _lib
    return 0
  # Otherwise, we error out and exit immediately
  else
    printf -- '%s\n' "The following requirements were not met" "${_failures}" >&2
    unset -v _item _failures _lib
    exit 1
  fi
}

# We want SH_LIBPATH to be expanded for printf
# shellcheck disable=SC2086
import() {
  _target="${1:?No target specified}"

  # If it's already loaded, then skip
  #_is_lib_loaded "${target}" && return 0

  for _lib in ${SH_LIBPATH//://$_target }/${_target}; do
    if [ -r "${_lib}" ]; then
      # shellcheck disable=SC1090
      . "${_lib}"
      SH_LIBS_LOADED="${SH_LIBS_LOADED} ${_lib}"
      unset -v _target _lib
      return 0
    fi
  done
  unset -v _target _lib
  return 1
}

# Sometimes you might want to load a file only if it exists,
# but otherwise it's not critical and your script can move on.
wants() {
  _fstarget="${1:?No target specified}"
  if [ -e "${_fstarget}" ]; then
    if [ -r "${_fstarget}" ]; then
      # shellcheck disable=SC1090
      . "${_fstarget}"
      unset -v _fstarget
    else
      printf -- '%s\n' "${_fstarget} exists but isn't readable" >&2
      unset -v _fstarget
      return 1
    fi
  fi
}