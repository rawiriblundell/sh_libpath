#!/usr/bin/env bats
# Tests for str_is_alpha, str_is_alnum, and str_is_digits in
# lib/sh/text/predicates.sh

load 'helpers/setup'

# ---------------------------------------------------------------------------
# str_is_alpha
# ---------------------------------------------------------------------------

@test "str_is_alpha: pure alpha string passes" {
  run shellac_run 'include "text/predicates"; str_is_alpha "hello"'
  [ "${status}" -eq 0 ]
}

@test "str_is_alpha: uppercase alpha passes" {
  run shellac_run 'include "text/predicates"; str_is_alpha "HELLO"'
  [ "${status}" -eq 0 ]
}

@test "str_is_alpha: mixed case alpha passes" {
  run shellac_run 'include "text/predicates"; str_is_alpha "Hello"'
  [ "${status}" -eq 0 ]
}

@test "str_is_alpha: single letter passes" {
  run shellac_run 'include "text/predicates"; str_is_alpha "a"'
  [ "${status}" -eq 0 ]
}

@test "str_is_alpha: empty string fails" {
  run shellac_run 'include "text/predicates"; str_is_alpha ""'
  [ "${status}" -eq 1 ]
}

@test "str_is_alpha: string with digit fails" {
  run shellac_run 'include "text/predicates"; str_is_alpha "abc1"'
  [ "${status}" -eq 1 ]
}

@test "str_is_alpha: string with space fails" {
  run shellac_run 'include "text/predicates"; str_is_alpha "hello world"'
  [ "${status}" -eq 1 ]
}

@test "str_is_alpha: string with punctuation fails" {
  run shellac_run 'include "text/predicates"; str_is_alpha "hello!"'
  [ "${status}" -eq 1 ]
}

@test "str_is_alpha: digit-only string fails" {
  run shellac_run 'include "text/predicates"; str_is_alpha "123"'
  [ "${status}" -eq 1 ]
}

# ---------------------------------------------------------------------------
# str_is_alnum
# ---------------------------------------------------------------------------

@test "str_is_alnum: pure alpha passes" {
  run shellac_run 'include "text/predicates"; str_is_alnum "hello"'
  [ "${status}" -eq 0 ]
}

@test "str_is_alnum: pure digits pass" {
  run shellac_run 'include "text/predicates"; str_is_alnum "123"'
  [ "${status}" -eq 0 ]
}

@test "str_is_alnum: mixed alpha and digits pass" {
  run shellac_run 'include "text/predicates"; str_is_alnum "abc123"'
  [ "${status}" -eq 0 ]
}

@test "str_is_alnum: empty string fails" {
  run shellac_run 'include "text/predicates"; str_is_alnum ""'
  [ "${status}" -eq 1 ]
}

@test "str_is_alnum: string with hyphen fails" {
  run shellac_run 'include "text/predicates"; str_is_alnum "abc-123"'
  [ "${status}" -eq 1 ]
}

@test "str_is_alnum: string with space fails" {
  run shellac_run 'include "text/predicates"; str_is_alnum "abc 123"'
  [ "${status}" -eq 1 ]
}

@test "str_is_alnum: string with underscore fails" {
  run shellac_run 'include "text/predicates"; str_is_alnum "abc_123"'
  [ "${status}" -eq 1 ]
}

# ---------------------------------------------------------------------------
# str_is_digits
# ---------------------------------------------------------------------------

@test "str_is_digits: pure digits pass" {
  run shellac_run 'include "text/predicates"; str_is_digits "12345"'
  [ "${status}" -eq 0 ]
}

@test "str_is_digits: single digit passes" {
  run shellac_run 'include "text/predicates"; str_is_digits "0"'
  [ "${status}" -eq 0 ]
}

@test "str_is_digits: empty string fails" {
  run shellac_run 'include "text/predicates"; str_is_digits ""'
  [ "${status}" -eq 1 ]
}

@test "str_is_digits: alpha string fails" {
  run shellac_run 'include "text/predicates"; str_is_digits "abc"'
  [ "${status}" -eq 1 ]
}

@test "str_is_digits: mixed string fails" {
  run shellac_run 'include "text/predicates"; str_is_digits "12abc"'
  [ "${status}" -eq 1 ]
}

@test "str_is_digits: negative integer fails" {
  run shellac_run 'include "text/predicates"; str_is_digits "-5"'
  [ "${status}" -eq 1 ]
}

@test "str_is_digits: float fails" {
  run shellac_run 'include "text/predicates"; str_is_digits "1.5"'
  [ "${status}" -eq 1 ]
}
