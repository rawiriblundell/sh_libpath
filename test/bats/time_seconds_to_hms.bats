#!/usr/bin/env bats
# Tests for time_seconds_to_hms in lib/sh/time/seconds_to_hms.sh

load 'helpers/setup'

@test "time_seconds_to_hms: zero seconds" {
  run shellac_run 'include "time/seconds_to_hms"; time_seconds_to_hms "0"'
  [ "${status}" -eq 0 ]
  [ "${output}" = "00:00:00" ]
}

@test "time_seconds_to_hms: 59 seconds" {
  run shellac_run 'include "time/seconds_to_hms"; time_seconds_to_hms "59"'
  [ "${status}" -eq 0 ]
  [ "${output}" = "00:00:59" ]
}

@test "time_seconds_to_hms: 60 seconds is one minute" {
  run shellac_run 'include "time/seconds_to_hms"; time_seconds_to_hms "60"'
  [ "${status}" -eq 0 ]
  [ "${output}" = "00:01:00" ]
}

@test "time_seconds_to_hms: 3600 seconds is one hour" {
  run shellac_run 'include "time/seconds_to_hms"; time_seconds_to_hms "3600"'
  [ "${status}" -eq 0 ]
  [ "${output}" = "01:00:00" ]
}

@test "time_seconds_to_hms: 3661 seconds" {
  run shellac_run 'include "time/seconds_to_hms"; time_seconds_to_hms "3661"'
  [ "${status}" -eq 0 ]
  [ "${output}" = "01:01:01" ]
}

@test "time_seconds_to_hms: 86399 seconds (23:59:59)" {
  run shellac_run 'include "time/seconds_to_hms"; time_seconds_to_hms "86399"'
  [ "${status}" -eq 0 ]
  [ "${output}" = "23:59:59" ]
}

@test "time_seconds_to_hms: negative integer fails" {
  run shellac_run 'include "time/seconds_to_hms"; time_seconds_to_hms "-1"'
  [ "${status}" -eq 1 ]
  [[ "${output}" == *"expected non-negative integer"* ]]
}

@test "time_seconds_to_hms: alpha string fails" {
  run shellac_run 'include "time/seconds_to_hms"; time_seconds_to_hms "abc"'
  [ "${status}" -eq 1 ]
  [[ "${output}" == *"expected non-negative integer"* ]]
}

@test "time_seconds_to_hms: float fails" {
  run shellac_run 'include "time/seconds_to_hms"; time_seconds_to_hms "1.5"'
  [ "${status}" -eq 1 ]
  [[ "${output}" == *"expected non-negative integer"* ]]
}

@test "time_seconds_to_hms: no argument fails with message" {
  run shellac_run 'include "time/seconds_to_hms"; time_seconds_to_hms'
  [ "${status}" -eq 1 ]
  [[ "${output}" == *"missing argument"* ]]
}
