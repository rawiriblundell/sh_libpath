# sh_libpath

Making shell scripts more robust with libraries

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

## The Unofficial Strict Mode

There is a lot of advice on the internet to "always use The Unofficial Strict Mode."

It is usually presented by its advocates as a brilliant one-time invocation that will magically fix every shell scripting issue. It is usually in a form similar to:

```bash
set -euo pipefail
```

The Unofficial Strict Mode is textbook [Cargo Cult Programming.](https://en.wikipedia.org/wiki/Cargo_cult_programming), and developers with less shell experience seem to love copying and pasting it, probably because the name gives them the illusion that it's some kind of `use strict`, which it isn't.  It's potentially more like `use chaos`.  It is non-portable, even within `bash` itself (as the behaviours of its various components have changed across `bash` versions), it replaces a set of well known and understood issues with a set of less known and less understood issues, and it gives a false sense of security.  Newcomers to shell scripting also fall into the trap of believing the claims of its advocates, to their potential peril.

`errexit`, `nounset` and `pipefail` are imperfect implementations of otherwise sane ideas, and unfortunately they often amount to being unreliable interfaces that are less familiar and less understood than simply living without them and curating defensive scripting habits. It's perfectly fine to *want* them to work as advertised, and I think we all would like that, but they don't, so shouldn't be recommended so blindly, nor advertised as a "best practice" - they aren't.

Some light reading into the matter:

* https://lists.nongnu.org/archive/html/bug-bash/2017-03/msg00171.html
* https://www.reddit.com/r/commandline/comments/g1vsxk/the_first_two_statements_of_your_bash_script/fniifmk/
* http://wiki.bash-hackers.org/scripting/obsolete
* http://mywiki.wooledge.org/BashFAQ/105
* http://mywiki.wooledge.org/BashFAQ/112
* https://mywiki.wooledge.org/BashPitfalls#set_-euo_pipefail
* https://bean.solutions/i-do-not-like-the-bash-strict-mode.html
* https://www.mulle-kybernetik.com/modern-bash-scripting/state-euxo-pipefail.html
* https://www.reddit.com/r/commandline/comments/4b3cqu/use_the_unofficial_bash_strict_mode_unless_you/
* https://www.reddit.com/r/programming/comments/25y6yt/use_the_unofficial_bash_strict_mode_unless_you/
* https://www.reddit.com/r/bash/comments/5zdzil/shell_scripts_matter_good_shell_script_practices/
* https://www.reddit.com/r/programming/comments/4daos8/good_practices_for_writing_shell_scripts/d1pgv4p/
* https://www.reddit.com/r/bash/comments/5ddvd2/til_you_can_turn_tracing_x_on_and_off_dynamically/da3xjkk/
* https://news.ycombinator.com/item?id=8054440
* http://www.oilshell.org/blog/2020/10/osh-features.html
* https://fvue.nl/wiki/Bash:_Error_handling
* https://gist.github.com/dimo414/2fb052d230654cc0c25e9e41a9651ebe (i.e. `set -u` is an absolute clusterfuck)

Now don't get me wrong: I recognise and genuinely like the *intent* behind the Unofficial Strict Mode.  But its subcomponents are so broken that the use of this mode often causes more trouble than it's worth.

And if you look at the original blogpost describing it, note that more than half of the page is dedicated to documenting workarounds for its flaws.

A number of other library/framework/module projects use and advocate for it.  I won't do that because it's counter to my goals.

I will provide it, however, via something like:

```bash
import strict.sh

# Enable Unofficial Strict Mode
strict_euopipefail

# Set IFS to '\t\n'
strict_nowhitesplitting
```

## XDG vars

Not all systems abide by the XDG spec.  We can provide a library to take care of some of that.

## Why use libraries and not just a package of scripts

That's a good question for which I don't have a good answer?


## How about importing singular functions

You mean like a `python`-esque import e.g.

```bash
from datetime import time
```

I think I have something that's more-or-less equivalent to that now.

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
* https://github.com/mulle-nat/mulle-bashfunctions
* https://github.com/m10k/toolbox
* https://github.com/awesome-lists/awesome-bash Maybe holds some more
* https://github.com/alebcay/awesome-shell

## List of projects that may be inspirational

* https://github.com/zsh-users/antigen
* https://github.com/zsh-users
