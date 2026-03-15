# sh_libpath

Making shell scripts more robust and readable with libraries

## TL;DR?

```bash
#!/usr/bin/env bash

# Load our init script
. /path/to/init-shlibpath || exit 1

# Import the function libraries that it provides
# Without a given extension, ".sh" is assumed
include sys/os
# Give a specific extension to load a shell specific lib
include utils/git.zsh
# If you have a full path to a library for whatever reason
include /opt/mycompany/some/full/path/to/a/specific/library.sh
# Or just load all libraries under the text libpath
include text

# Check that we have everything we need including shell version, commands and vars
# This means self-documenting code and fail-fast are handled in one line
requires BASH51 git jq curl osstr=Linux

# Lazy-load a config file in case that's something you need
wants /opt/secrets/squirrels.conf
```

## OK... Do you have more information?

This project proposes adding a library ecosystem, primarily for use in shell scripts.

`init-shlibpath` bootstraps a few environment vars, most importantly:

* `SH_LIBPATH` - this is a colon-separated list of library paths, just like `PATH`
* `SH_LIBPATH_ARRAY` - the same as above, just in an array
* `SH_LIBPATH_LOADED` - sentinel variable set when `init-shlibpath` is sourced, preventing re-initialisation
* `_SH_LOADED_<category>_<name>` - per-library sentinel variables set when each library is sourced, preventing duplicate loads

The proposed library structure caters for both monolithic libraries e.g.

`/usr/local/lib/sh/monolithic.sh`

As well as hierarchical e.g.

`/usr/local/lib/sh/text/string_function.sh`

It also adds the following functions:

### `include`

Similar to its `python` cousin `import` and/or its `perl` cousin `use`, this is intended for loading libraries

### `requires`

This function serves multiple purposes.  A lot of shell scripts:

* just _assume_ that binaries are present
* don't fail nicely if these binaries aren't
* don't really serve themselves well in terms of internal documentation
* don't fail-early.

`requires()` fixes all of that and more.

First, it works through multiple items so you only need to declare it once if you choose to.  It would typically be used to check for the existence of commands in `PATH` like this:

```bash
requires git jq sed awk
```

But it can also check that pre-requisite variables are as desired (or "as required", you might say), for example

```bash
requires EDITOR=/usr/bin/vim
```

It can also check for a particular version of `bash`, for example to require `bash 4.1` or newer:

```bash
requires BASH41
```

It also handles checking full paths for e.g. executable scripts, config files and SH_LIBPATH libraries.

By dealing with this at the very start of the script, we ensure that we fail early.  It abstracts away messy `command -v`/`which`/`type` tests and when someone reads a line like:

```bash
requires BASH42 git jq storcli /etc/multipath.conf
```

It's clear what the script needs in order to run i.e. it's self-documenting code.

### `wants`

Sources a file if it exists; silent no-op if not.  A lazy-loader for config files.

Some scripts contain logic to detect environmental facts — OS version quirks, available tools, site-specific paths — that rarely changes between runs.  Wrapping that detection behind a variable and caching the result in a config file means subsequent invocations skip straight past it.  Load that config file with `wants` at the top of your script and the short-circuit is free.

## Why

Shell is the first language most *nix practitioners reach for, the go-to for sysadmins, and often the right tool for the job.  Yet most shell scripts are written as if no ecosystem exists — because for the most part, it doesn't.  There's no `pip` or `CPAN` for `bash`, no standard library to lean on.  So most scripts copy and paste the same sub-optimal code from StackOverflow, repeat the same anti-patterns, and carry the same bugs, over and over.

The people quickest to reach for Python or Ruby are often unaware that what they're really reaching for is the library ecosystem those languages carry.  The language itself isn't the point — the abstraction is.  Shell can have that too.

There are existing shell library projects, but most have at least one of these problems: restrictive licensing, Linux-only, so deeply self-referential the code is unreadable, or naming conventions that make you feel like you're writing enterprise Java (`____awesome__shell_library____+5000____class::::text__split__` is hyperbole, but not by much).

This project aims for something simpler: a permissively licensed, broadly portable library of solid shell functions, loadable on demand, with sane names.

## Why use libraries and not just a package of scripts

That's a good question.  The main reasons for using functions over standalone scripts are:

