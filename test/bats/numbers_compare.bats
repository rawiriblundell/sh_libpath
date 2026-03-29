#!/usr/bin/env bats
# Tests for num_compare, num_compare_float, numbers_version_compare,
# and semver_to_int in lib/sh/numbers/compare.sh

load 'helpers/setup'

# ---------------------------------------------------------------------------
# num_compare
# ---------------------------------------------------------------------------

@test "num_compare: equal integers returns 0" {
  run shellac_run 'include "numbers/compare"; num_compare 5 5'
  [ "${status}" -eq 0 ]
}

@test "num_compare: first greater returns 1" {
  run shellac_run 'include "numbers/compare"; num_compare 7 3'
  [ "${status}" -eq 1 ]
}

@test "num_compare: first less returns 2" {
  run shellac_run 'include "numbers/compare"; num_compare 3 7'
  [ "${status}" -eq 2 ]
}

@test "num_compare: negative numbers equal returns 0" {
  run shellac_run 'include "numbers/compare"; num_compare -5 -5'
  [ "${status}" -eq 0 ]
}

@test "num_compare: negative less than positive returns 2" {
  run shellac_run 'include "numbers/compare"; num_compare -1 1'
  [ "${status}" -eq 2 ]
}

# ---------------------------------------------------------------------------
# num_compare_float
# ---------------------------------------------------------------------------

@test "num_compare_float: equal floats returns 0" {
  run shellac_run 'include "numbers/compare"; num_compare_float 3.14 3.14'
  [ "${status}" -eq 0 ]
}

@test "num_compare_float: first greater returns 1" {
  run shellac_run 'include "numbers/compare"; num_compare_float 3.14 2.72'
  [ "${status}" -eq 1 ]
}

@test "num_compare_float: first less returns 2" {
  run shellac_run 'include "numbers/compare"; num_compare_float 1.0 2.0'
  [ "${status}" -eq 2 ]
}

@test "num_compare_float: integer inputs work" {
  run shellac_run 'include "numbers/compare"; num_compare_float 10 5'
  [ "${status}" -eq 1 ]
}

# ---------------------------------------------------------------------------
# numbers_version_compare
# ---------------------------------------------------------------------------

@test "numbers_version_compare: equal versions returns 0" {
  run shellac_run 'include "numbers/compare"; numbers_version_compare "1.2.3" "1.2.3"'
  [ "${status}" -eq 0 ]
}

@test "numbers_version_compare: first greater minor returns 1" {
  run shellac_run 'include "numbers/compare"; numbers_version_compare "2.1.0" "2.0.9"'
  [ "${status}" -eq 1 ]
}

@test "numbers_version_compare: first less returns 2" {
  run shellac_run 'include "numbers/compare"; numbers_version_compare "1.0" "2.0"'
  [ "${status}" -eq 2 ]
}

@test "numbers_version_compare: 1.0 equals 1.0.0 (missing segments treated as 0)" {
  run shellac_run 'include "numbers/compare"; numbers_version_compare "1.0" "1.0.0"'
  [ "${status}" -eq 0 ]
}

@test "numbers_version_compare: missing args returns 3" {
  run shellac_run 'include "numbers/compare"; numbers_version_compare "1.0"'
  [ "${status}" -eq 3 ]
}

@test "numbers_version_compare: alpha in version returns 4" {
  run shellac_run 'include "numbers/compare"; numbers_version_compare "1.0a" "1.0"'
  [ "${status}" -eq 4 ]
}

@test "numbers_version_compare: empty string returns 4" {
  run shellac_run 'include "numbers/compare"; numbers_version_compare "" "1.0"'
  [ "${status}" -eq 4 ]
}

# ---------------------------------------------------------------------------
# semver_to_int
# ---------------------------------------------------------------------------

@test "semver_to_int: 1.0.2 produces 10002" {
  run shellac_run 'include "numbers/compare"; semver_to_int "1.0.2"'
  [ "${status}" -eq 0 ]
  [ "${output}" = "10002" ]
}

@test "semver_to_int: 2.31.0 produces 23100" {
  run shellac_run 'include "numbers/compare"; semver_to_int "2.31.0"'
  [ "${status}" -eq 0 ]
  [ "${output}" = "23100" ]
}

@test "semver_to_int: strips non-numeric chars like 1.0.2k-fips" {
  run shellac_run 'include "numbers/compare"; semver_to_int "1.0.2k-fips"'
  [ "${status}" -eq 0 ]
  [ "${output}" = "10002" ]
}

@test "semver_to_int: two-part version pads missing patch to 00" {
  run shellac_run 'include "numbers/compare"; semver_to_int "3.5"'
  [ "${status}" -eq 0 ]
  [ "${output}" = "30500" ]
}
