# Common setup helpers for shellac bats tests.
# Source this from the setup() function in each .bats file:
#   load 'helpers/setup'

# Absolute paths derived from the location of this file
SHELLAC_HELPERS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SHELLAC_BATS_DIR="$(cd "${SHELLAC_HELPERS_DIR}/.." && pwd)"
SHELLAC_REPO="$(cd "${SHELLAC_BATS_DIR}/../.." && pwd)"
SHELLAC_BIN="${SHELLAC_REPO}/bin/shellac"
SHELLAC_LIB="${SHELLAC_REPO}/lib/sh"

# Run a bash subprocess that sources shellac with SH_LIBPATH pre-pointed at the
# repo's lib/sh, then executes the given inline script fragment.
# Usage:  run shellac_run 'printf "%s\n" "${SH_LIBPATH}"'
shellac_run() {
  bash -c "
    export SH_LIBPATH='${SHELLAC_LIB}'
    source '${SHELLAC_BIN}'
    ${1}
  "
}
