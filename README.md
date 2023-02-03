# sh_libpath

Making shell scripts more robust and readable with libraries

| :warning: WARNING: This code is very very pre-alpha.  I'm currently just dumping in a bunch of functions from my code attic.  You're welcome to test, give feedback and contribute, but please don't use this for anything close to production! |
| --- |

## TL;DR?

```bash
#!/usr/bin/env bash

# Load our init script
. /path/to/init.sh || exit 1

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

`init.sh` bootstraps a few environment vars, most importantly:

* `SH_LIBPATH` - this is a colon seperated list of library paths, just like `PATH`
* `SH_LIBPATH_ARRAY` - the same as above, just in an array
* `SH_LIBS_LOADED` - a colon separated list of libraries that are already loaded.  This is used as one method to prevent attempts at multiple loadings of the same library code

The proposed library structure caters for both monolithic libraries e.g.

`/usr/local/lib/sh/monolithic.sh`

As well as hierarchical e.g.

`/usr/local/lib/sh/text/string_function.sh`

It also adds the following functions:

### `include`

Similar to its `python` cousin `import` and/or its `perl` cousin `use`, this is intended for loading libraries

### `requires`

This function serves multiple purposes.  A lot of shell scripts just _assume_ that binaries are present and don't fail nicely if these binaries aren't.  A lot of shell scripts don't really serve themselves well in terms of internal documentation.  A lot of shell scripts don't fail-early.  `requires()` fixes all of that and more.

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

This function currently deals only with files.  You tell it to look at a file, if that file is found it sources it.  Otherwise it's not fatal.  It's a lazy-loader, in other words.

Some scripts are built with a lot of logic for figuring out weird and tricky things.  You can save a lot of repeat processing by wrapping that logic up behind a var, and putting that var into a config file.  At the start of your script, you load the config file (or you don't) and it short-circuits various pieces of logic, leading to a more efficient run.

For example, I once proposed this code for the checkmk project, to replace some hairy, hackish and non-portable code they already had:

```bash
# GNU 'coreutils' 5.3.0 broke how 'stat' handled line endings in its output.
# This was corrected somewhere around 5.92 - 5.94 STABLE.
# If we detect a version of GNU stat 5.x, we investigate and set MK_STAT_BUG
# See: https://lists.gnu.org/archive/html/bug-coreutils/2005-12/msg00157.html
if var_is_blank "${MK_STAT_BUG}"; then
    # We only care about versions in the range [ 5.3.0 .. 5.94 ] (yes different numbering schemes)
    if stat --version 2>&1 | grep "GNU.*5.[3-9]" >/dev/null 2>&1; then
        # Convert the version information from semantic versioning to an integer
        stat_version=$(semver_to_int "$(stat --version 2>&1 | head -n 1)")
        if [ "${stat_version}" -ge 50300 ] && [ "${stat_version}" -lt 59400 ]; then
            MK_STAT_BUG="true"
        else
            MK_STAT_BUG="false"
        fi
        readonly MK_STAT_BUG
        export MK_STAT_BUG
    fi

fi

# If MK_STAT_BUG is true, we correct 'stat's behaviour globally
if [ "${MK_STAT_BUG}" = "true" ]; then
    stat() {
        printf -- '%s\n' "$(command stat "${@}")"
    }
