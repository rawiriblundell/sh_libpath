#!/usr/bin/env bats
# Tests for str_url_encode, str_url_decode, str_to_base64, str_from_base64,
# and str_escape in lib/sh/text/encode.sh

load 'helpers/setup'

# ---------------------------------------------------------------------------
# str_url_encode
# ---------------------------------------------------------------------------

@test "str_url_encode: space becomes %20" {
  run shellac_run 'include "text/encode"; str_url_encode "hello world"'
  [ "${status}" -eq 0 ]
  [ "${output}" = "hello%20world" ]
}

@test "str_url_encode: unreserved chars pass through unchanged" {
  run shellac_run 'include "text/encode"; str_url_encode "abc-_~.123"'
  [ "${status}" -eq 0 ]
  [ "${output}" = "abc-_~.123" ]
}

@test "str_url_encode: equals and ampersand are encoded" {
  run shellac_run 'include "text/encode"; str_url_encode "foo=bar&baz"'
  [ "${status}" -eq 0 ]
  [ "${output}" = "foo%3Dbar%26baz" ]
}

@test "str_url_encode: empty string returns empty" {
  run shellac_run 'include "text/encode"; str_url_encode ""'
  [ "${status}" -eq 0 ]
  [ "${output}" = "" ]
}

# ---------------------------------------------------------------------------
# str_url_decode
# ---------------------------------------------------------------------------

@test "str_url_decode: %20 becomes space" {
  run shellac_run 'include "text/encode"; str_url_decode "hello%20world"'
  [ "${status}" -eq 0 ]
  [ "${output}" = "hello world" ]
}

@test "str_url_decode: plus sign becomes space" {
  run shellac_run 'include "text/encode"; str_url_decode "hello+world"'
  [ "${status}" -eq 0 ]
  [ "${output}" = "hello world" ]
}

@test "str_url_decode: %3D becomes equals" {
  run shellac_run 'include "text/encode"; str_url_decode "foo%3Dbar"'
  [ "${status}" -eq 0 ]
  [ "${output}" = "foo=bar" ]
}

@test "str_url_encode and str_url_decode roundtrip" {
  run shellac_run 'include "text/encode"; str_url_decode "$(str_url_encode "hello world & more")"'
  [ "${status}" -eq 0 ]
  [ "${output}" = "hello world & more" ]
}

# ---------------------------------------------------------------------------
# str_to_base64 / str_from_base64
# ---------------------------------------------------------------------------

@test "str_to_base64: encodes hello world" {
  run shellac_run 'include "text/encode"; str_to_base64 "hello world"'
  [ "${status}" -eq 0 ]
  [[ "${output}" = "aGVsbG8gd29ybGQ="* ]]
}

@test "str_from_base64: decodes hello world" {
  run shellac_run 'include "text/encode"; str_from_base64 "aGVsbG8gd29ybGQ="'
  [ "${status}" -eq 0 ]
  [ "${output}" = "hello world" ]
}

@test "str_to_base64 and str_from_base64 roundtrip" {
  run shellac_run 'include "text/encode"; str_from_base64 "$(str_to_base64 "the quick brown fox")"'
  [ "${status}" -eq 0 ]
  [ "${output}" = "the quick brown fox" ]
}

# ---------------------------------------------------------------------------
# str_escape
# ---------------------------------------------------------------------------

@test "str_escape: space is escaped" {
  run shellac_run 'include "text/encode"; str_escape "hello world"'
  [ "${status}" -eq 0 ]
  [[ "${output}" = *"hello"* ]]
  [[ "${output}" = *"world"* ]]
  # output must not be two bare unescaped words
  [[ "${output}" != "hello world" ]]
}

@test "str_escape: plain alphanumeric string is unchanged" {
  run shellac_run 'include "text/encode"; str_escape "hello123"'
  [ "${status}" -eq 0 ]
  [ "${output}" = "hello123" ]
}
