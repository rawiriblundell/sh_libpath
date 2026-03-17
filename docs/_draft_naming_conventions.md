# Shellac function naming conventions

This document describes the naming standard that has emerged across
`lib/sh/`. The net/ module is covered in more detail in
`_draft_net_naming.md`; what follows applies library-wide.

---

## Core principle

The module prefix is the namespace. Everything after it describes
*what* the function does, not *that it retrieves something*. `get_`
is not a verb — it is noise.

This mirrors the pattern used in modern standard libraries:

| Language | Local read | Network I/O |
|---|---|---|
| Python psutil | `net_if_addrs()` | — |
| Node.js | `os.networkInterfaces()` | `dns.lookup()` |
| Go net | `net.Interfaces()` | `net.LookupHost()` |

The shell equivalent: plain noun for local state, descriptive infix
for I/O operations.

---

## Patterns

### `<module>_<noun>` — local passive read

Reads local system state. No network calls, no blocking I/O. Failure
means the platform is unusual or a required tool is absent.

```bash
sys_shell        # what shell is running?
sys_mounts       # what is mounted?
net_ip           # local IP address
net_mac          # MAC address of primary interface
net_dns          # configured DNS servers
```

### `<module>_<noun>_<attr>` — attribute of a domain

Sub-functions under a domain noun. Always callable directly; also
reachable via the dispatcher.

```bash
sys_cpu_cores
sys_cpu_mhz
sys_mem_total
sys_mem_percent
sys_swap_used
sys_info_manufacturer
sys_info_serial
```

### `<module>_<noun>` as dispatcher

The plain noun form doubles as the dispatcher for its attribute
functions. With no argument it prints a summary. With a flag or
subcommand it routes to the appropriate helper.

```bash
sys_cpu                    # summary: manufacturer, model, mhz, count
sys_cpu cores              # single attribute
sys_mem total -M           # single attribute with unit flag
sys_info                   # all: manufacturer, model, serial, bios
sys_info --serial          # single attribute
sys_hogs                   # all three hog reports
sys_hogs mem 20            # single report with line count
```

The subcommand style (`sys_cpu cores`) is used where the noun has
many attributes and a flag would be unwieldy. The flag style
(`sys_info --serial`) is used where the domain is small or the
attributes are heterogeneous.

### `<module>_query_<noun>` — active outbound query

Makes a network call. Failure modes are qualitatively different from
local reads: firewalls, DNS, timeouts, service outages.

```bash
net_query_ip               # what is my public IP?
net_query_ipinfo 8.8.8.8   # geo/org metadata for an IP
net_query_port host 443    # is this port reachable?
net_query_http_code url    # HTTP status of a URL
```

See `_draft_net_naming.md` for the full rationale.

### `<module>_info_<attr>` — hardware identity

Hardware identity attributes are a special case of `_attr` where the
parent noun is `info` — the machine's self-description. These live in
`sys/info.sh` and are dispatched by `sys_info`.

```bash
sys_info_manufacturer
sys_info_model
sys_info_serial
sys_info_bios
```

### `svc_<verb>` — service control

Service lifecycle operations use a `svc_` prefix rather than `sys_`
because they are imperative (they *change* state) rather than
descriptive. The verb is mandatory.

```bash
svc_start nginx
svc_restart nginx
svc_status nginx
svc_enabled nginx
svc_active nginx
```

### `_<module>_<noun>` — internal helpers

Functions prefixed with `_` are private to their file. Not part of
the public API; may change without notice.

```bash
_cpuhogs_print_fmt
_mem_read
_mem_convert_kb
_swaphogs_get_proc_info
```

### `is_<condition>` — boolean predicates

Return 0 (true) or 1 (false). No output to stdout. Used in
conditionals.

```bash
is_aws
is_azure
is_debian_like
is_redhat_like
```

These have not yet been given a module prefix. Candidates:
`sys_is_aws`, `sys_is_azure`. Deferred.

---

## File naming

Files follow the same noun-first rule: `<noun>.sh`, no `get_` prefix,
no verb. The filename should match the primary function or dispatcher
it contains.

```
sys/cpu.sh            → sys_cpu, sys_cpu_*
sys/mem.sh            → sys_mem, sys_mem_*, sys_swap, sys_swap_*
sys/info.sh           → sys_info, sys_info_*
sys/hogs.sh           → sys_hogs (dispatcher over cpuhogs/memhogs/swaphogs)
net/query.sh          → net_query_*
net/dns.sh            → net_dns, net_dns_resolve
fs/stat_file.sh       → stat_file, fs_file_age, whoowns
fs/permissions.sh     → fs_permissions
units/temperature.sh  → celsius_to_fahrenheit, temp_convert, … (see exceptions)
units/permissions.sh  → octal_to_rwx, rwx_to_octal, permissions_convert
```

---

## Sentinel variables

Sentinel variables follow the file path, not the function names:

```bash
_SHELLAC_LOADED_<dir>_<filename_without_extension>
```

Examples:
```bash
_SHELLAC_LOADED_sys_cpu
_SHELLAC_LOADED_sys_info
_SHELLAC_LOADED_net_query
_SHELLAC_LOADED_net_dns
```

When a file is renamed or moved, the sentinel must be updated to
match the new path.

---

## Named exceptions

Some functions are exempt from the module-prefix rule where the prefix
would be tautological or the short form is clearly the better name.

| Function | File | Why exempt |
|---|---|---|
| `toarray` | `array/toarray.sh` | `array_toarray` reads as a stutter; the filename already provides the namespace |
| `mapfile` | `array/mapfile.sh` | Deliberate shadow of the bash builtin; must match the builtin name to act as a drop-in |
| `cpuhogs`, `memhogs`, `swaphogs` | `sys/*.sh` | Short, well-known names; `sys_cpuhogs` adds no clarity. `sys_hogs` is the namespaced entry point. |
| `celsius_to_fahrenheit`, `octal_to_rwx`, etc. | `units/*.sh` | The `<unit>_to_<unit>` pattern is self-describing; a module prefix adds nothing. `units_celsius_to_fahrenheit` is worse in every way. |

Note: functions in `units/` that read filesystem or system state are **not** exempt — those belong in the appropriate module. `get_permissions()` was moved to `fs/permissions.sh` as `fs_permissions()` for this reason. The boundary is: if the function converts between representations, it lives in `units/`; if it reads external state to produce a value, it belongs in `fs/`, `sys/`, or `net/`.

The test: if adding the prefix makes the name *longer without making it clearer*,
the short form is the right call.

---

## What we explicitly rejected

| Pattern | Reason |
|---|---|
| `get_<noun>` | POSIX/C legacy. No semantic value. Dropped everywhere. |
| `get_<domain>info_<attr>` | `info` infix is noise; the module prefix is sufficient context. |
| `net_get_<noun>` | PowerShell-style verbosity. The absence of `query_` already implies local/passive. |
| `<noun>::<verb>` | Double-colon namespace is not idiomatic shell. |
