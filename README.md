# sh_libpath

Making shell scripts more robust with libraries

## Why

I have spent large parts of my career fixing other people's shell scripts.  Now, I'm not saying that I'm a scripting god - far from it.  I place myself somewhere on the right hand side of Dunning-Kruger's [Mount Stupid](https://psychology.stackexchange.com/questions/17825/what-is-the-primary-source-of-the-mount-stupid-graphic), but I still think that something needs to be done.

I keep seeing the same mistakes.  I keep seeing the same anti-patterns.  I keep seeing the same gnashing of teeth "rawrr use `python`" "arrgglleblarghle... my language of preference is so much better!" etc.  But quite often, shell, and `bash` specifically, *is* the language of the *nix sysadmin.  It's the language of those who are more on the Ops side of the DevOps spectrum, and quite often `bash` is actually the correct tool for the job.

The thing about people who clamour for any other language is that they are spoiled: all the nitty gritty code that they rely on is abstracted away; hidden in libraries/modules that they load up with `import` or `use`.  With shell, there's no solid ecosystem of libraries to depend on, so most scripts are like [inventing the universe](https://www.youtube.com/watch?v=zSgiXGELjbc) every time.  This usually leads to the same sub-optimal code being copied and pasted off StackOverflow, and the same sub-optimal practices being spread.

And if you read a larger script, it'll have a whole bunch of functions, usually taking up 80-90% of the code, and this collation of all the code in one file makes the task of reading the script psychologically more daunting than it need be.

If we can abstract a bunch of the usual stuff away to libraries, our scripts will in turn become more robust, easier to read and easier to debug.

### Story time to make this totally relatable

At a former job, I picked up a pre-existing shell script that was somewhat inefficiently written.  From memory it was a single line script, several thousand characters long, and basically a very long pipeline that was similar to

```bash
grep -v something | grep -v something-else | grep -v "another thing" | (this continues on and on and on...)
```

I put all of the regexes-to-be-filtered into an array, re-worked the logic a little and threw in a function named `array::join()`.  So the idea was that the script had something like this towards the top:

```bash
strings_to_filter=(
  "something"
  "something-else"
  "another thing"
)
```

That way, if there were any future changes to that list, adjusting it was clean and obvious.  Then `array::join` would smoosh the lot together into a single vertical-bar-delimited string which would be used by a single invocation of `grep -Ev`.  No surprises: it performed significantly faster.

This function used some shell-internal techniques to join the array elements together, and I knew that the code was going to be a bit obtuse so I added comments explaining what these various techniques did.  So I had a cleaner, more obvious, internally documented and performance tested improvement.  Well, that PR was not received well at all - this function was proof evident that shell was the language of the Nazis, that I had brought shame upon the company and that I should basically just kill myself after eating my own face.  How dare I attempt to reduce mediocrity?!  I should stab myself with a rusty screwdriver and rewrite the whole thing in `go`.

Now, on the other hand, had my PR simply been

```bash
+ import arrays.sh

... some time later ...

some_string=$(array::join '|' "${somearray[@]}")
```

There would have been literally no controversy at all, and that would have been the end of it.

If you're a `python`ista or a `perl`er, and you're reading this, ask yourself honestly:  When was the last time you sat down and looked at the code inside *that* library that you like?  Odds are: "uhh... approximately... never?" is the answer.  QED.

### Not all hammers are created equal

Abraham Maslow famously stated

>If the only tool you have is a hammer, you tend to see every problem as a nail.

And some might see this kind of effort as falling into that trap.  I don't.  If you're a carpenter and all you have is a cheap $5 Walmart hammer, your solution to nails isn't going to be a set of socket wrenches (say, `python`), or an electrician's toolbelt (say, `perl`), or a burning dumpster (insert that language that you really don't like here).  Indeed, the solution is usually a nailgun.  Let's assign that to [oilshell](http://www.oilshell.org/) or [ngs](https://ngs-lang.org/).  But carpenters don't use nailguns for all-things-nails either - they will always have a good clawhammer that they can use for things that a nailgun can't - or shouldn't - do.

So *when* shell is a hammer, and *when* we have actual nail problems, you shouldn't have to tolerate a $5 Walmart hammer, especially when we could have something more robust and durable, like an Estwing 20Oz.

## The Unofficial Strict Mode

XDG vars
Unofficial strict mode

## Why use libraries and not just a package of scripts

That's a good question for which I don't have a good answer?




function_list -> list functions in the library

net_cidr_list

## How about importing singular functions

You mean like a `python`-esque import e.g.

```
from datetime import time
```


## Incomplete list of bash libraries and frameworks

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
* https://github.com/awesome-lists/awesome-bash Maybe holds some more
* https://github.com/alebcay/awesome-shell

## List of projects that may be inspirational

* https://github.com/zsh-users/antigen
* https://github.com/zsh-users
