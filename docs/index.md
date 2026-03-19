# Shellac

The missing library ecosystem for shell.

Shellac is a modular bash library providing a consistent, well-named API across common domains: filesystem, networking, text, time, system, and more.

## Quick start

```bash
# Source shellac
source /path/to/shellac

# Browse the library hierarchy
shellac modules                   # list all modules
shellac info time                 # list libraries and functions in a module
shellac info time/dst.sh          # list functions in a single library
shellac info dst_is_active        # full documentation for a function
shellac provides dst_is_active    # which library defines a function

# Load and use a library
include fs/hash
fs_hash /etc/passwd
```

## Modules

| Module | Description |
|--------|-------------|
| `args` | Argument parsing and validation |
| `array` | Array manipulation and functional operations |
| `core` | Error handling, traps, type detection, status |
| `fs` | Filesystem operations, archives, hashing, permissions, stat |
| `git` | Git repository utilities |
| `goodies` | Animations and novelty functions |
| `line` | Line-oriented text operations |
| `misc` | AWS costs, Homebrew, Nagios output, strict modes |
| `net` | Networking — IP, DNS, CIDR, validation, queries |
| `numbers` | Numeric formatting, rounding, random, semver |
| `openssl` | SSL/TLS certificate inspection utilities |
| `path` | Path resolution and symlink handling |
| `sys` | CPU, memory, swap, uptime, terminal |
| `text` | String manipulation, formatting, helmet |
| `time` | Epoch, date conversion, month-end, DST |
| `units` | Unit conversion — temperature, permissions, storage |
| `users` | User and system account inspection |
| `utils` | Command checking, confirmation, password generation |

## Naming conventions

Shellac follows a consistent `<module>_<noun>` naming convention throughout. See the [naming conventions](naming-conventions.md) document for the full rationale, and [library structure](structure.md) for how modules, libraries, and functions relate to each other.
