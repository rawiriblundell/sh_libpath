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
# https://stackoverflow.com/a/23002317
get_absolute_path() {
  _filename="${1:?No filename specified}"
  # Ensure that a customised CDPATH doesn't interfere
  CDPATH=''

  # We only act further if the file actually exists
  [ -e "${_filename}" ] || return 1

  # If it's a directory, print it
  if [ -d "${_filename}" ]; then
    (cd "${_filename}" && pwd)
  elif [ -f "${_filename}" ]; then
    if [[ "${_filename}" = /* ]]; then
      printf -- '%s\n' "${_filename}"
    elif [[ "${_filename}" == */* ]]; then
      (
        cd "${_filename%/*}" >/dev/null 2>&1 || return 1
        printf -- '%s\n' "$(pwd)/${_filename##*/}"
      )
    else
      printf -- '%s\n' "$(pwd)/${_filename}"
    fi
  fi
  unset -v _filename
}

# Portable version of 'readlink -f'
# To be pushed out to another library at some point
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

# Make getting a string length a bit more familiar for practitioners of other languages
# To be pushed out to another library at some point
# Is not used at all in this library - it's like putting the egg before the chicken
# ... or is it the chicken before the egg?  Damn!
strlen() {
  case "${1}" in
    (-b|--bytes)
      shift 1
      LANG_orig="${LANG}"; LC_ALL_orig="${LC_ALL}"
      LANG=C; LC_ALL=C; 
      str="${*}"
      printf -- '%d\n' "${#str}"
      LANG="${LANG_orig}"; LC_ALL="${LC_ALL_orig}"
    ;;
    ('')
      printf -- '%d\n' "0"
    ;;
    (*)
      str="${*}"
      printf -- '%d\n' "${#str}"
    ;;
  esac
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

    # Shell version check e.g. 'requires BASH32' = we check for bash 3.2 or newer
    # To strictly require a specific version, you could use the keyval test above
    # TO-DO: Expand the "is greater than" logic, add extra shells
    case "${1}" in
      (BASH*)
        if [ "${#BASH_VERSINFO[@]}" -gt 0 ]; then
          bashver="${BASH_VERSINFO[*]:0:2}" # Get major and minor number e.g. '4 3'
          bashver="BASH${bashver/ /}"       # Concat and remove spaces e.g. 'BASH43'
          # Test on string (e.g. BASH44 = BASH44)
          [ "${1}" = "${bashver}" ] && continue
          # Test on integer by stripping "BASH" (e.g. 51 -ge 44)
          [ "${1/BASH/}" -ge "${bashver/BASH/}" ] && continue
        fi
      ;;
      (KSH)
        # At present we just check that we have one of the following env vars
        [ "${#KSH_VERSION}" -gt 0 ] && continue
        [ "${#.sh.version}" -gt 0 ] && continue
      ;;
      (ZSH*)
        if [ "${#ZSH_VERSION}" -gt 0 ]; then
          # ZSH_VERSION outputs a semantic number e.g. 5.7.1
          # We use parameter expansion to pull out the dots e.g. ZSH571
          # We do a string, then an int comparison just as with bash
          [ "${1}" = "ZSH${ZSH_VERSION//./}" ] && continue
          [ "${1/ZSH/}" -ge "${ZSH_VERSION//./}" ] && continue
        fi
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
  # TO-DO: test, further develop
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
