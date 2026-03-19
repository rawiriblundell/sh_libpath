# Library structure

Shellac organises its code in a three-level hierarchy:

```
Module  →  Library  →  Function
time/   →  dst.sh   →  dst_is_active
```

---

## Module

A **module** is a subdirectory under `lib/sh/`. It groups libraries that belong
to the same domain.

```
lib/sh/
  time/
  net/
  sys/
  text/
  ...
```

Modules define the first segment of every function name: `net_`, `sys_`,
`text_`, `time_`, and so on. See [naming conventions](naming-conventions.md)
for the full rules.

List all modules:

```bash
shellac modules
```

---

## Library

A **library** is a `.sh` file within a module. It groups functions that are
closely related within the module's domain.

```
time/dst.sh        # DST detection and offset
time/epoch.sh      # Unix epoch helpers
time/timestamp.sh  # formatted timestamp output
```

List all libraries (tree view, with loaded status):

```bash
shellac libraries
```

Inspect a specific module or library:

```bash
shellac info time             # all libraries and functions in the time module
shellac info time/dst.sh      # functions in a single library
shellac info time/dst         # .sh extension is optional
```

---

## Function

A **function** is a named public function defined within a library. Private
helper functions are prefixed with `_` and are not part of the public API.

Functions are documented inline using shdoc annotations:

```bash
# @description Convert a CIDR prefix length to a dotted-decimal subnet mask.
#
# @arg $1 string CIDR prefix length, e.g. 24 or /24
#
# @example
#   net_cidr_to_mask 24   # => 255.255.255.0
#
# @stdout The subnet mask in dotted-decimal notation
# @exitcode 0 Success
# @exitcode 1 No valid argument supplied
net_cidr_to_mask() { ... }
```

List all public functions (flat, sorted):

```bash
shellac functions
```

Show the full documentation for a function:

```bash
shellac info net_cidr_to_mask
```

Find which library defines a function:

```bash
shellac provides net_cidr_to_mask
# net_cidr_to_mask is provided by:
#   net/cidr.sh
```

---

## Loading

Libraries are loaded on demand with `include`:

```bash
include time/dst        # load a single library
include time            # load all libraries in the time module
include core/stdlib     # load the curated baseline set
```

The sentinel pattern (`_SHELLAC_LOADED_<module>_<library>`) makes repeated
inclusion free — loading the same library twice costs nothing.

---

## Browsing workflow

The commands compose into a natural drill-down:

```
shellac modules
  → shellac info <module>
      → shellac info <module/library>
          → shellac info <function>
              → shellac provides <function>
```
