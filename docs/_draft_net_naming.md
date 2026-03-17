# net/ naming conventions

## The distinction

Functions in `lib/sh/net/` follow two naming patterns that reflect a
meaningful difference in what the function does:

| Pattern | What it does | Examples |
|---|---|---|
| `net_<noun>` | Reads local system state — no network I/O | `net_ip`, `net_mac`, `net_dns` |
| `net_query_<noun>` | Makes an outbound network call | `net_query_ip`, `net_query_port`, `net_query_ipinfo` |

`net_dns_resolve` is a deliberate exception: it fires a DNS query outbound
but lives in `dns.sh` as a DNS-domain operation rather than a general query.
If a full `net_query` dispatcher is ever built, it would route internally to
`net_dns_resolve`.

## Rationale

An earlier draft used `net_get_<noun>` for local reads, mirroring PowerShell's
`Get-NetIPAddress` / `Test-NetConnection` verb-noun grammar. This was
discarded as unnecessary verbosity.

Other languages make the same distinction without `get`:

- **Python `psutil`**: `net_if_addrs()`, `net_if_stats()` — plain nouns for
  local state, no verb
- **Node.js**: `os.networkInterfaces()` (local, noun only) vs `dns.lookup()`
  (network I/O, descriptive verb)
- **Go `net`**: `net.Interfaces()` (local, noun) vs `net.LookupHost()` (I/O,
  `Lookup` prefix)

The consistent pattern: local reads carry no verb because the namespace prefix
already provides enough context. Network I/O carries a verb because the
operation itself — and its failure modes — are meaningfully different.

`net_` is the namespace. `query_` is the I/O signal. Nothing else is needed.

## Failure mode as the real distinction

Local reads (`net_ip`, `net_mac`) fail only when the platform is unusual or
a required tool is absent. Network queries (`net_query_port`, `net_query_ip`)
can fail because of firewalls, DNS, timeouts, or service outages. Mixing them
under a single verb would obscure that difference.
