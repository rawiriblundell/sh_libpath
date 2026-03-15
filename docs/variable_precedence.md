# Variable precedence in bash

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
CLOUDCLI_USER=finance-team
```

So now you've got a script that might look more like:

```bash
[[ -r /etc/cloudcli.conf ]] && . /etc/cloudcli.conf
[[ -r /opt/cloudcli/etc/cloudcli.conf ]] && . /opt/cloudcli/etc/cloudcli.conf
[[ -r "${HOME:?}/.cloudcli/cloudcli.conf" ]] && . "${HOME}/.cloudcli/cloudcli.conf"
[[ -r "${XDG_CONFIG_HOME:?}/.cloudcli/cloudcli.conf" ]] && . "${XDG_CONFIG_HOME}/.cloudcli/cloudcli.conf"

cloud_user="${CLOUDCLI_USER:-admin}"
```

In this example, we sequence config files in order of precedence so that they overlay.  Something like `/etc/cloudcli.conf` would have global defaults, and something like `"${XDG_CONFIG_HOME}/.cloudcli/cloudcli.conf"` would have user-level defaults.  If a user is running this script, they very likely want their configuration to apply, and if they don't define something specifically, they would reasonably expect the global defaults to be used.

Finally, let's say that `cloudcli` has an arg `--username`. If you run it like `cloudcli --username legal-team`, then that overrides anything else.

IMNSHO the correct behaviour for vars that can't be safely defaulted is to either go interactive, or fail out with a message. I'm not a fan of going interactive, but if you do go interactive, you could treat it as a one-time setup and write the vars to a config file. Just be sure to be chatty about it e.g. `Writing config to /home/blah/.cloudcli/cloudcli.conf` (which also means that if you load a config file, you should probably be chatty there too e.g. `Reading config from /etc/cloudcli.conf`)

----

I would use `/opt/name`  (replace `name` with whatever it is e.g. `/opt/docker`, `/opt/gitlab` etc)

The idea is that you put a `/`-like structure within that directory and if necessary, you can symlink to wherever things need to be.  For example:

    /opt/name/bin
    /opt/name/etc
    /opt/name/lib

And so on as required.  You can also short-cut where it's sensible, not many people would want to browse into

    /opt/name/var/log

When you could just have

    /opt/name/log

So let' say you have a config file in

    /opt/name/etc/name.conf

If that _needs_ to be elsewhere for whatever reason, you can just symlink it.  For example on systems that do have `XDG_CONFIG_HOME` set, you could throw in a symlink at `$XDG_CONFIG_HOME/name/name.conf`.  For systems that aren't so hung up on the XDG standard, you could throw in a symlink at `/etc/opt/name/name.conf`

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

Note that this usage of `/opt` is off the top of my head so I might be slightly off on "correct" usage of `/opt`, refer to the Filesystem Hierarchy Standard.
