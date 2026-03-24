Shellac has no build step and no package manager dependency. Clone it, source
it once, run `shellac init`.

No dodgy `curl | bash` invocations!

---

## Quick install

```bash
# System-wide (requires sudo for the clone)
sudo git clone https://github.com/rawiriblundell/shellac /opt/shellac
source /opt/shellac/bin/shellac
shellac init
```

`shellac init` detects whether `/etc/profile.d/` is writable and configures a
system-wide or per-user install accordingly. It reports every change it makes
and is idempotent — safe to run again.

Example output (system-wide):

```
shellac init: detected clone at /opt/shellac
shellac init: /etc/profile.d/ is writable — system-wide install
shellac init: created /etc/profile.d/00-shellac.sh
shellac init: added PATH entry to /etc/profile.d/00-shellac.sh
shellac init: added SH_LIBPATH to /etc/profile.d/00-shellac.sh
shellac init: 3 change(s) made — reload with: source /etc/profile.d/00-shellac.sh
```

Example output (per-user, no root):

```
shellac init: detected clone at /home/user/.local/share/shellac
shellac init: /etc/profile.d/ is not writable — per-user install
shellac init: target file: /home/user/.bashrc
shellac init: added PATH entry to /home/user/.bashrc
shellac init: added SH_LIBPATH to /home/user/.bashrc
shellac init: 2 change(s) made — reload with: source /home/user/.bashrc
```

---

## Manual setup

If you prefer to configure the environment yourself rather than running
`shellac init`:

### System-wide

```bash
sudo git clone https://github.com/rawiriblundell/shellac /opt/shellac
```

Create `/etc/profile.d/00-shellac.sh`:

```bash
export PATH="/opt/shellac/bin:${PATH}"
export SH_LIBPATH="/opt/shellac/lib/sh"
```

`/etc/profile.d/` files are sourced by login shells on most Linux
distributions (AlmaLinux, RHEL, Ubuntu, Debian). The `00-` prefix ensures
shellac loads before any profile.d scripts that might use it.

Re-login or `source /etc/profile.d/00-shellac.sh` to activate in the current
shell.

### Per-user

```bash
git clone https://github.com/rawiriblundell/shellac "${HOME}/.local/share/shellac"
```

Add to `~/.bashrc`:

```bash
export PATH="${HOME}/.local/share/shellac/bin:${PATH}"
export SH_LIBPATH="${HOME}/.local/share/shellac/lib/sh"
```

Then reload:

```bash
source ~/.bashrc
```

---

## Development clone

If you want to work on shellac itself or pin to a specific commit, clone
wherever is convenient and point your shell at it:

```bash
git clone https://github.com/rawiriblundell/shellac ~/git/shellac
```

```bash
# In ~/.bashrc or a project-specific env file
export PATH="${HOME}/git/shellac/bin:${PATH}"
export SH_LIBPATH="${HOME}/git/shellac/lib/sh"
```

`bin/shellac` self-locates `lib/sh` relative to its own path using
`BASH_SOURCE[0]`, so it works correctly from any clone location without any
path configuration — the `SH_LIBPATH` export just skips the runtime discovery
scan.

---

## Verify the install

```bash
source shellac
shellac modules
```

`source shellac` works because bash searches `PATH` for bare names with no
slash. If shellac is found and loads correctly, `shellac modules` lists all
available modules. If it fails, check:

```bash
# Is bin/ on PATH?
command -v shellac

# Where is SH_LIBPATH pointing?
printf '%s\n' "${SH_LIBPATH}"

# Does lib/sh exist there?
ls "${SH_LIBPATH}"
```

---

## Keeping up to date

```bash
git -C /opt/shellac pull        # system-wide
git -C ~/.local/share/shellac pull   # per-user
```

No rebuild needed after a pull.

---

## Adding a custom library path

If you maintain local shellac libraries outside the main repo, register the
path rather than modifying the clone:

```bash
shellac add-libpath /opt/local/lib/sh
```

This appends the path to `~/.config/shellac/paths.conf`, which is read during
discovery on every subsequent `source shellac`. To remove it:

```bash
shellac rm-libpath /opt/local/lib/sh
```
