#!/usr/bin/env bats
# Lint tests: shellcheck compliance and shell coding standards.
#
# shellcheck severity: errors only (-S error).
#   Info-level issues (e.g. SC1091 unresolvable dynamic sources) are excluded
#   as they require major structural changes beyond lint scope.
#   Warning-level issues (e.g. SC2178 nameref false positives) are tracked
#   separately.
#
# Excluded files:
#   lib/sh/sys/mem.sh — structurally broken fragment (missing opening '{');
#   needs a full audit and rewrite before it can be linted cleanly.

load 'helpers/setup'

# ---------------------------------------------------------------------------
# shellcheck
# ---------------------------------------------------------------------------

@test "shellcheck: bin/shellac passes" {
  run shellcheck -S error "${SHELLAC_BIN}"
  [ "${status}" -eq 0 ]
}

@test "shellcheck: all library .sh files pass (excluding known-broken mem.sh)" {
  run bash -c "
    failed=0
    while IFS= read -r f; do
      if ! out=\$(shellcheck -S error \"\${f}\" 2>&1); then
        printf '%s\n' \"\${out}\"
        failed=1
      fi
    done < <(find '${SHELLAC_LIB}' -name '*.sh' ! -name 'mem.sh' | sort)
    exit \"\${failed}\"
  "
  [ "${status}" -eq 0 ]
}

# ---------------------------------------------------------------------------
# echo
# ---------------------------------------------------------------------------

@test "echo: not used as a command in bin/shellac" {
  # Match 'echo' at the start of a line (after optional whitespace).
  # This is the most common and unambiguous form of erroneous echo usage.
  run grep -En '^\s*echo\b' "${SHELLAC_BIN}"
  [ "${status}" -ne 0 ]
}

@test "echo: not used as a command in library files" {
  # Collect lines where 'echo' appears at the start of a line across all .sh files.
  # Output is empty when no matches are found; non-empty output means a violation.
  local results
  results=$(grep -rn --include='*.sh' -E '^\s*echo\b' "${SHELLAC_LIB}" 2>/dev/null || true)
  if [[ -n "${results}" ]]; then
    printf '%s\n' "${results}"
    return 1
  fi
}
