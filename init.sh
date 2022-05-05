# shellcheck shell=ksh

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

# Start up SH_STACK
SH_STACK=()
sh_stack_add() {
  _sh_stack_depth='=>'
  case "${1}" in
    (-[0-9]*)
      _sh_stack_i=1
      while (( _sh_stack_i < "${1/-/}" )); do
        _sh_stack_depth="${_sh_stack_depth}>"
        _sh_stack_i=$(( _sh_stack_i + 1 ))
      done
      shift 1
    ;;
  esac
  SH_STACK=( "${SH_STACK[@]}" "$(date +%Y%m%d_%H:%M:%S_%Z): ${_sh_stack_depth} ${*}" )
  unset -v _sh_stack_depth _sh_stack_i
}
sh_stack_add "START"

# Potential basepaths for where our libraries might be placed
# TO-DO: Expand and include $FPATH (ksh, z/OS) and/or $fpath (zsh)
POSSIBLE_SH_LIBPATHS=(
  "${HOME}"/git/sh_libpath/lib/sh
  "${HOME}"/.local/lib/sh
  /usr/local/lib/sh
  /opt/sh_libpath/lib/sh
  /usr/share/misc
)

# we dynamically build SH_LIBPATH
unset -v SH_LIBPATH
for _path in "${POSSIBLE_SH_LIBPATHS[@]}"; do
  sh_stack_add "SH_LIBPATH: checking if ${_path} exists..."
  [ -d "${_path}" ] && SH_LIBPATH="${SH_LIBPATH}:${_path}"
done
unset -v _path
# Remove any leading colons from the construction process and export
SH_LIBPATH="${SH_LIBPATH#:}"
export SH_LIBPATH

# Check the length of the var again and fail out if it's empty
if (( "${#SH_LIBPATH}" == 0 )); then
  printf -- '%s\n' "SH_LIBPATH appears to be empty" >&2
  exit 1
fi

sh_stack_add "SH_LIBPATH: ${SH_LIBPATH}"

