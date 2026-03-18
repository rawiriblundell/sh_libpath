#!/usr/bin/env bats
# Tests for lib/sh/core/include.sh

load 'helpers/setup'

setup() {
  TEST_TMPDIR="$(mktemp -d)"
}

teardown() {
  rm -rf "${TEST_TMPDIR}"
}

# ---------------------------------------------------------------------------
# Full path loading
# ---------------------------------------------------------------------------

@test "include: full path to an existing readable file succeeds" {
  run bash -c "
    export SH_LIBPATH='${SHELLAC_LIB}'
    source '${SHELLAC_BIN}'
    include '${SHELLAC_LIB}/numbers/numeric.sh'
    command -v num_parse >/dev/null && printf ok
  "
  [ "${status}" -eq 0 ]
  [ "${output}" = "ok" ]
}

@test "include: full path to a missing file returns 1" {
  run bash -c "
    export SH_LIBPATH='${SHELLAC_LIB}'
    source '${SHELLAC_BIN}'
    include '${TEST_TMPDIR}/nonexistent.sh'
  "
  [ "${status}" -eq 1 ]
}

@test "include: full path to an unreadable file returns 1" {
  local target="${TEST_TMPDIR}/locked.sh"
  printf '%s\n' '# content' > "${target}"
  chmod 000 "${target}"
  run bash -c "
    export SH_LIBPATH='${SHELLAC_LIB}'
    source '${SHELLAC_BIN}'
    include '${target}' 2>/dev/null
  "
  chmod 644 "${target}"
  [ "${status}" -eq 1 ]
}

# ---------------------------------------------------------------------------
# Relative path loading (implicit .sh extension)
# ---------------------------------------------------------------------------

@test "include: relative path without extension resolves to .sh" {
  run bash -c "
    export SH_LIBPATH='${SHELLAC_LIB}'
    source '${SHELLAC_BIN}'
    include numbers/numeric
    command -v num_parse >/dev/null && printf ok
  "
  [ "${status}" -eq 0 ]
  [ "${output}" = "ok" ]
}

@test "include: relative path with explicit extension loads correctly" {
  run bash -c "
    export SH_LIBPATH='${SHELLAC_LIB}'
    source '${SHELLAC_BIN}'
    include numbers/numeric.sh
    command -v num_parse >/dev/null && printf ok
  "
  [ "${status}" -eq 0 ]
  [ "${output}" = "ok" ]
}

@test "include: missing relative path returns 1" {
  run bash -c "
    export SH_LIBPATH='${SHELLAC_LIB}'
    source '${SHELLAC_BIN}'
    include numbers/nonexistent 2>/dev/null
  "
  [ "${status}" -eq 1 ]
}

# ---------------------------------------------------------------------------
# Subdirectory bulk-load
# ---------------------------------------------------------------------------

@test "include: subdirectory bulk-load sources all .sh files" {
  local subdir="${TEST_TMPDIR}/mylib"
  mkdir -p "${subdir}"
  printf '%s\n' 'BULK_A=1' > "${subdir}/a.sh"
  printf '%s\n' 'BULK_B=2' > "${subdir}/b.sh"
  run bash -c "
    export SH_LIBPATH='${SHELLAC_LIB}:${TEST_TMPDIR}'
    source '${SHELLAC_BIN}'
    include mylib
    printf '%s %s\n' \"\${BULK_A}\" \"\${BULK_B}\"
  "
  [ "${status}" -eq 0 ]
  [ "${output}" = "1 2" ]
}

# ---------------------------------------------------------------------------
# Sentinel / double-source prevention
# ---------------------------------------------------------------------------

@test "include: already-loaded sentinel prevents double-sourcing" {
  local lib="${TEST_TMPDIR}/mylib/once.sh"
  mkdir -p "${TEST_TMPDIR}/mylib"
  printf '%s\n' \
    '[ -n "${_SHELLAC_LOADED_mylib_once+x}" ] && return 0' \
    '_SHELLAC_LOADED_mylib_once=1' \
    'ONCE_COUNTER=$(( ${ONCE_COUNTER:-0} + 1 ))' \
    > "${lib}"
  run bash -c "
    export SH_LIBPATH='${SHELLAC_LIB}:${TEST_TMPDIR}'
    source '${SHELLAC_BIN}'
    include mylib/once
    include mylib/once
    printf '%d\n' \"\${ONCE_COUNTER}\"
  "
  [ "${status}" -eq 0 ]
  [ "${output}" = "1" ]
}

# ---------------------------------------------------------------------------
# Error output
# ---------------------------------------------------------------------------

@test "include: missing library dumps stack trace to stdout" {
  run bash -c "
    export SH_LIBPATH='${SHELLAC_LIB}'
    source '${SHELLAC_BIN}'
    include numbers/nonexistent 2>/dev/null
  "
  [ "${status}" -eq 1 ]
  # Stack dump lines are formatted as +NNNN: ...
  local pattern='^\+[0-9]{4}:'
  [[ "${output}" =~ ${pattern} ]]
}

@test "include: error message goes to stderr (stack dump goes to stdout)" {
  # On failure, include() dumps the stack to stdout and the error message to stderr.
  # Verify the error message appears on stderr by swapping fd1/fd2.
  run bash -c "
    export SH_LIBPATH='${SHELLAC_LIB}'
    source '${SHELLAC_BIN}'
    include numbers/nonexistent 2>&1 1>/dev/null
  "
  [ "${status}" -eq 1 ]
  [[ "${output}" == *"include:"* ]]
}

@test "include: no args returns 1 with a message" {
  run bash -c "
    export SH_LIBPATH='${SHELLAC_LIB}'
    source '${SHELLAC_BIN}'
    include 2>/dev/null
  "
  [ "${status}" -eq 1 ]
}
