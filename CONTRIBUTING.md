# Contributing

Contributions are welcome!

## License

Any contributed code that is accepted into this repo will be published under the same license as the repo i.e. Apache 2.0 License, unless you choose to submit it under a compatible license like MIT.

I realise that some people might have issues with this.  If you're contributing modules or functions that aren't already covered, and you want to use a different license that you don't feel is compatible, consider instead hosting them on your own github repo and sending me a link.  I'll find somewhere to share it here and promote it.

| :pushpin: It might be nice in the future to have a very simple library fetch mechanism.  This would grab a simple manifest file from this repo, maybe perform some simple tasks based on the manifest, but ultimately its purpose would be to fetch any non-core libraries and place them into `SH_LIBPATH`.  What to call it though?  Something like `pip`?  How about... Shell Library Into Place or `slip`? |
| --- |

Whichever way you go, please do declare a FOSS license, otherwise potentially restrictive and messy Copyright rules apply by default.

### License Header

If you wish to contribute code under a compatible license, please include a license header in your file(s) and update [NOTICE](notice.md).  IF you wish to defer to the project's license, please include the contents of [license_header](license_header) at the top of your file(s).

## Third party code

Any code imported from another project or site must be using a compatible license such as MIT.  Attribution will be given and tracked in [NOTICE](NOTICE.md).

### Code copied from websites

Code that is published on a website is almost always the copyright of its author, or the website owner, depending on the site's terms and conditions.  Copyright is also automatic from the moment a work is created, and does not need a copyright declaration (although having one does help).  Blindly copying and pasting code is, therefore, a copyright violation.

Please do not copy code from websites unless they have an explicit license statement detailing a compatible license, OR, you have express written permission from the copyright holder to re-use their code in a way that is compatible with, or directly under, the terms of a compatible license.

Some reference terms and conditions:

* https://www.ycombinator.com/legal/ (search for the word "copyright")
* https://www.redditinc.com/policies/user-agreement-september-12-2021 (Section 05 "Your Content")
* https://slashdotmedia.com/terms-of-use/ (End of Section 6 and all of Section 7)
* https://docs.github.com/en/github/site-policy/github-terms-of-service#d-user-generated-content
* https://stackoverflow.com/help/licensing (Nice and simple)

See, also: https://tosdr.org/

Simply emailing the author of a copyrighted material, introducing yourself, explaining your desired usage of their material, and asking them politely to consider a FOSS/OSI license will often result in positive reciprocation.

## Code of Conduct

See [CODE_OF_CONDUCT](CODE_OF_CONDUCT.md)

## How to contribute

This isn't going to be an exhaustive Git or GitHub how-to.  That's documented far better elsewhere.

