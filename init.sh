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

sh_stack_dump() {
  printf -- '%s\n' "" "${SH_STACK[@]}"
  [ -t 0 ] && return 1
}

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
        if [ "${#BASH_VERSION}" -gt 0 ]; then
          _bashver="${BASH_VERSION%${BASH_VERSION#???}}" # Get first three chars e.g. '4.3'
          _bashver="BASH${_bashver/./}"                  # Concat and remove dot e.g. 'BASH43'
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

# Usage examples:
# import /opt/company/libs/sh/library.sh
#   Attempts to source a library from a given full path
# import text/puts
#   Attempts to locate and source the library "puts.sh" within SH_LIBPATH
# import text/puts.bash
#   Attempts to locate and source the library "puts.bash" within SH_LIBPATH
# import units
#   Attempts to locate the subdir 'units' within SH_LIBPATH and sources all the libraries within it
import() {
  sh_stack_add -2 "Entering 'import()' and processing args: '${*}'"

  # Ensure that SH_LIBPATH has some substance, otherwise why bother?
  sh_stack_add -3 "SH_LIBPATH at this point: ${SH_LIBPATH}"
  if (( "${#SH_LIBPATH}" == 0 )); then
    sh_stack_dump
    printf -- 'import: %s\n' "SH_LIBPATH appears to be empty" >&2
    exit 1
  fi

  # Ensure that we have an arg to parse
  sh_stack_add -3 "Count of args found: ${#}"
  if (( "${#}" == 0 )); then
    sh_stack_dump
    printf -- 'import: %s\n' "No args given" >&2
    exit 1
  fi

  # Assign our target to a var
  _import_target="${1}"

  # Ensure that it's not already loaded
  # TO-DO: Add option to import() to ignore this test and (forcibly?) reload
  _is_lib_loaded "${_import_target}" && return 0

  # Is it a direct path to a readable file?  Load it.
  # Example: import /opt/something/specific/library.sh
  if [ -r "${_import_target}" ]; then
    sh_stack_add -4 "Full path given to readable file: ${_import_target}"
    # shellcheck disable=SC1090
    if . "${_import_target}"; then
      # Add the library to SH_LIBS_LOADED
      SH_LIBS_LOADED="${SH_LIBS_LOADED} ${_import_target}"
      # Strip the leading space char
      SH_LIBS_LOADED="${SH_LIBS_LOADED# }"
      export SH_LIBS_LOADED
      unset -v _import_target
      return 0
    else
      sh_stack_dump
      printf -- 'import: %s\n' "Failed to load '${_import_target}'" >&2
      unset -v _import_target
      exit 1
    fi
  elif [ -e "${_import_target}" ]; then
    sh_stack_add -4 "Full path given to unreadable file: ${_import_target}"
    sh_stack_dump
    printf -- 'import: %s\n' "Insufficient permissions while importing '${_import_target}'" >&2
    unset -v _import_target
    exit 1
  fi

  # With the above scenario out of the way, we now assess the following in order:
  # import subdir/library.extension (e.g. import text/tolower.sh)
  #     This scenario allows us to load shell specific libs e.g. text/tolower.zsh
  # import subdir/library           (e.g. import text/tolower)
  #     This scenario defaults to the .sh extension i.e. text/tolower = text/tolower.sh
  # import subdir                   (e.g. import text
  #     This scenario loads all libraries within a subdir
  case "${_import_target}" in
    (*/*.*)
      # Is it a specific library in the format path/library.extension?
<<<<<<< HEAD
      _subdir_path="${_import_target%%/*}"
      _import_target="${_import_target#*/}"
=======
      #_subdir_path="${_import_target%%/*}"
      #_import_target="${_import_target#*/}"
      #_extension="${_import_target#*.}"
>>>>>>> 830cbab... Add validate_cert.sh

      # If these two are the same, then we don't have an extension.  Default to .sh
      if [ "${_import_target}" = "${_import_target#*.}" ]; then
        _extension="sh"
      # Otherwise, extract the extension
      else
        _extension="${_import_target#*.}"
      fi

      # Check that the subdir exists in SH_LIBPATH, if not, fail out
      # Get first found match of subdir in SH_LIBPATH
      for _import_subdir in ${SH_LIBPATH//://$_subdir_path }/${_subdir_path}; do
        if [ -d "${_import_subdir}" ]; then
          _subdir_path="${_import_target}"
          break
        fi
        # TODO: Fail out here
      done

      # We've validated all of the input components, so re-assemble them
      _import_target="${_subdir_path}/${_import_target}.${_extension}"
      
      # This expands SH_LIBPATH and appends the target to each path member e.g.
      # for _target in /usr/local/lib/sh/arrays.sh "${HOME}"/.local/lib/sh/arrays.sh; do
      for _import_target in ${SH_LIBPATH//://$_import_target }/${_import_target}; do
        if [ -r "${_import_target}" ]; then
          # shellcheck disable=SC1090
          . "${_import_target}" || {
            printf -- 'import: %s\n' "Failed to load '${_import_target}'" >&2
            exit 1
          }
          SH_LIBS_LOADED="${SH_LIBS_LOADED} ${_import_target}"
          SH_LIBS_LOADED="${SH_LIBS_LOADED# }"
          unset -v _target _import_target
          return 0
        elif [ -e "${_import_target}" ]; then
          sh_stack_dump
          printf -- 'import: %s\n' "Insufficient permissions while importing '${_import_target}'" >&2
          unset -v _target _import_target
          exit 1
        fi
      done
    ;;
    (*)
      # Is it a path within SH_LIBPATH?  Load everything within that path.
      # Note: we only load everything with a .sh extension
      # We don't want to try loading library.zsh into bash, for example
      _subdir_path="${_import_target}"

      sh_stack_add -4 "case > 3 > all"
      # Get first found match of subdir in SH_LIBPATH
      for _import_target in ${SH_LIBPATH//://$_subdir }/${_subdir}; do
        if [ -d "${_import_target}" ]; then
          _subdir_path="${_import_target}"
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

      sh_stack_add -4 "Loading all functions from ${_subdir_path}"
      for _import_target in "${_subdir_path}"/*; do
        # Ensure that it's not already loaded
        _is_lib_loaded "${_subdir_path}/${_import_target}" && continue
        if [ -r "${_subdir_path}/${_import_target}" ]; then
          # shellcheck disable=SC1090
          . "${_subdir_path}/${_import_target}" || {
            sh_stack_dump
            printf -- 'import: %s\n' "Failed to load '${_import_target}' from ${_subdir_path}" >&2
            unset -v _target _import_target
            exit 1
          }
          SH_LIBS_LOADED="${SH_LIBS_LOADED} ${_import_target}"
          SH_LIBS_LOADED="${SH_LIBS_LOADED# }"
          unset -v _target _import_target
        elif [ -e "${_import_target}" ]; then
          sh_stack_dump
          printf -- 'import: %s\n' "Insufficient permissions while importing '${_import_target}'" >&2
          unset -v _target _import_target
          exit 1
        fi
      done
      export SH_LIBS_LOADED
      unset -v _subdir _function _subdir_path _import_target
      return 0
    ;;
  esac

  # If we're here, then 'import()' wasn't called correctly
  sh_stack_dump
  printf -- 'import: %s\n' "Unspecified error while executing 'import ${*}'" >&2
  unset -v _subdir _function _subdir_path _import_target
  exit 1
}
