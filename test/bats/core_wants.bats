#!/usr/bin/env bats
# Tests for lib/sh/core/wants.sh

load 'helpers/setup'

setup() {
  TEST_TMPDIR="$(mktemp -d)"
}

teardown() {
  rm -rf "${TEST_TMPDIR}"
}

# ---------------------------------------------------------------------------
# Direct path behaviour
# ---------------------------------------------------------------------------

@test "wants: sourcing an existing readable file succeeds" {
  local target="${TEST_TMPDIR}/config.sh"
  printf '%s\n' 'WANTS_TEST_VAR=loaded' > "${target}"
  run bash -c "
    export SH_LIBPATH='${SHELLAC_LIB}'
    source '${SHELLAC_BIN}'
    wants '${target}'
    printf '%s\n' \"\${WANTS_TEST_VAR}\"
  "
  [ "${status}" -eq 0 ]
  [ "${output}" = "loaded" ]
}

@test "wants: missing file is a silent no-op (exit 0)" {
  run bash -c "
    export SH_LIBPATH='${SHELLAC_LIB}'
    source '${SHELLAC_BIN}'
    wants '${TEST_TMPDIR}/does_not_exist.sh'
  "
  [ "${status}" -eq 0 ]
  [ -z "${output}" ]
}

@test "wants: existing but unreadable file returns 1" {
  local target="${TEST_TMPDIR}/unreadable.sh"
  printf '%s\n' '# content' > "${target}"
  chmod 000 "${target}"
  run bash -c "
    export SH_LIBPATH='${SHELLAC_LIB}'
    source '${SHELLAC_BIN}'
    wants '${target}'
  "
  chmod 644 "${target}"
  [ "${status}" -eq 1 ]
}

@test "wants: unreadable file error goes to stderr, not stdout" {
  local target="${TEST_TMPDIR}/unreadable.sh"
  printf '%s\n' '# content' > "${target}"
  chmod 000 "${target}"
  run bash -c "
    export SH_LIBPATH='${SHELLAC_LIB}'
    source '${SHELLAC_BIN}'
    wants '${target}' 2>/dev/null
  "
  chmod 644 "${target}"
  [ "${status}" -eq 1 ]
  [ -z "${output}" ]
}

@test "wants: does not exit the shell on failure (uses return 1)" {
  local target="${TEST_TMPDIR}/unreadable.sh"
  printf '%s\n' '# content' > "${target}"
  chmod 000 "${target}"
  run bash -c "
    export SH_LIBPATH='${SHELLAC_LIB}'
    source '${SHELLAC_BIN}'
    wants '${target}' 2>/dev/null || true
    printf survived
  "
  chmod 644 "${target}"
  [ "${status}" -eq 0 ]
  [ "${output}" = "survived" ]
}

# ---------------------------------------------------------------------------
# Bare filename search via SH_CONFPATH_ARRAY
# ---------------------------------------------------------------------------

@test "wants: bare filename is sourced from SH_CONFPATH_ARRAY" {
  local conf_dir="${TEST_TMPDIR}/conf"
  mkdir -p "${conf_dir}"
  printf '%s\n' 'WANTS_BARE_VAR=from_confpath' > "${conf_dir}/myapp.conf"
  run bash -c "
    export SH_LIBPATH='${SHELLAC_LIB}'
    export SH_CONFPATH='${conf_dir}'
    source '${SHELLAC_BIN}'
    wants myapp.conf
    printf '%s\n' \"\${WANTS_BARE_VAR}\"
  "
  [ "${status}" -eq 0 ]
  [ "${output}" = "from_confpath" ]
}

@test "wants: bare filename not found in SH_CONFPATH_ARRAY is a silent no-op" {
  run bash -c "
    export SH_LIBPATH='${SHELLAC_LIB}'
    export SH_CONFPATH='${TEST_TMPDIR}'
    source '${SHELLAC_BIN}'
    wants nonexistent.conf
  "
  [ "${status}" -eq 0 ]
  [ -z "${output}" ]
}
