While it's not strictly defined, anywhere to my knowledge, in UNIX shells there's a de-facto variable precedence order.

From least to most important, they are:

* script defaults
* environment variables
* config files
* command line options

For the purpose of this demonstration, let's assume a cloud tool named `cloudcli`.

The first two levels compose naturally. A script-level variable references an env var and falls back to a hardcoded default if it's unset:

```bash
cloud_user="${CLOUDCLI_USER:-admin}"
```

So if `CLOUDCLI_USER` is set, then whatever its value is gets used.  If, however, it is unset, then `admin` is used.

Add config file sourcing and the script builds out to:

```bash
[[ -r /etc/cloudcli.conf ]] && . /etc/cloudcli.conf
[[ -r /opt/cloudcli/etc/cloudcli.conf ]] && . /opt/cloudcli/etc/cloudcli.conf
[[ -r "${HOME:?}/.cloudcli/cloudcli.conf" ]] && . "${HOME}/.cloudcli/cloudcli.conf"
[[ -r "${XDG_CONFIG_HOME:-${HOME}/.config}/cloudcli/cloudcli.conf" ]] && . "${XDG_CONFIG_HOME:-${HOME}/.config}/cloudcli/cloudcli.conf"

cloud_user="${CLOUDCLI_USER:-admin}"
```

In this example, config files are sequenced in order of precedence so that they overlay.  Something like `/etc/cloudcli.conf` holds global defaults, and `"${XDG_CONFIG_HOME:-${HOME}/.config}/cloudcli/cloudcli.conf"` holds user-level overrides.  Each file sourced can redefine any variable set by an earlier one; the last definition wins.

Command-line arguments sit at the top of the stack — `cloudcli --username legal-team` overrides everything.

The correct behaviour for vars that can't be safely defaulted is to either go interactive or fail out with a message.  Going interactive is best treated as a one-time setup that writes the result to a config file.  Either way, be explicit about what is happening: print `Writing config to /home/user/.config/cloudcli/cloudcli.conf` when writing, and `Reading config from /etc/cloudcli.conf` when loading.

## Config file hierarchy

Load configs in sequence, letting each file overlay the last — the last definition wins:

    /opt/name/etc/name.conf          <-- The defaults as defined by you, the maintainer
    /etc/opt/name/name.conf          <-- Any defaults that an OS or distro package maintainer may choose to implement in order to override your defaults
    $HOME/.name/name.conf            <-- One possible location for a user to have their vars set
    $XDG_CONFIG_HOME/name/name.conf  <-- Another possible location for a user to have their vars set

If you define, let's say, an env var in `/opt/name/etc/name.conf` like `NAME_REGION=APAC`, then that's the default.  Let's say that a user wants to set that region to something else, they may define it in `$XDG_CONFIG_HOME/name/name.conf` with `NAME_REGION=EMEA`.  As those config files are loaded in sequence, the end result will be: `NAME_REGION=EMEA`

*NOTE: This model assumes all variables are mutable. Marking a variable `readonly` before the later config files are sourced will cause subsequent assignments to silently fail (bash) or raise an error (some other shells), breaking the overlay chain. Reserve `readonly` for values that must genuinely never be overridden.*
