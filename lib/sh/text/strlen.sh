# shellcheck shell=ksh

# Make getting a string length a bit more familiar
# for practitioners of other languages
strlen() {
  case "${1:?No string specified}" in
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
  unset -v str
}

