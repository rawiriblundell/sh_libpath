# shellcheck shell=ksh
# @redirect text/first.sh
# This file exists so that 'shellac include line/first' works as expected.
# The canonical implementation lives in text/first.sh.
# It is intentionally excluded from 'shellac libraries' output.

[ -n "${_SHELLAC_LOADED_text_first+x}" ] && return 0
# shellcheck disable=SC1090
. "$(dirname -- "${BASH_SOURCE[0]}")/../text/first.sh"
