# sh_libpath

Making shell scripts more robust with libraries

## TL;DR

```bash
#!/usr/bin/env bash

# Load our init script
. /path/to/init.sh || exit 1

# Start using the functions that it provides
import os.sh
import git.sh
from arrays import array_split.sh

requires BASH51 git jq osstr=Linux
wants /opt/secrets/squirrels.conf
```

## Enhance

This project proposes adding a library ecosystem to shell scripts.

`init.sh` bootstraps a couple of environment vars:

* `SH_LIBPATH` - this is a colon seperated list of library paths, just like `PATH`
* `SH_LIBS_LOADED` - a colon separated list of libraries that are already loaded.  This is used as one method to attempt multiple reloadings of the same library code

The proposed library structure caters for both monolithic libraries e.g.

`/usr/local/lib/sh/monolithic.sh`

As well as hierarchical e.g.

`/usr/local/lib/sh/text/string_function.sh`

It also adds the following functions:

### `import`

Similar to its `python` cousin, this is intended for loading monolithic libraries

### `from`

Similar to its `python` cousin, this is intended for loading hierarchical libraries

### `requires`

This function serves multiple purposes.  A lot of shell scripts just _assume_ that binaries are present and don't fail nicely if these binaries aren't.  A lot of shell scripts don't really serve themselves well in terms of internal documentation.  A lot of shell scripts don't fail-early.  `requires()` fixes all of that and more.

First, it works through multiple items so you only need to declare it once if you choose to.  It would typically be used to check for the existence of commands in `PATH` like this:

```bash
requires git jq sed awk
```

But it can also check that variables equal something, for example

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

This function currently deals only with files.  You tell it to look at a file, if that file is found it sources it.  Otherwise it's not fatal.  It's a lazy-loader, and I'm not sure how much work will go into it.

## Why

Well, why not?

I have spent large parts of my career fixing other people's shell scripts.  Now, to be clear and upfront: I'm not saying that I'm a scripting god - far from it.  I place myself somewhere on the right hand side of Dunning-Kruger's [Mount Stupid](https://psychology.stackexchange.com/questions/17825/what-is-the-primary-source-of-the-mount-stupid-graphic), but I still think that something needs to be done.

I keep seeing the same mistakes.  I keep seeing the same anti-patterns.  I keep seeing the same gnashing of teeth "rawrr use `python`" "arrgglleblarghle... my language of preference is so much better!" etc.  But quite often, shell, and `bash` specifically, *is* the appropriate language for the task at hand.  It's either the first, the only or the go-to language for many *nix sysadmins, and a lot of Devs approach it with a degree of ignorance.

The thing about people who clamour for any other language is that they are used to being spoiled: all the nitty gritty code that they actually rely on is abstracted away; hidden in libraries/modules that they load up with `import` or `use`.  With shell, there's no solid ecosystem of libraries to depend on, no `pip` or `CPAN` for `bash`, so most scripts are like [inventing the universe](https://www.youtube.com/watch?v=zSgiXGELjbc) every time.  This usually leads to the same sub-optimal code being copied and pasted off StackOverflow, and the same sub-optimal practices being spread.

And if you find yourself reading a larger script, it'll usually have a whole bunch of functions, usually taking up 80-90% of the code, and this collation of all the code in one file, while potentially enabling immense portability, makes the task of reading the script psychologically more daunting than it needs to be.

I think that until something like the Oil Shell or NGS gains traction, we can abstract a bunch of the common stuff away to libraries and solidify the code.  As a result, our scripts will in turn become more robust, safer, easier to read and easier to debug.

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
+ import arrays.sh

... (some time later) ...

+ filter_string=$(array::join '|' "${strings_to_filter[@]}")
+ grep -Ev "${filter_string}" "${some_file}
```

There would have been no controversy at all, and that would have been the end of it.

If you're a `python`ista or a `perl`er, and you're reading this, ask yourself honestly:  When was the last time you sat down and looked at the code inside *that* library that you like?  Odds are: "uhh... approximately... never?" is the answer.  QED.

### Not all hammers are created equal

Whenever someone mentions doing anything remotely constructive about the unix shell, someone invariably trots out Maslow's Hammer.

> If the only tool you have is a hammer, you tend to see every problem as a nail.
>  
> Abraham Maslow

And some might see this kind of effort as falling into that trap.  I don't.  Sometimes a nail really is a nail and we shouldn't have to tolerate a $5 Walmart hammer when we could have something more like a 20oz Estwing.  And, sometimes, the people who are on team spanners really shouldn't talk about hammers and nails.  I mean... you can hammer in a nail with a spanner, but it's not pretty...

See, also: [Master Foo and the Ten Thousand Lines](http://www.catb.org/~esr/writings/unix-koans/ten-thousand.html)

## XDG vars

Not all systems abide by the XDG spec.  We can provide a library to take care of some of that.

## Why use libraries and not just a package of scripts

That's a good question for which I don't have a good answer?

## Incomplete list of other bash libraries and frameworks

In no particular order...

* https://github.com/basherpm/basher
* https://github.com/Bash-it/bash-it
* https://github.com/bpkg/bpkg
* https://github.com/cyberark/bash-lib
* https://github.com/aks/bash-lib
* https://github.com/bashup/events
* https://github.com/dzove855/bar
* https://github.com/fidian/ansi
* https://github.com/matejak/argbash
* https://github.com/jneen/balls
* https://github.com/jmcantrell/bashful
* https://github.com/niieani/bash-oo-framework
* https://github.com/cloudflare/semver_bash
* https://github.com/zombieleet/bashify
* https://github.com/tests-always-included/mo
* https://github.com/juan131/bash-libraries
* https://github.com/labbots/bash-utility
* https://github.com/pioneerworks/lib-bash
* https://github.com/reale/bashlets
* https://github.com/mulle-nat/mulle-bashfunctions
* https://github.com/m10k/toolbox
* https://github.com/awesome-lists/awesome-bash Maybe holds some more
* https://github.com/alebcay/awesome-shell

## List of projects that may be inspirational

* https://github.com/zsh-users/antigen
* https://github.com/zsh-users
