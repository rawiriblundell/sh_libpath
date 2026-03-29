#!/usr/bin/env bats
# Tests for temperature conversion functions in lib/sh/units/temperature.sh

load 'helpers/setup'

# ---------------------------------------------------------------------------
# celsius_to_fahrenheit
# ---------------------------------------------------------------------------

@test "celsius_to_fahrenheit: 0C = 32.00F" {
  run shellac_run 'include "units/temperature"; celsius_to_fahrenheit "0"'
  [ "${status}" -eq 0 ]
  [ "${output}" = "32.00" ]
}

@test "celsius_to_fahrenheit: 100C = 212.00F" {
  run shellac_run 'include "units/temperature"; celsius_to_fahrenheit "100"'
  [ "${status}" -eq 0 ]
  [ "${output}" = "212.00" ]
}

@test "celsius_to_fahrenheit: -40C = -40.00F" {
  run shellac_run 'include "units/temperature"; celsius_to_fahrenheit "-40"'
  [ "${status}" -eq 0 ]
  [ "${output}" = "-40.00" ]
}

@test "celsius_to_fahrenheit: invalid input returns null and exit 1" {
  run shellac_run 'include "units/temperature"; celsius_to_fahrenheit "abc"'
  [ "${status}" -eq 1 ]
  [ "${output}" = "null" ]
}

# ---------------------------------------------------------------------------
# fahrenheit_to_celsius
# ---------------------------------------------------------------------------

@test "fahrenheit_to_celsius: 32F = 0C" {
  run shellac_run 'include "units/temperature"; fahrenheit_to_celsius "32"'
  [ "${status}" -eq 0 ]
  [ "${output}" = "0" ]
}

@test "fahrenheit_to_celsius: 212F = 100.00C" {
  run shellac_run 'include "units/temperature"; fahrenheit_to_celsius "212"'
  [ "${status}" -eq 0 ]
  [ "${output}" = "100.00" ]
}

# ---------------------------------------------------------------------------
# celsius_to_kelvin
# ---------------------------------------------------------------------------

@test "celsius_to_kelvin: 0C = 273.15K" {
  run shellac_run 'include "units/temperature"; celsius_to_kelvin "0"'
  [ "${status}" -eq 0 ]
  [ "${output}" = "273.15" ]
}

@test "celsius_to_kelvin: 100C = 373.15K" {
  run shellac_run 'include "units/temperature"; celsius_to_kelvin "100"'
  [ "${status}" -eq 0 ]
  [ "${output}" = "373.15" ]
}

# ---------------------------------------------------------------------------
# kelvin_to_celsius
# ---------------------------------------------------------------------------

@test "kelvin_to_celsius: 273.15K = 0C" {
  run shellac_run 'include "units/temperature"; kelvin_to_celsius "273.15"'
  [ "${status}" -eq 0 ]
  [ "${output}" = "0" ]
}

# ---------------------------------------------------------------------------
# fahrenheit_to_kelvin / kelvin_to_fahrenheit
# ---------------------------------------------------------------------------

@test "fahrenheit_to_kelvin: 32F = 273.15K" {
  run shellac_run 'include "units/temperature"; fahrenheit_to_kelvin "32"'
  [ "${status}" -eq 0 ]
  [ "${output}" = "273.15" ]
}

@test "kelvin_to_fahrenheit: 373.15K = 212.00F" {
  run shellac_run 'include "units/temperature"; kelvin_to_fahrenheit "373.15"'
  [ "${status}" -eq 0 ]
  [ "${output}" = "212.00" ]
}

# ---------------------------------------------------------------------------
# temp_convert dispatcher
# ---------------------------------------------------------------------------

@test "temp_convert: 100 C F = 212.00" {
  run shellac_run 'include "units/temperature"; temp_convert 100 C F'
  [ "${status}" -eq 0 ]
  [ "${output}" = "212.00" ]
}

@test "temp_convert: 0 C K = 273.15" {
  run shellac_run 'include "units/temperature"; temp_convert 0 C K'
  [ "${status}" -eq 0 ]
  [ "${output}" = "273.15" ]
}

@test "temp_convert: C to C is identity" {
  run shellac_run 'include "units/temperature"; temp_convert 42 C C'
  [ "${status}" -eq 0 ]
  [ "${output}" = "42" ]
}

@test "temp_convert: unknown unit returns exit 1" {
  run shellac_run 'include "units/temperature"; temp_convert 100 C X'
  [ "${status}" -eq 1 ]
}

@test "temp_convert: invalid value returns null and exit 1" {
  run shellac_run 'include "units/temperature"; temp_convert abc C F'
  [ "${status}" -eq 1 ]
  [ "${output}" = "null" ]
}
