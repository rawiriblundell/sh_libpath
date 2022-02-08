# shellcheck shell=ksh
# The MIT License (MIT)

# Copyright (c) 2020 -, Rawiri Blundell

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

################################################################################
# Author's note: This is an exercise for my own amusement/education.
# If it works well for you, fantastic!  If you have ideas, please submit them :)

# Our variant of die()
# We used to call this json_vorhees.  Har har.
# Note that in the parent script, extra logic may be necessary to die in subshells
# See: https://gist.github.com/rawiriblundell/2dab6903848f73641652a8e95e872dcb
json_die() {
  printf -- '====> jsonprint exception: %s\n' "${@}" >&2
  exit 1
}

# You might like to call it this way instead.
json_exception() {
  printf -- '====> jsonprint exception: %s\n' "${@}" >&2
  exit 1
}

# A curly brace to denote the opening of something, usually the json block
json_open() {
  printf -- '%s' "{"
}

# The partner for json_open()
# This emits a newline specifically for ndjson.
json_close() {
  printf -- '%s\n' "}"
}

# A single comma
json_comma() {
  printf -- '%s' ","
}

# Sometimes you may need to remove a trailing comma when processing a list
# i.e. the last value, object, array etc
# You should really try to structure your code to not need this
# To use, pipe into this function e.g. some_code | json_decomma
json_decomma() {
  sed 's/\(.*\),/\1 /'
}