* Once loaded into memory, functions can be called a lot faster than on-disk scripts.  So functions are advantageous for repeated use.
* Functions assist with chunking shell code in a modular and organised way.  This makes them easier to develop and maintain.

Libraries, insofar as they're presented in this project, are simply collections of functions.

### Story time

At a former job I inherited a slow shell script — a very long pipeline of chained `grep -v` calls.  I refactored it: put the filter strings in an array, used `array::join()` to build a single `grep -Ev` pattern from them.  Cleaner, documented, measurably faster.  The PR was not well received.  The function was apparently proof that shell was the language of the Nazis, I had brought shame upon the company, and so forth.

Had my PR instead been:

```bash
+ include arrays.sh

... (some time later) ...

+ filter_string=$(array::join '|' "${strings_to_filter[@]}")
+ grep -Ev "${filter_string}" "${some_file}"
```

There would have been no controversy at all.

If you're a `python`ista or a `perl`er: when did you last read the source of a library you depend on?  "Approximately never" is the honest answer.  QED.

## Incomplete list of other bash libraries and frameworks

In alphabetical order only for readability:

* https://github.com/adoyle-h/lobash
* https://github.com/aks/bash-lib
* https://github.com/alebcay/awesome-shell
* https://github.com/antonrotar/command_runner
* https://github.com/awesome-lists/awesome-bash
* https://github.com/bahamas10/bash-stacktrace
* https://github.com/bahamas10/bash-vardump
* https://github.com/basherpm/basher
* https://github.com/bash-bastion/bash-core
* https://github.com/Bash-it/bash-it
* https://github.com/bashup/events
* https://github.com/BetterScripts/posix
* https://github.com/bpkg/bpkg
* https://github.com/CecilWesterhof/BashLibrary
* https://github.com/cloudflare/semver_bash
* https://github.com/codeforester/base
* https://github.com/cyberark/bash-lib
* https://github.com/DethByte64/BashLib
* https://github.com/dolpa/dolpa-bash-utils/blob/main/bash-utils.sh
* https://github.com/dzove855/bar
* https://github.com/ekahPruthvi/basil
* https://github.com/elibs/ebash
* https://github.com/ElectricRCAircraftGuy/eRCaGuy_hello_world/tree/master/bash
* https://github.com/fidian/ansi
* https://github.com/gruntwork-io/bash-commons
* https://github.com/HariSekhon/DevOps-Bash-tools
* https://github.com/hastec-fr/apash
* https://github.com/hornos/shf3
* https://github.com/hyperupcall/bash-term
* https://github.com/kamilcuk/L_lib/
* https://github.com/kigster/bashmatic
* https://github.com/jandob/rebash
* https://github.com/javier-lopez/learn/blob/master/sh/lib
* https://github.com/jmcantrell/bashful
* https://github.com/jneen/balls
* https://github.com/juan131/bash-libraries
* https://github.com/kvz/bash3boilerplate
* https://github.com/labbots/bash-utility
* https://github.com/m10k/toolbox
* https://github.com/martinburger/bash-common-helpers
* https://github.com/matejak/argbash
* https://github.com/mulle-nat/mulle-bashfunctions
* https://github.com/nafigator/bash-helpers
* https://github.com/niieani/bash-oo-framework
* https://github.com/paralllax/libash
* https://github.com/pioneerworks/lib-bash
* https://github.com/Privex/shell-core
* https://github.com/reale/bashlets
* https://github.com/shellfire-dev
* https://github.com/SpicyLemon/SpicyLemon/tree/master/bash_fun
* https://github.com/svn2github/oobash/tree/master/oobash
* https://github.com/tests-always-included/mo
* https://github.com/timo-reymann/bash-tui-toolkit
* https://github.com/tomocafe/bash-boost
* https://github.com/tsilvs/bashlib
* https://github.com/UrNightmaree/Shocket
* https://github.com/vlisivka/bash-modules
* https://github.com/Wuageorg/bashkit
* https://github.com/xsh-lib/core
* https://github.com/zombieleet/cash/
* https://github.com/zombieleet/bashify
* https://hyperupcall.github.io/basalt
* https://loader.sourceforge.io/overview/

## List of projects that may be inspirational

* https://github.com/zsh-users/antigen
* https://github.com/zsh-users

## Want to take it to the next level?

* https://github.com/modernish/modernish
* http://www.oilshell.org/
* https://ngs-lang.org/
