# shellcheck shell=ksh

# Randomise the characters within a string
# This uses a Knuth-Fisher-Yates shuffle method... kinda.
# Note: This does not produce cryptographically secure random strings!
str_shuffle() {
  # We require RANDOM, any shell that we come across should have it
  # But we check for it, just in case...
  if (( "${RANDOM:-1}${RANDOM:-1}" == "${RANDOM:-1}${RANDOM:-1}" )); then
    printf -- 'str_shuffle: %s\n' "No randomness found"
    return 1
  fi

  # Ensure that our dependencies are present
  for _str_shuffle_dep in fold paste; do
    if ! command -v "${_str_shuffle_dep}" >/dev/null 2>&1; then
      _str_shuffle_missing="${_str_shuffle_missing},${_str_shuffle_dep}"
    fi
  done
  if (( "${#_str_shuffle_missing}" > 0 )); then
    printf -- 'str_shuffle: %s\n' "The following requirements were not found in PATH" >&2
    printf -- '%s\n' "${_str_shuffle_missing/,/}" >&2
    unset -v _str_shuffle_missing _str_shuffle_dep
    return 1
  fi

  for word in "${@}"; do
    case "${#word}" in
      (1)
        # Don't go to the bother of shuffling single-char words like 'a'
        printf -- '%s ' "${word}"
      ;;
      (*)
        # Initialise an array of all the characters from the word and get the array size
        # shellcheck disable=SC2207
        _str_shuffle_chars=( $(printf -- '%s' "${word}" | fold -w 1 | paste -sd ' ') )
        _str_shuffle_charcount="${#_str_shuffle_chars[@]}"
        # $RANDOM % (i+1) is biased because of the limited range of $RANDOM
        # We compensate by using a range which is a multiple of the array size.
        _str_shuffle_randmax=$(( 32768 / _str_shuffle_charcount * _str_shuffle_charcount ))

        for ((i=_str_shuffle_charcount-1; i>0; i--)); do
          # Get a random modulo-able number within our range, the modulo it
          # shellcheck disable=SC2004
          while (( (rand=${RANDOM}) >= _str_shuffle_randmax )); do :; done
          rand=$(( rand % (i+1) ))

          # Swap the i'th element with the rand element
          _str_shuffle_chartmp="${_str_shuffle_chars[i]}"
          _str_shuffle_chars[i]=${_str_shuffle_chars[rand]}
          _str_shuffle_chars[rand]="${_str_shuffle_chartmp}"
        done
        # Convert the array back to a string and strip out the spaces
        # This gives us our shuffled word, which we print out
        shuffled_word="${_str_shuffle_chars[*]}"
        shuffled_word="${shuffled_word// /}"
        printf -- '%s ' "${shuffled_word}"
      ;;
    esac
    unset -v i word shuffled_word rand
  done
  printf -- '%s\n' ""
  unset -v _str_shuffle_deps _str_shuffle_missing _str_shuffle_chars
  unset -v _str_shuffle_charcount _str_shuffle_randmax _str_shuffle_chartmp
}
