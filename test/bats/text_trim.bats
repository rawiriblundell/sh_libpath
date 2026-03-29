#!/usr/bin/env bats
# Tests for str_trim, str_ltrim, str_rtrim, str_ntrim in
# lib/sh/text/trim.sh

load 'helpers/setup'

# ---------------------------------------------------------------------------
# str_trim
# ---------------------------------------------------------------------------

@test "str_trim: removes leading spaces" {
  run shellac_run 'include "text/trim"; str_trim "   hello"'
  [ "${status}" -eq 0 ]
  [ "${output}" = "hello" ]
}

@test "str_trim: removes trailing spaces" {
  run shellac_run 'include "text/trim"; str_trim "hello   "'
  [ "${status}" -eq 0 ]
  [ "${output}" = "hello" ]
}

@test "str_trim: removes both leading and trailing spaces" {
  run shellac_run 'include "text/trim"; str_trim "  hello world  "'
  [ "${status}" -eq 0 ]
  [ "${output}" = "hello world" ]
}

@test "str_trim: already-clean string is unchanged" {
  run shellac_run 'include "text/trim"; str_trim "hello"'
  [ "${status}" -eq 0 ]
  [ "${output}" = "hello" ]
}

@test "str_trim: removes leading and trailing tabs" {
  run shellac_run $'include "text/trim"; str_trim "\thello\t"'
  [ "${status}" -eq 0 ]
  [ "${output}" = "hello" ]
}

@test "str_trim: empty string returns empty" {
  run shellac_run 'include "text/trim"; str_trim ""'
  [ "${status}" -eq 0 ]
  [ "${output}" = "" ]
}

@test "str_trim: preserves internal spaces" {
  run shellac_run 'include "text/trim"; str_trim "  hello   world  "'
  [ "${status}" -eq 0 ]
  [ "${output}" = "hello   world" ]
}

# ---------------------------------------------------------------------------
# str_ltrim
# ---------------------------------------------------------------------------

@test "str_ltrim: removes leading spaces only" {
  run shellac_run 'include "text/trim"; str_ltrim "  hello  "'
  [ "${status}" -eq 0 ]
  [ "${output}" = "hello  " ]
}

@test "str_ltrim: no leading spaces leaves string unchanged" {
  run shellac_run 'include "text/trim"; str_ltrim "hello  "'
  [ "${status}" -eq 0 ]
  [ "${output}" = "hello  " ]
}

# ---------------------------------------------------------------------------
# str_rtrim
# ---------------------------------------------------------------------------

@test "str_rtrim: removes trailing spaces only" {
  run shellac_run 'include "text/trim"; str_rtrim "  hello  "'
  [ "${status}" -eq 0 ]
  [ "${output}" = "  hello" ]
}

@test "str_rtrim: no trailing spaces leaves string unchanged" {
  run shellac_run 'include "text/trim"; str_rtrim "  hello"'
  [ "${status}" -eq 0 ]
  [ "${output}" = "  hello" ]
}

# ---------------------------------------------------------------------------
# str_ntrim
# ---------------------------------------------------------------------------

@test "str_ntrim: trims and collapses internal spaces" {
  run shellac_run 'include "text/trim"; str_ntrim "  hello   world  "'
  [ "${status}" -eq 0 ]
  [ "${output}" = "hello world" ]
}

@test "str_ntrim: single word unchanged after trim" {
  run shellac_run 'include "text/trim"; str_ntrim "  hello  "'
  [ "${status}" -eq 0 ]
  [ "${output}" = "hello" ]
}

@test "str_ntrim: collapses multiple internal spaces to one" {
  run shellac_run 'include "text/trim"; str_ntrim "a     b     c"'
  [ "${status}" -eq 0 ]
  [ "${output}" = "a b c" ]
}
