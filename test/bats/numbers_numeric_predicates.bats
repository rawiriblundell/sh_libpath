#!/usr/bin/env bats
# Tests for num_is_numeric, num_is_positive_integer, and num_abs in
# lib/sh/numbers/numeric.sh and lib/sh/numbers/math.sh

load 'helpers/setup'

# ---------------------------------------------------------------------------
# num_is_numeric
# ---------------------------------------------------------------------------

@test "num_is_numeric: plain positive integer passes" {
  run shellac_run 'include "numbers/numeric"; num_is_numeric "42"'
  [ "${status}" -eq 0 ]
}

@test "num_is_numeric: zero passes" {
  run shellac_run 'include "numbers/numeric"; num_is_numeric "0"'
  [ "${status}" -eq 0 ]
}

@test "num_is_numeric: negative integer fails" {
  run shellac_run 'include "numbers/numeric"; num_is_numeric "-1"'
  [ "${status}" -eq 1 ]
}

@test "num_is_numeric: float fails" {
  run shellac_run 'include "numbers/numeric"; num_is_numeric "1.5"'
  [ "${status}" -eq 1 ]
}

@test "num_is_numeric: alpha string fails" {
  run shellac_run 'include "numbers/numeric"; num_is_numeric "abc"'
  [ "${status}" -eq 1 ]
}

@test "num_is_numeric: empty string fails" {
  run shellac_run 'include "numbers/numeric"; num_is_numeric ""'
  [ "${status}" -eq 1 ]
}

@test "num_is_numeric: no argument exits 2 with message" {
  run shellac_run 'include "numbers/numeric"; num_is_numeric'
  [ "${status}" -eq 2 ]
  [[ "${output}" == *"missing argument"* ]]
}

# ---------------------------------------------------------------------------
# num_is_positive_integer
# ---------------------------------------------------------------------------

@test "num_is_positive_integer: 1 passes" {
  run shellac_run 'include "numbers/numeric"; num_is_positive_integer "1"'
  [ "${status}" -eq 0 ]
}

@test "num_is_positive_integer: large positive integer passes" {
  run shellac_run 'include "numbers/numeric"; num_is_positive_integer "1000"'
  [ "${status}" -eq 0 ]
}

@test "num_is_positive_integer: zero fails" {
  run shellac_run 'include "numbers/numeric"; num_is_positive_integer "0"'
  [ "${status}" -eq 1 ]
}

@test "num_is_positive_integer: negative integer fails" {
  run shellac_run 'include "numbers/numeric"; num_is_positive_integer "-1"'
  [ "${status}" -eq 1 ]
}

@test "num_is_positive_integer: leading zero fails" {
  run shellac_run 'include "numbers/numeric"; num_is_positive_integer "01"'
  [ "${status}" -eq 1 ]
}

@test "num_is_positive_integer: alpha string fails" {
  run shellac_run 'include "numbers/numeric"; num_is_positive_integer "abc"'
  [ "${status}" -eq 1 ]
}

@test "num_is_positive_integer: empty string fails" {
  run shellac_run 'include "numbers/numeric"; num_is_positive_integer ""'
  [ "${status}" -eq 1 ]
}

@test "num_is_positive_integer: no argument exits 2 with message" {
  run shellac_run 'include "numbers/numeric"; num_is_positive_integer'
  [ "${status}" -eq 2 ]
  [[ "${output}" == *"missing argument"* ]]
}

# ---------------------------------------------------------------------------
# num_abs
# ---------------------------------------------------------------------------

@test "num_abs: positive integer is unchanged" {
  run shellac_run 'include "numbers/math"; num_abs "5"'
  [ "${status}" -eq 0 ]
  [ "${output}" = "5" ]
}

@test "num_abs: negative integer returns positive" {
  run shellac_run 'include "numbers/math"; num_abs "-5"'
  [ "${status}" -eq 0 ]
  [ "${output}" = "5" ]
}

@test "num_abs: zero returns zero" {
  run shellac_run 'include "numbers/math"; num_abs "0"'
  [ "${status}" -eq 0 ]
  [ "${output}" = "0" ]
}

@test "num_abs: non-integer fails with message" {
  run shellac_run 'include "numbers/math"; num_abs "abc"'
  [ "${status}" -eq 1 ]
  [[ "${output}" == *"not an integer"* ]]
}

@test "num_abs: no argument fails with message" {
  run shellac_run 'include "numbers/math"; num_abs'
  [ "${status}" -eq 1 ]
  [[ "${output}" == *"missing argument"* ]]
}