First, if you have larger changes in mind, [open an Issue](https://github.com/rawiriblundell/sh_libpath/issues/new) and let's discuss it.

If that discussion is resolved to our mutual satisfaction, or if you're going to submit something smaller, the next steps are:

Create a fork of the `main` branch.

Create your own branch from that e.g. `git checkout -b my_new_feature`

Work on your code improvements.  Try to make smaller commits rather than large ones.  This makes it easier to trace the process of the code's development.

When you're ready, put in a Pull Request with a small explanation of what you're submitting and why.

## Linting

All code must be parsed through [shellcheck.](https://www.shellcheck.net/)

Be aware that while Shellcheck is an excellent tool, it's not perfect.  Sometimes it can give false positive alerts.  If you do come across a scenario where it is wrong, you can disable an alert by using a `disable` directive.

```bash
# This function is sourced outside of this library, where it does parse args
# shellcheck disable=SC2120
foo() {
```

## Portability

This project will try to code on the more portable side.  Definitely not [strictly portable](https://www.gnu.org/software/autoconf/manual/autoconf-2.60/html_node/Portable-Shell.html), but at least in a way that it can be refactored up or down the portability scale as/when required.

Fundamentally speaking, our baseline is POSIX, plus named arrays as a minimum.  But let's not beat around the bush here: `bash` is going to be the first class citizen, and other shells?  Not so much.

`echo` is a portability nightmare.  Prefer `printf` instead.

`ksh` is actually a very good shell that is quietly installed in far more places than you'd expect, so consider targeting that.  If it runs in `ksh`, it'll likely run in `bash`.

Ubuntu's [DashAsBinSh](https://wiki.ubuntu.com/DashAsBinSh) wiki page can give you some ideas on more portable scripting, and `dash` is a readily available shell that you can test your code within. Do be aware that `dash` is stricter than our goals.

| :pushpin: Right now, my thinking is that we could have multiple library files with the same name, but with a shell specific extension i.e. `func.bash`, `func.zsh`, `func.sh`.  This way the most performant way to do something in a particular shell can be contributed, and all users of that shell benefit. |
| --- |

## Coding Style

Please look at some of the other code and try to be consistent with it.

Broadly we will try to use the same style as [ChromiumOS](https://chromium.googlesource.com/chromiumos/docs/+/HEAD/styleguide/shell.md)

Failing that, we will refer to the [Google Shell Style Guide.](https://google.github.io/styleguide/shellguide.html)

Any prescribed advice below supersedes the advice given in these two guides.

### Indendation and column width

Two or four space soft-tabs - whichever you prefer, just keep them consistent within each file.  Try to limit to 80 chars width, but up to 120ish is fine.

`do` and `then` go on the same line rather than the next.  The same applies for opening braces and parens.

Hard tabs are a hard no.

### Function names

Function names are in lower `snake_case()`.  Names should try to be meaningful, so if you're not sure, consider `verb_noun` style.  Microsoft has documentation for [approved verbs](https://docs.microsoft.com/en-us/powershell/scripting/developer/cmdlet/approved-verbs-for-windows-powershell-commands?view=powershell-7) for PowerShell that may provide some guidance.

Some style guides and other shell library projects use `class::function()` style naming, however `:` does not appear to be a portable character, so something like `__class_function()` may be preferable.

For helper functions that won't be used directly by a human, prepend it with a single underscore.

Do not use the `function` keyword.  It is non-portable and considered obsolete.

### Variables

Variables should generally be in lowercase, snake_case if possible.

Curly braces are used on `${arrays[@]}` and `${variable/modif/ications}`. For consistency, we use curly braces on normal variables too.

Curly braces around variables also improves readability when syntax colouring is not available. ${this_variable} stands out within this block of text, for example.

Exception: When you're in an arithmetic context e.g. `$(( time_metric + 10 ))`

Exceptions to the exception: If your var is an array element or requires transformation e.g.

```bash
$(( ${time_metrics[2]} + 20 ))
$(( ${10#time_metric} + 10 ))
```

Try, also, to use meaningful names. This is meaningless:

```bash
for f in $(lsblk -ln -o NAME); do
    ...
```

Whereas this is better:

```bash
for block_device in $(lsblk -ln -o NAME); do
    ...
```

This also reduces/eliminates unexpected in-scope collisions.

Exception: C-Style `for (( i=0; i<max_count; i++ )); do` style loops, as the var `i` is usually self-contained and is short-hand for 'integer' or 'iteration'

It's generally good, but a highly uncommon, habit to unset your variables once you're done with them.  We should aspire to do this where we can.

#### Typing

Variables in Linux/UNIX shells are untyped. `typeset` and `declare` and similar tools have been developed to bring some form of typing, but these are not portable solutions, so should be avoided.

If you need a variable to be of a specific type, the best advice right now is to validate it before you use it.

We do already have some code for this kind of validation.

#### Scoping

Shell uses dynamic scoping, which can really throw off a lot of people.  Practically speaking: it's not great.  But, with some simple practices, we can mitigate the potential issues caused by this.

Typically in a shell script you have 3, maybe 4 pseudo-scopes:

* Environment level (e.g. `$PATH`) / Shell (e.g. `$RANDOM`)
* Script level
* Function level

A lot of badly written articles imply that using UPPERCASE is a good thing.  It's best avoided if at all possible.

We practice psuedoscoping to minimise the chances of variables within scripts or functions from clobbering variables within the environment and vice versa.

Variables must be in the appropriate format for its "scope" as defined below:

#### Environment

We know from long-established convention that environment variables are almost always in UPPERCASE. You can see this in e.g. `bash` by running `set` and/or `printenv`.

We generally shouldn't need to put any variables into the environment, so you should avoid UPPERCASE as much as possible. If you do need a variable in the environment "scope" for whatever reason, namespace your variables by using a prefixed form like IDENTIFIER_VARNAME e.g. `MATH_SCRIPT_VERSION`

You might often see this "scope" referred to as the global scope, or shell scope. This scope also contains shell builtin variables.

#### Script

Variables in the script "scope" tend often to be mistakenly written in UPPERCASE, which gives rise to the possibility of clobbering a legitimate variable in the environment "scope". This can have results that are potentially hilarious, or potentially bad depending on your point of view.

For that reason, UPPERCASE variable names are strongly discouraged outside of the environment scope.

Instead, use lowercase, with underscores to separate words i.e. snake_case.

GNU Autoconf's documentation also states:

As a general rule, shell variable names containing a lower-case letter are safe; you can define and use these variables without worrying about their effect on the underlying system, and without worrying about whether the shell changes them unexpectedly.

#### local

`bash` and others allow you to define variables as local within a function e.g.

```bash
get_api_user() {
    local username
    username=Shelly
    ...
}
```

In library files that target a shell that supports this, please go ahead and use it.

If you are targeting a generic/portable library, please avoid this.  It's non-portable, and the workarounds are messy to say the least.  Our solution is to simply prepend any variables within a function with an underscore. We also unset the variable immediately prior to the function closure. For example:

```bash
get_api_user() {
    _username=Shelly
    ...
    unset -v _username
}
```

#### `RETVAL` variables

I think it might be useful to settle on a return value standard.  For example

```bash
function_name() {
  blah
  function_name_stdout
  function_name_stderr
  function_name_rc
}
```

#### Constants

_a.k.a. immutable variable_

Define a constant in its appropriate scope with `readonly`.  Define and set separately e.g.

```bash
my_variable="Polaris"
readonly my_variable
```

Variable pseudoscopes re-cap:
Environment: ${SH_UPPERCASE}
Script: ${meaningful_snake_case}
Function / Local: ${_underscore_prepended_snake_case} with unset -v
Constants: The appropriate above form set to readonly

### Compartmentalisation

I was just looking for an excuse to use that word.

One of the flaws - I think - with some of the other shell library projects, is that they get bogged down with too much re-use.  And so you get library upon library upon library dependant on one-another.  For example, one function supplied by this project is `puts()`, which fixes the mess of `echo` and the verbosity of `printf` for everyday use.  You'd think that such a function would be re-used throughout other library files, and you'd be wrong.

This practise should be heavily discouraged.

Each library file should be as self-contained as possible, and should try as much as possible not to require the inclusion of any other library.  This ultimately keeps the end-user interface simple, it ultimately keeps simple the core functionality of `include()`, it improves code re-use for derivative works, and it doesn't bog the codebase down with frustrating and highly obnoxious namespacing.

## The Unofficial Strict Mode

There is a lot of advice on the internet to "always use The Unofficial Strict Mode."

It is usually presented by its advocates as a brilliant one-time invocation that will magically fix every shell scripting issue. It is usually in a form similar to:

```bash
set -euo pipefail
```

The Unofficial Strict Mode is textbook [Cargo Cult Programming.](https://en.wikipedia.org/wiki/Cargo_cult_programming), and developers with less shell experience seem to love copying and pasting it, probably because the name gives them the illusion that it's some kind of `use strict`, which it isn't.  It's potentially more like `use chaos`.  It is non-portable, even within `bash` itself (as the behaviours of its various components have changed across `bash` versions), it replaces a set of well known and understood issues with a set of less known and less understood issues, and it gives a false sense of security.  Newcomers to shell scripting also fall into the trap of believing the claims of its advocates, to their potential peril.

`errexit`, `nounset` and `pipefail` are imperfect implementations of otherwise sane ideas, and unfortunately they often amount to being unreliable interfaces that are less familiar and less understood than simply living without them and curating defensive scripting habits. It's perfectly fine to *want* them to work as advertised, and I think we all would like that, but they don't, so shouldn't be recommended so blindly, nor advertised as a "best practice" - they aren't.

Some light reading into the matter:

* https://www.in-ulm.de/~mascheck/various/set-e/
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

A number of other library/framework/module projects use and advocate for it.  This project will not do that.

This project will nonetheless provide the capability, however, via a library named `strict.sh`.
