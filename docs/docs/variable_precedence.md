While it's not strictly defined anywhere to my knowledge, there is arguably an unspoken-but-not-followed-but-probably-should-be variable precedence order from least to most important:

* script defaults
* environment variables
* config files
* command line options

For the purpose of this demonstration, let's assume a cloud tool named `cloudcli`.

So here's how you might handle the first two:

Within your script, you can define a script level var that references an env var, and otherwise sets a default if the env var is unset, like so:

```bash
cloud_user="${CLOUDCLI_USER:-admin}"
```

So if `CLOUDCLI_USER` is set, then whatever its value is gets used.  If, however, it is unset, then `admin` is used.

Moving up the order of precedence, we get to a config file, which usually should reside in either `/etc` or `/opt/subpath/etc` or some similar location.  The config file expects a simple shell variable assignment keyval format e.g.

```bash
cloudcli_user=finance-team
```

So now you've got a script that might look more like:

```bash
[[ -r /etc/cloudcli.conf ]] && . /etc/cloudcli.conf
[[ -r /opt/cloudcli/etc/cloudcli.conf ]] && . /opt/cloudcli/etc/cloudcli.conf
[[ -r "${HOME:?}/.cloudcli/cloudcli.conf" ]] && . "${HOME}/.cloudcli/cloudcli.conf"
[[ -r "${XDG_CONFIG_HOME:-${HOME}/.config}/cloudcli/cloudcli.conf" ]] && . "${XDG_CONFIG_HOME:-${HOME}/.config}/cloudcli/cloudcli.conf"

cloud_user="${CLOUDCLI_USER:-admin}"
```

In this example, config files are sequenced in order of precedence so that they overlay.  Something like `/etc/cloudcli.conf` holds global defaults, and `"${XDG_CONFIG_HOME:-${HOME}/.config}/cloudcli/cloudcli.conf"` holds user-level overrides.  Each file sourced can redefine any variable set by an earlier one; the last definition wins.

Finally, let's say that `cloudcli` has an arg `--username`. If you run it like `cloudcli --username legal-team`, then that overrides anything else.

The correct behaviour for vars that can't be safely defaulted is to either go interactive or fail out with a message.  Going interactive is best treated as a one-time setup that writes the result to a config file.  Either way, be explicit about what is happening: print `Writing config to /home/user/.config/cloudcli/cloudcli.conf` when writing, and `Reading config from /etc/cloudcli.conf` when loading.

----

## Installing to /opt

Use `/opt/name` as the install root (e.g. `/opt/docker`, `/opt/shellac`).  Place a `/`-like structure within it, symlinking to other locations only where necessary:


    /opt/name/bin
    /opt/name/etc
    /opt/name/lib

Shorten paths where it's sensible — few people want to browse into

    /opt/name/var/log

When you could just have

    /opt/name/log

For a config file at

    /opt/name/etc/name.conf

If it needs to be visible elsewhere, symlink it.  XDG-aware systems can get a symlink at `$XDG_CONFIG_HOME/name/name.conf`; non-XDG systems at `/etc/opt/name/name.conf`.

You could also take a hierarchical view towards config files i.e. load configs in this sequence:

    /opt/name/etc/name.conf
    /etc/opt/name/name.conf
    $HOME/.name/name.conf
    $XDG_CONFIG_HOME/name/name.conf

This way, the last-definition of any variable overlays any previous definitions and takes precedence.  So you could think about it like this:

    /opt/name/etc/name.conf          <-- The defaults as defined by you, the maintainer
    /etc/opt/name/name.conf          <-- Any defaults that an OS or distro package maintainer may choose to implement in order to override your defaults
    $HOME/.name/name.conf            <-- One possible location for a user to have their vars set
    $XDG_CONFIG_HOME/name/name.conf  <-- Another possible location for a user to have their vars set

If you define, let's say, an env var in `/opt/name/etc/name.conf` like `NAME_REGION=APAC`, then that's the default.  Let's say that a user wants to set that region to something else, they may define it in `$XDG_CONFIG_HOME/name/name.conf` with `NAME_REGION=EMEA`.  As those config files are loaded in sequence, the end result will be: `NAME_REGION=EMEA`

Refer to the Filesystem Hierarchy Standard for the authoritative definition of `/opt` conventions.
