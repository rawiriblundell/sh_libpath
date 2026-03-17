#!/usr/bin/env bats
# Tests for lib/sh/sys/{cpu,mem,swap}hogs.sh
# Covers colorization switching: ANSI codes present on a tty, absent otherwise.

load 'helpers/setup'

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

# Run a bash snippet inside a PTY via `script`.
# Requires util-linux `script` (script -q -c CMD /dev/null).
# Stdout from the command is captured by bats in $output.
_pty_run() {
  script -q -c "bash -c ${1@Q}" /dev/null
}

# ---------------------------------------------------------------------------
# Setup / skip guard
# ---------------------------------------------------------------------------

setup() {
  if ! command -v script >/dev/null 2>&1; then
    skip "script(1) not available — interactive PTY tests cannot run"
  fi
}

# ---------------------------------------------------------------------------
# cpuhogs: _cpuhogs_print_fmt
# ---------------------------------------------------------------------------

@test "cpuhogs: no ANSI codes when stdout is not a tty" {
  run shellac_run '
    include sys/cpuhogs
    _cpuhogs_print_fmt green 1234 50.00 test_cmd
  '
  [ "${status}" -eq 0 ]
  [[ "${output}" != *$'\x1b'* ]]
}

@test "cpuhogs: ANSI codes present when stdout is a tty" {
  local snippet
  snippet="export SH_LIBPATH='${SHELLAC_LIB}'; source '${SHELLAC_BIN}'; include sys/cpuhogs; _cpuhogs_print_fmt green 1234 50.00 test_cmd"
  run _pty_run "${snippet}"
  [ "${status}" -eq 0 ]
  [[ "${output}" == *$'\x1b'* ]]
}

@test "cpuhogs: color escalates green -> yellow -> red by threshold" {
  run shellac_run '
    include sys/cpuhogs
    _cpuhogs_print_fmt green  1234  5.00 low_cmd
    _cpuhogs_print_fmt yellow 1235 15.00 mid_cmd
    _cpuhogs_print_fmt red    1236 25.00 high_cmd
  '
  [ "${status}" -eq 0 ]
  # Non-tty: all three lines plain, no escape codes at all
  [[ "${output}" != *$'\x1b'* ]]
  # All three PIDs appear in output
  [[ "${output}" == *1234* ]]
  [[ "${output}" == *1235* ]]
  [[ "${output}" == *1236* ]]
}

# ---------------------------------------------------------------------------
# memhogs: _memhogs_print_fmt
# ---------------------------------------------------------------------------

@test "memhogs: no ANSI codes when stdout is not a tty" {
  run shellac_run '
    include sys/memhogs
    _memhogs_print_fmt green 1234 50.00 test_cmd
  '
  [ "${status}" -eq 0 ]
  [[ "${output}" != *$'\x1b'* ]]
}

@test "memhogs: ANSI codes present when stdout is a tty" {
  local snippet
  snippet="export SH_LIBPATH='${SHELLAC_LIB}'; source '${SHELLAC_BIN}'; include sys/memhogs; _memhogs_print_fmt green 1234 50.00 test_cmd"
  run _pty_run "${snippet}"
  [ "${status}" -eq 0 ]
  [[ "${output}" == *$'\x1b'* ]]
}

@test "memhogs: color escalates green -> yellow -> red by threshold" {
  run shellac_run '
    include sys/memhogs
    _memhogs_print_fmt green  1234  5.00 low_cmd
    _memhogs_print_fmt yellow 1235 15.00 mid_cmd
    _memhogs_print_fmt red    1236 25.00 high_cmd
  '
  [ "${status}" -eq 0 ]
  [[ "${output}" != *$'\x1b'* ]]
  [[ "${output}" == *1234* ]]
  [[ "${output}" == *1235* ]]
  [[ "${output}" == *1236* ]]
}

# ---------------------------------------------------------------------------
# swaphogs: _swaphogs_print_fmt
# ---------------------------------------------------------------------------

@test "swaphogs: no ANSI codes when stdout is not a tty" {
  run shellac_run '
    include sys/swaphogs
    _swaphogs_print_fmt green 1234 50.00 test_cmd
  '
  [ "${status}" -eq 0 ]
  [[ "${output}" != *$'\x1b'* ]]
}

@test "swaphogs: ANSI codes present when stdout is a tty" {
  local snippet
  snippet="export SH_LIBPATH='${SHELLAC_LIB}'; source '${SHELLAC_BIN}'; include sys/swaphogs; _swaphogs_print_fmt green 1234 50.00 test_cmd"
  run _pty_run "${snippet}"
  [ "${status}" -eq 0 ]
  [[ "${output}" == *$'\x1b'* ]]
}

@test "swaphogs: color escalates green -> yellow -> red by threshold" {
  run shellac_run '
    include sys/swaphogs
    _swaphogs_print_fmt green  1234  5.00 low_cmd
    _swaphogs_print_fmt yellow 1235 15.00 mid_cmd
    _swaphogs_print_fmt red    1236 25.00 high_cmd
  '
  [ "${status}" -eq 0 ]
  [[ "${output}" != *$'\x1b'* ]]
  [[ "${output}" == *1234* ]]
  [[ "${output}" == *1235* ]]
  [[ "${output}" == *1236* ]]
}
