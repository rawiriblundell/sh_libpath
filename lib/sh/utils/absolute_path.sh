# shellcheck shell=ksh

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
        printf -- '%s\n' "${PWD:-$(pwd)}/${_filename##*/}"
      )
    else
      printf -- '%s\n' "${PWD:-$(pwd)}/${_filename}"
    fi
  fi
  unset -v _filename
}

