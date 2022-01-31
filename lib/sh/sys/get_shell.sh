# shellcheck shell=ksh

# Because $SHELL is an unreliable thing to test against, we provide this function
# This won't work for 'fish', which needs 'ps -p %self' or similar
# non-bourne-esque syntax.
# TO-DO: Investigate application of 'export PS_PERSONALITY="posix"'
get_shell() {
  if [ -r "/proc/$$/cmdline" ]; then
    # We use 'tr' because 'cmdline' files have NUL terminated lines
    # TO-DO: Possibly handle multi-word output e.g. 'busybox ash'
    printf -- '%s\n' "$(tr '\0' ' ' </proc/"$$"/cmdline)"
  elif ps -p "$$" >/dev/null 2>&1; then
    ps -p "$$" | awk -F'[\t /]' 'END {print $NF}'
  # This one works well except for busybox
  elif ps -o comm= -p $$ >/dev/null 2>&1; then
    ps -o comm= -p $$
  elif ps -o pid,comm= >/dev/null 2>&1; then
    ps -o pid,comm= | awk -v ppid="$$" '$1==ppid {print $2}'
  # FreeBSD, may require more parsing
  elif command -v procstat >/dev/null 2>&1; then
    procstat -bh $$
  else
    case "${BASH_VERSION}" in (*.*) printf -- '%s\n' "bash"; return 0 ;; esac
    case "${KSH_VERSION}" in (*.*) printf -- '%s\n' "ksh"; return 0 ;; esac
    case "${ZSH_VERSION}" in (*.*) printf -- '%s\n' "zsh"; return 0 ;; esac
    # If we get to this point, fail out:
    printf -- '%s\n' "Unable to find method to determine the shell" >&2
    return 1
  fi
}