fi
```

To prevent that code from being run through at every single invocation of the checkmk agent, one could simply define:

```bash
MK_STAT_BUG=false
```

within a config file.  Load that config file early in the agent script, and the majority of that code gets skipped.  Otherwise, if it's not short-circuited via a config file, it will just run through normally - no problem, just a bit of wasted processing.

So that's what `wants()` is about.  Originally, at least.

## Why

Well, why not?

I have spent large parts of my career fixing other people's shell scripts, and I keep seeing the same mistakes.  I keep seeing the same anti-patterns.  I keep seeing the same gnashing of teeth "More than 2 lines of shell and I use `python`" etc.  But quite often, shell, and `bash` specifically, *is* the appropriate language for the task at hand.  It's either the first, the only or the go-to language for many *nix sysadmins, and a lot of Devs approach it with a degree of ignorance.

The thing about people who clamour for any other language is that many of them are blissfully unaware that they're spoiled: all the nitty gritty code that they actually rely on is abstracted away; hidden in libraries/modules that they load up with `import` or `use` or some similar loader.  With shell, there's no solid ecosystem of libraries to depend on, no `pip` or `CPAN` for `bash`, so most scripts are like [inventing the universe](https://www.youtube.com/watch?v=zSgiXGELjbc) every time.  This usually leads to the same sub-optimal code being copied and pasted off StackOverflow, and the same sub-optimal practices being spread.

And if you find yourself reading a larger script, it'll usually have a whole bunch of functions - assuming it has some basic semblence of structure.  These functions usually take up 80-90% of the code, and this collation of all the code in one file, while potentially enabling immense portability, makes the task of reading the script psychologically more daunting than it needs to be.

I think that until something like the Oil Shell or NGS gains traction, we can abstract a bunch of the common stuff away to libraries and solidify the code.  As a result, our scripts will in turn become more robust, safer, easier to read and easier to debug.

Now, there are existing shell library projects out there, but they usually use a license that is too restrictive, or they are so deeply self-referencing that it's nearly impossible to make sense of their code.  Some will insist on ridiculous naming conventions: If you're more familiar with another language, you're going to want to call `split`, _not_ `____awesome__shell_library____+5000____class::::text__split__`.  Hyperbolic example, sure, but not far removed from what some of these library projects are inflicting on their users.  Personally, if I want my code to be that obnoxious to write, I'll switch to PowerShell.

These projects also tend to be Linux and `bash` 4.0 or newer only.  Maybe there'll be the occassional attempt at MacOS compatibility, but that's it.

## Why use libraries and not just a package of scripts

That's a good question.  The main reasons for using functions over standalone scripts are:

* Once loaded into memory, functions can be called a lot faster than on-disk scripts.  So functions are advantageous for repeated use.
* Functions assist with chunking shell code in a modular and organised way.  This makes them easier to develop and maintain.

Libraries, insofar as they're presented in this project, are simply collections of functions.

### Story time to make this totally relatable

At a former job, I picked up a pre-existing shell script that was somewhat inefficiently written.  From memory it was a very -very- long single line script, several thousand characters long, and basically a very long pipeline that was similar to

```bash
grep -v something | grep -v something-else | grep -v "another thing" | (this continues on and on and on...)
```

I put all of the strings-to-be-filtered into an array, re-worked the logic a little and threw in a function named `array::join()`.  So the idea was that the script had something like this towards the top:

```bash
strings_to_filter=(
  "something"
  "something-else"
  "another thing"
)
```

That way, if there were any future changes to that list, adjusting it was straightforward and obvious.  Then `array::join` would smoosh the lot together into a single vertical-bar-delimited string which would be used by a single invocation of `grep -Ev`.  As a result that should shock absolutely nobody: it performed significantly faster.

This function used some shell-native techniques to join the array elements together, and I knew that the code might be considered as a bit obtuse so I added comments briefly explaining what these various techniques did.  So I had a cleaner, more obvious, internally documented and performance tested improvement.  Well, that PR was not received well at all - this function was apparently proof evident that shell was the indeed the language of the Nazis, that I had brought shame upon the company, and that I should basically just eat my own shoes for having the conceit to propose any minimisation of mediocrity.

Now, on the other hand, had my PR simply been

```bash
+ include arrays.sh

... (some time later) ...

+ filter_string=$(array::join '|' "${strings_to_filter[@]}")
+ grep -Ev "${filter_string}" "${some_file}
```

There would have been no controversy at all, and that would have been the end of it.

If you're a `python`ista or a `perl`er, and you're reading this, ask yourself honestly:  When was the last time you sat down and looked at the code inside _that_ library that you like?  Odds are: "uhh... approximately... never?" is the answer.  QED.

### Not all hammers are created equal

Whenever someone mentions doing anything remotely constructive about the unix shell, someone invariably trots out Maslow's Hammer.

> If the only tool you have is a hammer, you tend to see every problem as a nail.
>  
> Abraham Maslow

And some might see this kind of effort as falling into that trap.  I don't.  Sometimes a nail really is a nail, and suggesting that you hit it with a spanner is idiotic.  Nor should we have to tolerate a $5 Walmart hammer when we could have something more like a 20oz Estwing.  And, sometimes, the people who are on team spanners really shouldn't talk about hammers and nails because it's not in their wheelhouse.  I mean... you _can_ hammer in a nail with a spanner, but it's not pretty...

See, also: [Master Foo and the Ten Thousand Lines](http://www.catb.org/~esr/writings/unix-koans/ten-thousand.html)

## Incomplete list of other bash libraries and frameworks

In alphabetical order only for readability:

* https://github.com/adoyle-h/lobash
* https://github.com/aks/bash-lib
* https://github.com/alebcay/awesome-shell
* https://github.com/awesome-lists/awesome-bash
* https://github.com/basherpm/basher
* https://github.com/Bash-it/bash-it
* https://github.com/bashup/events
* https://github.com/bpkg/bpkg
* https://github.com/cloudflare/semver_bash
* https://github.com/codeforester/base
* https://github.com/cyberark/bash-lib
* https://github.com/DethByte64/BashLib
* https://github.com/dzove855/bar
* https://github.com/elibs/ebash
* https://github.com/fidian/ansi
* https://github.com/gruntwork-io/bash-commons
* https://github.com/HariSekhon/DevOps-Bash-tools
* https://github.com/jandob/rebash
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
* https://github.com/tests-always-included/mo
* https://github.com/tomocafe/bash-boost
* https://github.com/vlisivka/bash-modules
* https://github.com/Wuageorg/bashkit
* https://github.com/xsh-lib/core
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
