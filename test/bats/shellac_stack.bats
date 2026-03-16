#!/usr/bin/env bats
# Tests for bin/shellac: sh_stack_add formatting and _shellac_stack subcommands.

load 'helpers/setup'

# ---------------------------------------------------------------------------
# sh_stack_add format
# ---------------------------------------------------------------------------

@test "sh_stack_add: entries are formatted as +NNNN: => message" {
  run shellac_run '
    sh_stack_add "test entry"
    last="${SH_STACK[-1]}"
    printf "%s\n" "${last}"
  '
  [ "${status}" -eq 0 ]
  local pattern='^\+[0-9]{4}: =>+ test entry$'
  [[ "${output}" =~ ${pattern} ]]
}

@test "sh_stack_add: elapsed time is non-negative" {
  run shellac_run '
    sh_stack_add "timing check"
    last="${SH_STACK[-1]}"
    elapsed="${last:1:4}"
    printf "%d\n" "${elapsed}"
  '
  [ "${status}" -eq 0 ]
  (( output >= 0 ))
}

@test "sh_stack_add: START entry is present after sourcing" {
  run shellac_run '
    for entry in "${SH_STACK[@]}"; do
      case "${entry}" in
        (*START*) printf found; exit 0 ;;
      esac
    done
    exit 1
  '
  [ "${status}" -eq 0 ]
  [ "${output}" = "found" ]
}

@test "SHELLAC_INIT_TIME: is set to a non-negative integer at source time" {
  run shellac_run 'printf "%d\n" "${SHELLAC_INIT_TIME}"'
  [ "${status}" -eq 0 ]
  (( output >= 0 ))
}

# ---------------------------------------------------------------------------
# _shellac_stack subcommands
# ---------------------------------------------------------------------------

@test "shellac stack dump: prints stack entries" {
  run shellac_run '
    sh_stack_add "dump test"
    shellac stack dump
  '
  [ "${status}" -eq 0 ]
  [[ "${output}" == *"dump test"* ]]
}

@test "shellac stack clear: empties SH_STACK" {
  run shellac_run '
    shellac stack clear
    printf "%d\n" "${#SH_STACK[@]}"
  '
  [ "${status}" -eq 0 ]
  [ "${output}" = "0" ]
}

@test "shellac stack: unknown subcommand returns 1" {
  run shellac_run 'shellac stack bogus'
  [ "${status}" -eq 1 ]
}
