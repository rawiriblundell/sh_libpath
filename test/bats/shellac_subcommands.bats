#!/usr/bin/env bats
# Tests for bin/shellac: add-libpath, rm-libpath, and the shellac() dispatcher.

load 'helpers/setup'

setup() {
  TEST_TMPDIR="$(mktemp -d)"
  # XDG_CONFIG_HOME: shellac appends /shellac internally, so point here, not at the shellac subdir
  TEST_XDG_CONFIG="${TEST_TMPDIR}/.config"
  mkdir -p "${TEST_XDG_CONFIG}/shellac"
  TEST_PATHS_CONF="${TEST_XDG_CONFIG}/shellac/paths.conf"
}

teardown() {
  rm -rf "${TEST_TMPDIR}"
}

# ---------------------------------------------------------------------------
# add-libpath
# ---------------------------------------------------------------------------

@test "add-libpath: appends path to paths.conf" {
  run bash -c "
    export SH_LIBPATH='${SHELLAC_LIB}'
    export XDG_CONFIG_HOME='${TEST_XDG_CONFIG}'
    source '${SHELLAC_BIN}'
    shellac add-libpath '/some/library/path'
    grep -qxF '/some/library/path' '${TEST_PATHS_CONF}'
  "
  [ "${status}" -eq 0 ]
}

@test "add-libpath: is idempotent (duplicate is silently skipped)" {
  run bash -c "
    export SH_LIBPATH='${SHELLAC_LIB}'
    export XDG_CONFIG_HOME='${TEST_XDG_CONFIG}'
    source '${SHELLAC_BIN}'
    shellac add-libpath '/some/library/path' >/dev/null 2>&1
    shellac add-libpath '/some/library/path' >/dev/null 2>&1
    grep -cxF '/some/library/path' '${TEST_PATHS_CONF}'
  "
  [ "${status}" -eq 0 ]
  [ "${output}" = "1" ]
}

@test "add-libpath: creates config dir if it does not exist" {
  rm -rf "${TEST_XDG_CONFIG}/shellac"
  run bash -c "
    export SH_LIBPATH='${SHELLAC_LIB}'
    export XDG_CONFIG_HOME='${TEST_XDG_CONFIG}'
    source '${SHELLAC_BIN}'
    shellac add-libpath '/created/path' >/dev/null 2>&1
    [ -d '${TEST_XDG_CONFIG}/shellac' ] && printf ok
  "
  [ "${status}" -eq 0 ]
  [ "${output}" = "ok" ]
}

# ---------------------------------------------------------------------------
# rm-libpath
# ---------------------------------------------------------------------------

@test "rm-libpath: removes an existing entry from paths.conf" {
  printf '%s\n' '/path/to/remove' > "${TEST_PATHS_CONF}"
  run bash -c "
    export SH_LIBPATH='${SHELLAC_LIB}'
    export XDG_CONFIG_HOME='${TEST_XDG_CONFIG}'
    source '${SHELLAC_BIN}'
    shellac rm-libpath '/path/to/remove'
    grep -qxF '/path/to/remove' '${TEST_PATHS_CONF}'
  "
  [ "${status}" -ne 0 ]
}

@test "rm-libpath: returns 1 if path is not present" {
  run bash -c "
    export SH_LIBPATH='${SHELLAC_LIB}'
    export XDG_CONFIG_HOME='${TEST_XDG_CONFIG}'
    source '${SHELLAC_BIN}'
    shellac rm-libpath '/not/in/conf'
  "
  [ "${status}" -eq 1 ]
}

@test "rm-libpath: uses tempfile-then-move (other entries are preserved)" {
  printf '%s\n' '/keep/this' '/remove/this' '/also/keep' > "${TEST_PATHS_CONF}"
  run bash -c "
    export SH_LIBPATH='${SHELLAC_LIB}'
    export XDG_CONFIG_HOME='${TEST_XDG_CONFIG}'
    source '${SHELLAC_BIN}'
    shellac rm-libpath '/remove/this'
    grep -qxF '/keep/this' '${TEST_PATHS_CONF}' &&
    grep -qxF '/also/keep' '${TEST_PATHS_CONF}'
  "
  [ "${status}" -eq 0 ]
}

# ---------------------------------------------------------------------------
# shellac() dispatcher
# ---------------------------------------------------------------------------

@test "shellac: unknown subcommand returns 1" {
  run shellac_run 'shellac bogus-command'
  [ "${status}" -eq 1 ]
  [[ "${output}" == *"unknown subcommand"* ]]
}

@test "shellac: no subcommand prints usage and returns 1" {
  run shellac_run 'shellac'
  [ "${status}" -eq 1 ]
  [[ "${output}" == *"Usage:"* ]]
}