# Apply a standard set of transformations to tidy up an input
json_sanitise() {
  if [[ -n "${1}" ]]; then
    _input="${1}"
  else
    read -r _input
  fi

  # Strip any literal double quotes.
  # These will be re-added if required by an output function
  _input="${_input%\"}"
  _input="${_input#\"}"

  # Strip any literal single quotes.
  # These will be re-added if required by an output function
  _input="${_input%\'}"
  _input="${_input#\'}"

  # Strip any trailing instances of ":" or "="
  _input="${_input%%:*}"
  _input="${_input%%=*}"

  # Remove any leading whitespace from 'value'
  _input="${_input#"${_input%%[![:space:]]*}"}"

  # Remove any trailing whitespace from 'key'
  _input="${_input%"${_input##*[![:space:]]}"}"

  # Return the input from whence it came
  printf -- '%s' "${_input}"
  unset -v _input
}

json_sanitize() {
  if [[ -n "${1}" ]]; then
    _input="${1}"
  else
    read -r _input
  fi

  # Strip any literal double quotes.
  # These will be re-added if required by an output function
  _input="${_input%\"}"
  _input="${_input#\"}"

  # Strip any literal single quotes.
  # These will be re-added if required by an output function
  _input="${_input%\'}"
  _input="${_input#\'}"

  # Strip any trailing instances of ":" or "="
  _input="${_input%%:*}"
  _input="${_input%%=*}"

  # Remove any leading whitespace from 'value'
  _input="${_input#"${_input%%[![:space:]]*}"}"

  # Remove any trailing whitespace from 'key'
  _input="${_input%"${_input##*[![:space:]]}"}"

  # Return the input from whence it came
  printf -- '%s' "${_input}"
  unset -v _input
}

# A function to ensure that any commands or files that we need exist
# On failure, this function generates simple warning keypairs e.g.
# { "Warning": "lsblk not found or not readable." }
json_require() {
  # shellcheck disable=SC2048
  for _fsobj in ${*}; do
    # First try to determine if it's a command
    command -v "${_fsobj}" >/dev/null 2>&1 && continue

    # TO-DO: This may require more smarts
    [[ -x ./"${_fsobj}" ]] && continue

    # Next, let's see if it's a readable file
    [[ -r "${_fsobj}" ]] && continue

    # If we get to this point, add it to our list of failures
    _failures+=( "${_fsobj}" )
  done

  # Tare a loop counter
  # This helps us to automatically determine when to stop outputting commas
  _iter_count=0

  # If we have no failures, then no news is good news - return quietly
  if (( "${#_failures[@]}" == 0 )); then
    # No news is good news
    unset _fsobj _failures _iter_count
    return 0
  # Otherwise, we process each element of our failure array
  else
    json_open
      for _fsobj in ${_failures[*]}; do
        # If we're on our first run through this loop, we need to use json_str()
        # Once we iterate _iter_count by 1, we don't need to touch it again
        if (( _iter_count == 0 )); then
          json_str Warning "${_fsobj} not found or not readable"
          (( _iter_count++ ))
        # With _iter_count > 0, we simply append each extra warning
        # The append functions are prefixed with a comma, making them stackable
        else
          json_append_str Warning "${_fsobj} not found or not readable"
        fi
      done
    json_close
  fi
  unset _fsobj _failures _iter_count
  exit 1
}

# UNIX shell variables are not typed.  But...
# We need to know what we're dealing with in order to best assign a function
# i.e. a string -> json_str(), a number -> json_num() etc...
# Unfortunately we need to fork out to grep to keep this relatively portable
json_gettype() {
  # Floats
  if printf -- '%s\n' "${*}" | grep -E '^[-+]?[0-9]+\.[0-9]*$' >/dev/null 2>&1; then
    printf -- '%s\n' "float"
    return 0
  fi

  # Integers
  if printf -- '%s\n' "${*}" | grep -E '^[-+]?[0-9]+$' >/dev/null 2>&1; then
    printf -- '%s\n' "int"
    return 0
  fi

  # Booleans
  # In the case of a boolean, we should only ever deal with one arg
  case "${1}" in
    ([tT][rR][uU][eE])      _isbool=true ;;
    ([fF][aA][lL][sS][eE])  _isbool=true ;;
    ([yY][eE][sS])          _isbool=true ;;
    ([nN][oO])              _isbool=true ;;
    ([oO][nN])              _isbool=true ;;
    ([oO][fF][fF])          _isbool=true ;;
    (*)                     _isbool=false ;;
  esac
  if [[ "${_isbool}" = "true" ]]; then
    unset -v _isbool
    printf -- '%s\n' "bool"
    return 0
  else
    unset -v _isbool
  fi

  # Everything else we deal with as a string
  printf -- '%s\n' "string"
  return 0
}

# Open an array block
# If an arg is provided, we return '"name": ['
# Without any arg, we simply return '['
json_open_arr() {
  case "${1}" in
    ('')  printf -- '%s' "[" ;;
    (*)   printf -- '"%s": [' "${*}" ;;
  esac
}

# Close an array block
# With '-c' or -'--comma', we return '],'
# Without either arg, we return ']'
json_close_arr() {
  case "${1}" in
    (-c|--comma) shift 1; _comma="," ;;
    (*)          _comma="" ;;
  esac
  printf -- '%s%s' "]" "${_comma}"
  unset -v _comma
}

# Append an array to another
# If an arg is provided, we return '],"name": ['
# Otherwise, we simply return '],['
# With '-n' or '--no-bracket', the leading bracket is omitted
json_append_arr() {
  case "${1}" in
    (-n|--no-bracket)
      case "${2}" in
        ('')  printf -- '%s' ",[" ;;
        (*)   shift 1; printf -- ', "%s": [' "${*}" ;;
      esac
    ;;
    ('')  printf -- '%s' "],[" ;;
    (*)   printf -- '], "%s": [' "${*}" ;;
  esac
}

# Open an object block
# If an arg is provided, we return '"name": {'
# Without any arg, we simply return '{'
json_open_obj() {
  case "${1}" in
    ('')  printf -- '%s' "{" ;;
    (*)   printf -- '"%s": {' "${*}" ;;
  esac
}

# Close an object block
# With '-c' or -'--comma', we return '},'
# Without either arg, we return '}'
# shellcheck disable=SC2120
json_close_obj() {
  case "${1}" in
    (-c|--comma)  printf -- '%s,' "}" ;;
    (''|*)        printf -- '%s' "}" ;;
  esac 
}

# Append an object to another
# With '-n' or '--no-bracket', the leading bracket is omitted
json_append_obj() {
  case "${1}" in
    (-n|--no-bracket)
      case "${2}" in
        ('')  printf -- '%s' ",{" ;;
        (*)   shift 1; printf -- ', "%s": {' "${*}" ;;
      esac
    ;;
    ('')  printf -- '%s' "},{" ;;
    (*)   printf -- '}, "%s": {' "${*}" ;;
  esac
}

# A function to escape characters that must be escaped in JSON
# This converts stdin into a single column of octals
# We then search for our undesirable octals and emit our replacements
# Modified from https://stackoverflow.com/a/23166624
# Some of these might not be strictly necessary... YMMV...
# TO-DO: Add ability to process its $*/$@, at the moment it must be piped into
# shellcheck disable=SC2059
json_escape_str() {
    od -A n -t o1 -v | tr ' \t' '\n' | grep . |
    while read -r _char; do
      case "${_char}" in
        ('00[0-7]')  printf -- '\u00%s' "${_char}" ;;
        ('02[0-7]')  printf -- '\u00%s' "$(( "10#${_char}" - 10 ))" ;;
        ('010')      printf -- '%s' "\b" ;;
        ('011')      printf -- '%s' "\t" ;;
        ('012')      printf -- '%s' "\n" ;;
        ('013')      printf -- '\u00%s' "0B" ;;
        ('014')      printf -- '%s' "\f" ;;
        ('015')      printf -- '%s' "\r" ;;
        ('016')      printf -- '\u00%s' "0E" ;;
        ('017')      printf -- '\u00%s' "0F" ;;
        ('030')      printf -- '\u00%s' "18" ;;
        ('031')      printf -- '\u00%s' "19" ;;
        ('042')      printf -- '%s' "\\\"" ;;
        #('047')      printf -- '%s' "\'" ;;
        #('057')      printf -- '%s' "\/" ;;
        ('134')      printf -- '%s' "\\" ;;
        (''|*)       printf -- "\\${_char}" ;;
      esac
    done
  unset -v _char
}

# Format a string keypair
# With '-c' or '--comma', we return '"key": "value",'
# Without either arg, we return '"key": "value"'
# If the value is blank or literally 'null', we return 'null' unquoted
json_str() {
  case "${1}" in
    (-c|--comma) shift 1; _comma="," ;;
    (*)          _comma="" ;;
  esac
  # Clean and assign the _key variable
  _key="$(json_sanitise "${1:-null}")"
  case "${2}" in
    (null|'') printf -- '"%s": %s%s' "${_key}" "null" "${_comma}" ;;
    (*)       shift 1; printf -- '"%s": "%s"%s' "${_key}" "${*}" "${_comma}" ;;
  esac
  unset -v _comma _key
}

# Add a string keypair to an object
# This leads with a comma, allowing us to stack keypairs
# If the value is blank or literally 'null', we return 'null' unquoted
json_append_str() {
  # Clean and assign the _key variable
  _key="$(json_sanitise "${1:-null}")"
  case "${2}" in
    (null|'') printf -- ', "%s": %s' "${_key}" "null" ;;
    (*)       shift; printf -- ', "%s": "%s"' "${_key}" "${*}" ;;
  esac
  unset -v _key
}

# Format a number keypair using printf float notation.  Numbers are unquoted.
# With '-c' or '--comma', we return '"key": value,'
# Without either arg, we return '"key": value'
# If the value is not a number, an error will be thrown
# TO-DO: Possibly extend to allow scientific notataion
json_num() {
  case "${1}" in
    (-c|--comma) shift 1; _comma="," ;;
    (*)          _comma="" ;;
  esac
  # Clean and assign the _key and _value variables
  _key="$(json_sanitise "${1}")"
  _value="$(json_sanitise "${2:-null}")"
  case "${_value}" in
    (''|null)
      printf -- '"%s": %s%s' "${_key}" "null" "${_comma}"
    ;;
    (*[!0-9.]*)
      json_die "Value '${_value}' not a number"
    ;;
    (*[0-9][.][0-9]*)
      printf -- '"%s": %.2f%s' "${_key}" "${_value}" "${_comma}"
    ;;
    (*)
      # We strip any leading zeros as json doesn't support them (i.e. octal)
      printf -- '"%s": %.0f%s' "${_key}" "${_value}" "${_comma}"
    ;;
  esac
  unset -v _key _value _comma
}

# Add a number keypair using printf float natation.  Numbers are unquoted.
# This leads with a comma, allowing us to stack keypairs
# If the value is blank or literally 'null', we return 'null' unquoted
json_append_num() {
  # Clean and assign the _key and _value variables
  _key="$(json_sanitise "${1}")"
  _value="$(json_sanitise "${2:-null}")"
  case "${_value}" in
    (''|null)
      printf -- ', "%s": %s' "${_key}" "null"
    ;;
    (*[!0-9.]*)
      json_die "Value '${_value}' not a number"
    ;;
    (*[0-9][.][0-9]*)
      printf -- ', "%s": %.2f' "${_key}" "${_value}"
    ;;
    (*)
      printf -- ', "%s": %.0f' "${_key}" "${_value}"
    ;;
  esac
  unset -v _key _value
}

# Format a boolean true/false keypair.  Booleans are unquoted.
# With '-c' or '--comma', we return '"key": value,'
# Without either arg, we return '"key": value'
# If the value is neither 'true' or 'false', an error will be thrown
# TO-DO: Extend to map extra bools
json_bool() {
  case "${1}" in
    (-c|--comma) shift 1; _comma="," ;;
    (*)          _comma="" ;;
  esac
  # Clean and assign the _key and _value variables
  _key="$(json_sanitise "${1:-null}")"
  _value="$(json_sanitise "${2:-null}")"
  case "${_value}" in
    ([tT][rR][uU][eE])     _bool=true ;;
    ([fF][aA][lL][sS][eE]) _bool=false ;;
    ([yY][eE][sS])         _bool=true ;;
    ([nN][oO])             _bool=false ;;
    ([oO][nN])             _bool=true ;;
    ([oO][fF][fF])         _bool=false ;;
    (*)                    json_die "Value not a recognised boolean" ;;
  esac
  printf -- '"%s": %s%s' "${_key}" "${_bool}" "${_comma}"
  unset -v _key _value _bool _comma
}

# Add a boolean true/false keypair.  Booleans are unquoted.
# This leads with a comma, allowing us to stack keypairs
# If the value is neither 'true' or 'false', an error will be thrown
# TO-DO: Extend to map extra bools
json_append_bool() {
  # Clean and assign the _key and _value variables
  _key="$(json_sanitise "${1:-null}")"
  _value="$(json_sanitise "${2:-null}")"
  case "${_value}" in
    ([tT][rR][uU][eE])     _bool=true ;;
    ([fF][aA][lL][sS][eE]) _bool=false ;;
    ([yY][eE][sS])         _bool=true ;;
    ([nN][oO])             _bool=false ;;
    ([oO][nN])             _bool=true ;;
    ([oO][fF][fF])         _bool=false ;;
    (*)                    json_die "Value not a recognised boolean" ;;
  esac
  printf -- ', "%s": %s' "${_key}" "${_bool}"
  unset -v _key _value _bool
}

# Attempt to automatically figure out how to address a key value pair
# Untested, may change.
json_auto() {
  # Clean and assign the _key and _value variables
  _key="$(json_sanitise "${1}")"
  _value="$(json_sanitise "${2:-null}")"
  case $(json_gettype "${_value}") in
    (int|float) json_num "${_key}" "${_value}" ;;
    (bool)      json_bool "${_key}" "${_value}" ;;
    (string)    json_str "${_key}" "${_value}" ;;
  esac
  unset -v _key _value
}

# Attempt to automatically figure out how to address a key value pair
# Untested, may change.
json_append_auto() {
  # Clean and assign the _key and _value variables
  _key="$(json_sanitise "${1}")"
  _value="$(json_sanitise "${2:-null}")"
  case $(json_gettype "${_value}") in
    (int|float) json_append_num "${_key}" "${_value}" ;;
    (bool)      json_append_bool "${_key}" "${_value}" ;;
    (string)    json_append_str "${_key}" "${_value}" ;;
  esac
  unset -v _key _value
}

# This function takes a comma or equals delimited key-value pair input
# and emits it in a way that can be used by e.g. json_str()
# Example: a variable named 'line' that contains "Bytes: 22"
# json_num $(json_from_dkvp "${line}") -> "Bytes": 22
json_from_dkvp() {
  _line="${*}"
  case "${_line}" in
    (*:*)
      _key="${_line%%:*}"
      _value="${_line##*:}"
    ;;
    (*=*)
      _key="${_line%%=*}"
      _value="${_line##*=}"
    ;;
    (*)
      # To-do: figure out a desired behaviour for this instance
      :
    ;;
  esac
  # Clean the _key and _value variables
  _key="$(json_sanitise "${_key}")"
  _value="$(json_sanitise "${_value}")"
  printf -- '"%s" "%s"' "${_key}" "${_value}"
  unset -v _line _key _value
}

# This function takes any number of parameters and blindly structures
# every pair in the sequence into json keypairs.
# Example: json_foreach a b c d
# {"a": "b", "c": "d"}
# shellcheck disable=SC2048,SC2086,SC2183
json_foreach() {
  case "${1}" in
    (-n|--name) json_open_obj "${2}"; shift 2 ;;
    (*)         json_open_obj ;;
  esac
  # Tare a loop iteration counter
  _iter_count=0
  while read -r _key _value; do
    # Clean and the _key and _value variables
    _key="$(json_sanitise "${_key}")"
    _value="$(json_sanitise "${_value}")"

    # Now we determine what variable "type" _value is and
    # based on that, we select the appropriate output function
    case "$(json_gettype "${_value}")" in
      (int|float)
        if (( _iter_count == 0 )); then
          json_num "${_key}" "${_value}"
          (( _iter_count++ ))
        else
          json_append_num "${_key}" "${_value}"
        fi
      ;;
      (bool)
        if (( _iter_count == 0 )); then
          json_bool "${_key}" "${_value}"
          (( _iter_count++ ))
        else
          json_append_bool "${_key}" "${_value}"
        fi
      ;;
      (string|''|*)
        if (( _iter_count == 0 )); then
          json_str "${_key}" "${_value}"
          (( _iter_count++ ))
        else
          json_append_str "${_key}" "${_value}"
        fi
      ;;
    esac
  done < <(printf -- '%s %s\n' ${*})
  # shellcheck disable=SC2119
  json_close_obj
  unset -v _iter_count _key _value
}

# Preliminary attempt at a function to automatically read input and build objects
# do not use
json_readloop() {
  _loop_iter=0
    case "${1}" in
      (-n|--name) json_open_obj "${2}"; shift 2 ;;
      (*)         json_open_obj ;;
    esac
    while read -r _key _value; do
      # Clean the _key and _value variables
      _key="$(json_sanitise "${_key}")"
      _value="$(json_sanitise "${_value}")"

      if (( _loop_iter == 0 )); then
        case $(json_gettype "${_value}") in
          (int|float) json_num "${_key}" "${_value}" ;;
          (bool)      json_bool "${_key}" "${_value}" ;;
          (string)    json_str "${_key}" "${_value}" ;;
        esac
        (( _loop_iter++ ))
      else
        case $(json_gettype "${_value}") in
          (int|float) json_append_num "${_key}" "${_value}" ;;
          (bool)      json_append_bool "${_key}" "${_value}" ;;
          (string)    json_append_str "${_key}" "${_value}" ;;
        esac
      fi
    done < "${1:-/dev/stdin}"
  json_close_obj
  unset -v _loop_iter _key _value
}

# A function to append an object with a timestamp
# This attempts the epoch first, and fails over to YYYYMMDDHHMMSS
json_timestamp() {
  json_append_obj --no-bracket timestamp
    case "$(date '+%s' 2>&1)" in
      (*[0-9]*) json_num utc_epoch "$(date -u '+%s')" ;;
      (*)       json_num utc_YYYYMMDDHHMMSS "$(date -u '+%Y%m%d%H%M%S')" ;;
    esac
  json_close_obj
}
