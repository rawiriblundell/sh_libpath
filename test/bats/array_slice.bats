#!/usr/bin/env bats
# Tests for array_slice, array_at, array_head, array_tail in
# lib/sh/array/slice.sh

load 'helpers/setup'

# ---------------------------------------------------------------------------
# array_slice
# ---------------------------------------------------------------------------

@test "array_slice: single index returns that element" {
  run shellac_run 'include "array/slice"; arr=(a b c d e); array_slice "2" arr'
  [ "${status}" -eq 0 ]
  [ "${output}" = "c" ]
}

@test "array_slice: single index 0 returns first element" {
  run shellac_run 'include "array/slice"; arr=(a b c d e); array_slice "0" arr'
  [ "${status}" -eq 0 ]
  [ "${output}" = "a" ]
}

@test "array_slice: inclusive :n returns first n elements" {
  run shellac_run 'include "array/slice"; arr=(a b c d e); array_slice ":3" arr'
  [ "${status}" -eq 0 ]
  [ "${output}" = "$(printf '%s\n' a b c)" ]
}

@test "array_slice: range x:y returns elements x through y-1" {
  run shellac_run 'include "array/slice"; arr=(a b c d e); array_slice "1:4" arr'
  [ "${status}" -eq 0 ]
  [ "${output}" = "$(printf '%s\n' b c d)" ]
}

@test "array_slice: inclusive_increment ::n prints every nth element" {
  run shellac_run 'include "array/slice"; arr=(a b c d e f); array_slice "::2" arr'
  [ "${status}" -eq 0 ]
  [ "${output}" = "$(printf '%s\n' a c e)" ]
}

@test "array_slice: increment x:y:z prints every zth from x to y" {
  run shellac_run 'include "array/slice"; arr=(a b c d e f g); array_slice "0:6:2" arr'
  [ "${status}" -eq 0 ]
  [ "${output}" = "$(printf '%s\n' a c e g)" ]
}

@test "array_slice: unrecognised specifier dumps whole array" {
  run shellac_run 'include "array/slice"; arr=(a b c); array_slice "junk" arr'
  [ "${status}" -eq 0 ]
  [ "${output}" = "$(printf '%s\n' a b c)" ]
}

# ---------------------------------------------------------------------------
# array_at
# ---------------------------------------------------------------------------

@test "array_at: positive index returns correct element" {
  run shellac_run 'include "array/slice"; arr=(a b c d e); array_at arr 2'
  [ "${status}" -eq 0 ]
  [ "${output}" = "c" ]
}

@test "array_at: index 0 returns first element" {
  run shellac_run 'include "array/slice"; arr=(a b c d e); array_at arr 0'
  [ "${status}" -eq 0 ]
  [ "${output}" = "a" ]
}

@test "array_at: negative index -1 returns last element" {
  run shellac_run 'include "array/slice"; arr=(a b c d e); array_at arr -1'
  [ "${status}" -eq 0 ]
  [ "${output}" = "e" ]
}

@test "array_at: --random returns a value from the array" {
  run shellac_run 'include "array/slice"; arr=(x y z); out=$(array_at arr --random); [[ " x y z " = *" ${out} "* ]]'
  [ "${status}" -eq 0 ]
}

# ---------------------------------------------------------------------------
# array_head
# ---------------------------------------------------------------------------

@test "array_head: default returns first element" {
  run shellac_run 'include "array/slice"; arr=(a b c d e); array_head arr'
  [ "${status}" -eq 0 ]
  [ "${output}" = "a" ]
}

@test "array_head: n=3 returns first three elements" {
  run shellac_run 'include "array/slice"; arr=(a b c d e); array_head arr 3'
  [ "${status}" -eq 0 ]
  [ "${output}" = "$(printf '%s\n' a b c)" ]
}

@test "array_head: n larger than array returns whole array" {
  run shellac_run 'include "array/slice"; arr=(a b); array_head arr 10'
  [ "${status}" -eq 0 ]
  [ "${output}" = "$(printf '%s\n' a b)" ]
}

# ---------------------------------------------------------------------------
# array_tail
# ---------------------------------------------------------------------------

@test "array_tail: default returns last element" {
  run shellac_run 'include "array/slice"; arr=(a b c d e); array_tail arr'
  [ "${status}" -eq 0 ]
  [ "${output}" = "e" ]
}

@test "array_tail: n=2 returns last two elements" {
  run shellac_run 'include "array/slice"; arr=(a b c d e); array_tail arr 2'
  [ "${status}" -eq 0 ]
  [ "${output}" = "$(printf '%s\n' d e)" ]
}

@test "array_tail: n larger than array returns whole array" {
  run shellac_run 'include "array/slice"; arr=(a b); array_tail arr 10'
  [ "${status}" -eq 0 ]
  [ "${output}" = "$(printf '%s\n' a b)" ]
}
