# shellcheck shell=ksh

get_child_pids() {
  _ppid="${1:?No PPID supplied}"
  if command -v pgrep >/dev/null 2>&1; then
    pgrep -P "${_ppid}"
  else
    ps -e -o pid,ppid | awk -v _ppid="${_ppid}" '$2 == _ppid{print $1}'
  fi
  unset -v _ppid
}