# Function to work through a list of commands and/or files
# and fail on any unmet requirements.  Example usage:
# requires curl sed awk /etc/someconf.cfg
requires() {
  for _item in "${@}"; do
    # First, is this a variable check?
    # There has to be a cleaner/safer way to do this
    case "${_item}" in
      (*=*)
        _key="${_item%%=*}" # Everything left of the first '='
        _val="${_item#*=}"  # Everything right of the first '='
        eval [ \$"${_key}" = "${_val}" ] && continue
      ;;
      (BASH*)
        # Shell version check e.g. 'requires BASH32' = we check for bash 3.2 or newer
        # To strictly require a specific version, you could use the keyval test above
        # TO-DO: Expand the "is greater than" logic, add extra shells
        if [ "${#BASH_VERSINFO[@]}" -gt 0 ]; then
          _bashver="${BASH_VERSINFO[*]:0:2}" # Get major and minor number e.g. '4 3'
          _bashver="BASH${_bashver/ /}"       # Concat and remove spaces e.g. 'BASH43'
          # Test on string (e.g. BASH44 = BASH44)
          [ "${1}" = "${_bashver}" ] && continue
          # Test on integer by stripping "BASH" (e.g. 51 -ge 44)
          [ "${1/BASH/}" -ge "${_bashver/BASH/}" ] && continue
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
      (root)
        [ "${EUID:-$(id -u)}" -eq "0" ] && continue
      ;;
    esac
    
    # Next, try to determine if it's a command
    command -v "${_item}" >/dev/null 2>&1 && continue

    # Next, see if it's an executable file e.g. a script to call
    [ -x ./"${_item}" ] && continue

    # Next, let's see if it's a library in SH_LIBPATH
    for _target_lib in ${SH_LIBPATH//://$_item }/${_item}; do
      [ -r "${_target_lib}" ] && continue
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
    unset -v _item _failures _target_lib _bashver
    return 0
  # Otherwise, we error out and exit immediately
  else
    printf -- '%s\n' "The following requirements were not met:" "${_failures}" >&2
    unset -v _item _failures _target_lib _bashver
    exit 1
  fi
}

# Sometimes you might want to load a file only if it exists,
# but otherwise it's not critical and your script can move on.
wants() {
  _fstarget="${1:?No target specified}"
  [ -e "${_fstarget}" ] || return

  if [ -r "${_fstarget}" ]; then
    # shellcheck disable=SC1090
    . "${_fstarget}" || { printf -- 'wants: %s\n' "Failed to load '${_fstarget}'"; exit 1; }
    unset -v _fstarget
  else
    printf -- 'wants: %s\n' "${_fstarget} exists but isn't readable" >&2
    unset -v _fstarget
    return 1
  fi
}

_is_function_loaded() {
  typeset -f "${1:?No function defined}" >/dev/null
}

_is_lib_loaded() {
  _is_lib_loaded_target="${1:?No library defined}"
  if [ "${SH_LIBS_LOADED#*"$_is_lib_loaded_target"}" != "${SH_LIBS_LOADED}" ]; then
    unset -v _is_lib_loaded_target
    return 0
  else
    unset -v _is_lib_loaded_target
    return 1
  fi
}

# Usage:   import dir/library.sh
# Or:      import library.sh from dir
# Example: import text/puts.sh
#          import puts.sh from text
#  The second form also supports the keyword 'all' e.g. 'import all from dir'
import() {
  sh_stack_add -2 "Entering 'import()' and processing args: '${*}'"
  # Ensure that SH_LIBPATH has some substance, otherwise why bother?
  if (( "${#SH_LIBPATH}" == 0 )); then
    printf -- 'import: %s\n' "SH_LIBPATH appears to be empty" >&2
    exit 1
  fi

  sh_stack_add -3 "Processing case statement for ${#} arg(s).  Correct: 1, or 3."
  case "${#}" in
    (1)
      case "${1}" in
        (*/*)   _target_lib="${1}" ;;
        (*)
          printf -- 'import: %s\n' "Usage: import dir/library.sh / import library.sh from dir" >&2
          unset -v _target _target_lib
          printf -- '%s\n' "" "${SH_STACK[@]}"
          [ -t 0 ] && return 1
          exit 1
        ;;
      esac

      # Ensure that it's not already loaded
      _is_lib_loaded "${_target_lib}" && return 0

      # Test if the _target_lib is readable
      # This indicates to us that the given library is likely a full path e.g.
      # import /opt/something/specific/library.sh
      if [ -r "${_target_lib}" ]; then
        sh_stack_add -4 "Full path given: ${_target_lib}"
        # shellcheck disable=SC1090
        . "${_target_lib}" || { printf -- 'import: %s\n' "Failed to load '${_target_lib}'" >&2; exit 1; }
        # Add the library to SH_LIBS_LOADED
        SH_LIBS_LOADED="${SH_LIBS_LOADED} ${_target_lib}"
        # Strip the leading space char
        SH_LIBS_LOADED="${SH_LIBS_LOADED# }"
        export SH_LIBS_LOADED
        unset -v _target_lib
        return 0
      elif [ -e "${_target_lib}" ]; then
        printf -- 'import: %s\n' "Insufficient permissions while importing '${_target_lib}'" >&2
      fi

      # This expands SH_LIBPATH and appends the target to each path member e.g.
      # for _target in /usr/local/lib/sh/arrays.sh "${HOME}"/.local/lib/sh/arrays.sh; do
      for _target_lib in ${SH_LIBPATH//://$_target_lib }/${_target_lib}; do
        if [ -r "${_target_lib}" ]; then
          # shellcheck disable=SC1090
          . "${_target_lib}" || { printf -- 'import: %s\n' "Failed to load '${_target_lib}'" >&2; exit 1; }
          SH_LIBS_LOADED="${SH_LIBS_LOADED} ${_target_lib}"
          SH_LIBS_LOADED="${SH_LIBS_LOADED# }"
          unset -v _target _target_lib
          return 0
        elif [ -e "${_target_lib}" ]; then
          printf -- 'import: %s\n' "Insufficient permissions while importing '${_target_lib}'" >&2
          unset -v _target _target_lib
          printf -- '%s\n' "" "${SH_STACK[@]}"
          [ -t 0 ] && return 1
          exit 1
        fi
      done

      # If we're here, then 'import()' wasn't called correctly
      printf -- 'import: %s\n' "Unspecified error while executing 'import ${*}'" >&2
      printf -- '%s\n' "" "${SH_STACK[@]}"
      [ -t 0 ] && return 1
      exit 1
    ;;
    (3)
      # Ensure our args are as desired - in count and structure
      if ! [ "${2}" = "from" ]; then
        printf -- 'import: %s\n' "Incorrect usage of 'import'" >&2
        printf -- '%s\n' "" "${SH_STACK[@]}"
        [ -t 0 ] && return 1
        exit 1
      fi
      _function="${1}"
      _subdir="${3}"

      case "${_function}" in
        (all)
          sh_stack_add -4 "case > 3 > all"
          # Get first found match of subdir in SH_LIBPATH
          for _target_lib in ${SH_LIBPATH//://$_subdir }/${_subdir}; do
            if [ -d "${_target_lib}" ]; then
              _subdir_path="${_target_lib}"
              break
            fi
          done

          # If we can't find it, fail out
          if [ "${_subdir_path+x}" = "x" ] || [ "${#_subdir_path}" -eq "0" ]; then
            printf -- 'import: %s\n' "'${_subdir}' not found in SH_LIBPATH" >&2
            printf -- '%s\n' "" "${SH_STACK[@]}"
            [ -t 0 ] && return 1
            exit 1
          fi

          : "Loading all functions from ${_subdir_path}"
          for _target_lib in "${_subdir_path}"/*; do
            # Ensure that it's not already loaded
            _is_lib_loaded "${_subdir_path}/${_target_lib}" && continue
            if [ -r "${_subdir_path}/${_target_lib}" ]; then
              # shellcheck disable=SC1090
              . "${_subdir_path}/${_target_lib}" || {
                printf -- 'import: %s\n' "Failed to load '${_target_lib}' from ${_subdir_path}" >&2
                printf -- '%s\n' "" "${SH_STACK[@]}"
                [ -t 0 ] && return 1
                exit 1
              }
              SH_LIBS_LOADED="${SH_LIBS_LOADED} ${_target_lib}"
              SH_LIBS_LOADED="${SH_LIBS_LOADED# }"
              unset -v _target _target_lib
            elif [ -e "${_target_lib}" ]; then
              printf -- 'import: %s\n' "Insufficient permissions while importing '${_target_lib}'" >&2
              printf -- '%s\n' "" "${SH_STACK[@]}"
              unset -v _target _target_lib
              [ -t 0 ] && return 1
              exit 1
            fi
          done
          export SH_LIBS_LOADED
          unset -v _subdir _function _subdir_path _target_lib
          return 0
        ;;
        (*)
          sh_stack_add -4 "case > 3 > '*'"
          _target_lib="${_subdir}/${_function}"
          
          # Ensure that it's not already loaded
          _is_lib_loaded "${_target_lib}" && return 0
          for _target_lib in ${SH_LIBPATH//://$_target_lib }/${_target_lib}; do
            if [ -r "${_target_lib}" ]; then
              # shellcheck disable=SC1090
              . "${_target_lib}" || { printf -- 'import: %s\n' "Failed to load '${_target_lib}'" >&2; exit 1; }
              SH_LIBS_LOADED="${SH_LIBS_LOADED} ${_target_lib}"
              SH_LIBS_LOADED="${SH_LIBS_LOADED# }"
              export SH_LIBS_LOADED
              unset -v _target _target_lib
              return 0
            elif [ -e "${_target_lib}" ]; then
              printf -- 'import: %s\n' "Insufficient permissions while importing '${_target_lib}'" >&2
              printf -- '%s\n' "" "${SH_STACK[@]}"
              unset -v _target _target_lib
              [ -t 0 ] && return 1
              exit 1
            fi
          done
        ;;
      esac

      # If we get to this point, then the library wasn't loaded for some reason
      printf -- 'import: %s\n' "Unspecified error while importing '${_function}' from '${_subdir}'" >&2
      printf -- '%s\n' "" "${SH_STACK[@]}"
      unset -v _subdir _function _subdir_path _target_lib
      [ -t 0 ] && return 1
      exit 1
    ;;
    (*)
      # If we're here, then 'import()' wasn't called correctly
      printf -- 'import: %s\n' "Unspecified error while executing 'import ${*}'" >&2
      printf -- '%s\n' "" "${SH_STACK[@]}"
      [ -t 0 ] && return 1
      exit 1
    ;;
  esac
}
