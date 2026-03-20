This document shows what a shellac-enhanced script looks like in practice.
The source script is `~/bin/regen_knownhosts` — a utility that safely
regenerates `~/.ssh/known_hosts` after a key rotation by pulling hosts
from bash history, deduplicating, re-scanning fingerprints, and falling
back to live SSH connections for hosts that keyscan can't reach.

The rewrite below is functionally equivalent. Annotations explain what
each shellac call replaces.

---

## Original pain points

| Before | After |
|---|---|
| `LC_CTYPE=C tr -dc "a-zA-Z0-9" < /dev/urandom \| fold -w 8 \| head -n 1` | `secrets_genpasswd 8` |
| `printf -- '%s\n' "..." >&2` (error to stderr) | `warn "..."` |
| `printf -- '======> %s\n' "Processing ${host}..."` | `log_info "Processing ${host}..."` |
| `trap 'rm -f "${file}"' RETURN` (hand-rolled) | `include core/trap` cleanup pattern |
| No dependency checking | `requires ssh ssh-keyscan ssh-keygen` |

---

## Shellac-enhanced version

```bash
#!/bin/bash
# Regenerate your known_hosts file after rotating your keys

source shellac 2>/dev/null || {
    printf -- '%s\n' "shellac not found - https://github.com/rawiriblundell/shellac" >&2
    exit 1
}

include core/die
include core/trap
include crypto/genpasswd
include utils/logging

# Fail fast if required tools are absent
requires ssh ssh-keyscan ssh-keygen

# --- Functions ---------------------------------------------------------------

# Build a candidate host list from bash history
_get_historical_hosts() {
    grep "^ssh " "${HOME}/.bash_history" |
        awk '{print $2}' |
        sort |
        uniq |
        grep -Ev -- '^-|ssh$|radius2\\|^raw$'
}

# Print or add SSH fingerprints for one or more hosts
ssh-fingerprint() {
    local fingerprint
    local keyscanargs=()
    fingerprint="$(mktemp)"

    # Cleanup temp file on return regardless of exit code
    trap 'rm -f "${fingerprint:?}"' RETURN

    # Prefer ed25519 where supported
    ssh -Q key 2>/dev/null | grep -q ed25519 &&
        keyscanargs=( -t "ed25519,rsa,ecdsa" )

    case "${1}" in
        (-a|--add|--append)
            shift 1
            ssh-keyscan "${keyscanargs[@]}" "${@}" > "${fingerprint}" 2>/dev/null
            [[ -s "${fingerprint}" ]] || return 1
            cp "${HOME}"/.ssh/known_hosts{,."$(date +%Y%m%d)"}
            sort -u "${fingerprint}" "${HOME}/.ssh/known_hosts.$(date +%Y%m%d)" \
                > "${HOME}/.ssh/known_hosts"
        ;;
        (''|-h|--help)
            warn "Usage: ssh-fingerprint (-a|--add|--append) [hostnames]"
            return 1
        ;;
        (*)
            ssh-keyscan "${keyscanargs[@]}" "${@}" > "${fingerprint}" 2>/dev/null
            [[ -s "${fingerprint}" ]] || return 1
            ssh-keygen -l -f "${fingerprint}"
        ;;
    esac
}

# --- Main --------------------------------------------------------------------

# Back up known_hosts with a random stamp so reruns don't collide
local rand_stamp
rand_stamp="$(secrets_genpasswd 8).$(date +%Y%m%d)"
cp "${HOME}/.ssh/known_hosts" "${HOME}/.ssh/known_hosts.${rand_stamp}"
log_info "Backed up known_hosts to known_hosts.${rand_stamp}"

# Split into hashed and unhashed entries
grep  '|1|' "${HOME}/.ssh/known_hosts" \
    > "${HOME}/.ssh/known_hosts.hashed"
grep -v '|1|' "${HOME}/.ssh/known_hosts" |
    awk '{print $1}' |
    tr ',' '\n' \
    > "${HOME}/.ssh/known_hosts.unhashed"

# Resolve hashed entries by matching against bash history
if [[ -s "${HOME}/.ssh/known_hosts.hashed" ]]; then
    while read -r host; do
        if ssh-keygen -F "${host}" >/dev/null 2>&1; then
            grep -q "${host}" "${HOME}/.ssh/known_hosts.unhashed" ||
                printf -- '%s\n' "${host}" >> "${HOME}/.ssh/known_hosts.unhashed"
        fi
    done < <(_get_historical_hosts)
fi

# Merge unhashed list with history, deduplicate
sort -u "${HOME}/.ssh/known_hosts.unhashed" \
    <(_get_historical_hosts) \
    > "${HOME}/.ssh/known_hosts.sorted"

# Clear known_hosts and rebuild from sorted list
: > "${HOME}/.ssh/known_hosts"

while read -r target_host; do
    log_info "Processing ${target_host}..."
    ssh-fingerprint --add "${target_host}" ||
        printf -- '%s\n' "${target_host}" >> "${HOME}/.ssh/failed_fingerprinting"
done < "${HOME}/.ssh/known_hosts.sorted"

# Second pass: attempt live SSH for hosts keyscan couldn't reach
if [[ -s "${HOME}/.ssh/failed_fingerprinting" ]]; then
    log_warn "Working through fingerprint failures — this may take a while"
    while read -r host; do
        if ! ssh -n -o ConnectTimeout=3 -o BatchMode=yes \
                -o StrictHostKeyChecking=accept-new "${host}" true; then
            warn "${host}: unable to connect — manual intervention required"
        fi
        grep -q "^${host}" "${HOME}/.ssh/known_hosts" &&
            log_info "${host} added to known_hosts"
    done < "${HOME}/.ssh/failed_fingerprinting"
fi

log_info "Done. Clean up ${HOME}/.ssh when you're satisfied:"
ls -1 "${HOME}/.ssh"
```

---

## What changed and why

**Loading shellac** — `source shellac` works because bash searches `PATH`
for bare names with no slash, and a standard shellac install puts `bin/`
on `PATH`. `bin/shellac` then self-locates `lib/sh` from its own path, so
no hardcoded install prefix is needed. If shellac is absent the script
fails immediately with a useful message rather than a cascade of
"command not found" errors.

**`requires`** — three tools are non-negotiable. Declaring them upfront
means the script fails with a clear message before touching anything,
rather than mid-run.

**`secrets_genpasswd 8`** — replaces the `tr | fold | head` pipeline.
Same result, readable at a glance.

**`warn` and `log_info` / `log_warn`** — replace ad-hoc `printf ... >&2`
calls. Log functions write to the right stream automatically, carry
consistent formatting, and can be silenced or redirected centrally.

The logic is otherwise unchanged — the rewrite is not a reimagining, just
a demonstration that shellac handles the scaffolding so the script can
focus on what it actually does.
