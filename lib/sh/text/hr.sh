# shellcheck shell=ksh

_hr_width_helper() {
  command -v get_terminal_size >/dev/null 2>&1 || return
# heredocs can't be indented unless you use dirty hard tabs
IFS= read -r _hr_height _hr_width << EOF
$(get_terminal_size)
EOF
  printf -- '%s\n' "${_hr_width}"
  unset -v _hr_height _hr_width
}

# Write a horizontal line using any character
# If run interactively, this defaults to the full width of the window
# Otherwise it defaults to 60 columns
# Note: You will need to escape characters that have special shell meaning
# e.g. 'hr 40 \&'
hr() {
  # Figure out if we're in an interactive shell, then try to figure the width
  case "${-}" in
    (*i*) _hr_width="${COLUMNS:-$(_hr_width_helper)}" ;;
  esac

  # Default to 60 chars wide
  _hr_width="${_hr_width:-60}"

  # shellcheck disable=SC2183
  printf -- '%*s\n' "${1:-$_hr_width}" | tr ' ' "${2:-#}"

  unset -v _hr_width
}