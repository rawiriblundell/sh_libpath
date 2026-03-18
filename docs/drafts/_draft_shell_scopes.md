# Scopes within Bourne family shells

## TL;DR

In Bourne family shells, it's a good defensive practice to not use UPPERCASE variables unless/until you know *when* and *why* to use them.

Once you understand *when* to use UPPERCASE and *why* to use UPPERCASE, you will be at a point of your shell coding ability where you're not going to risk inadvertently breaking things.

Within your scripts, use lowercase variable names, preferably snake_case.

Within your functions, use `local` where possible to contain the function variables within the function itself.  Be mindful of [SC2155](https://www.shellcheck.net/wiki/SC2155).

## Preamble

Variable scoping in Bourne-family shells surprises programmers coming from other languages, and clobbering a reserved variable like `PATH` is a common and painful mistake.  This document covers the scoping model, the conventions that emerge from it, and the defensive practices that prevent those bugs.

## What are scopes

| :pushpin: This is not an exhaustive treatment — the topic is explored elsewhere to whatever depth you choose.  This is a high-level overview within a shell scripting context, deliberately avoiding the muddying/blurring of the definitions of scopes and namespaces.  The concepts are used here in a minimal, practical way. |
| --- |

The definition of a scope for the last 60+ years has been "the portion of source code in which a binding of a name with an entity applies".  That definition is in the context of lexical scoping, which we'll get to in a minute.

Scopes is fundamentally a programming concept where identifiers such as variables and functions are defined and accessible within a contained area.  You can think of them as a hierarchy of nested boxes, with a very basic example demonstrated like so:

```bash
+----------------------------------------------------------------------+
| Outside scope                                                        |
|                                                                      |
| FOO="hello"                                                          |
|                                                                      |
| +------------------------------------------------------------------+ |
| | Inside scope                                                     | |
| |                                                                  | |
| | BAR="world"                                                      | |
| |                                                                  | |
| +------------------------------------------------------------------+ |
+----------------------------------------------------------------------+
```

In the above example, `FOO` obviously resides in the Outside scope, and `BAR` obviously resides in the Inside scope.  In most programming languages, `BAR` is not accessible in the Outside scope, because it is ring-fenced within its own scope: in this case, `BAR` is only accessible within the Inside scope.

Because the Inside scope is, well, *inside*, it inherits from the Outside scope.  So `FOO`, from the Outside scope, is available within the Inside scope.

### Shell example

So for a shell example of the above inside/outside scope model, this might look something like:

```bash
#!/bin/bash

# Outside scope
FOO="hello"

# We print here to show the state of our vars
printf -- '%s!\n' "${FOO}, ${BAR}${BAZ}"

# Using a function to demonstrate the Inside scope
inside_scope() {
    local BAR
    BAR="world"
    BAZ="my baby, hello, my honey, hello, my ragtime gal"

    # We print here to show the state of our vars
    printf -- '%s!\n' "${FOO}, ${BAR}"
    printf -- '%s!\n' "${FOO}, ${BAR}${BAZ}"
}

# We call the function to get its output
inside_scope

# We print here to show the state of our vars
printf -- '%s!\n' "${FOO}, ${BAR}${BAZ}"
```

And the output would be:

```bash
# The first print, no vars set yet
hello, !
# The first printf within inside_scope
hello, world!
# The second printf within inside_scope
# Note that BAR=world here, so "${BAR}${BAZ}" emits "worldmy"
hello, worldmy baby, hello, my honey, hello, my ragtime gal!
# The last printf, showing that BAR is contained within inside_scope
hello, my baby, hello, my honey, hello, my ragtime gal!
```

So as we work through the script, we can see that `FOO` remains constant (and could be made so with `readonly`), and that `BAR` only works within the function `inside_scope()`, because we contain it *within* the function scope by using `local`.  But, for the sake of demonstration, we intentionally don't contain `BAZ` within the function scope, so that escapes out to the script scope.

### Lexical vs Dynamic scopes

Most modern programming languages (Python, JavaScript, Go) use **lexical scope** (a.k.a. static scope): a function can only access variables from its own scope and the scopes that enclose it *at the point it was written*, regardless of how it is called.

Bash uses **dynamic scope**: a function can access variables from any of its callers at runtime.  Without `local`, any variable a function sets is visible to everything that function calls, and any variable a caller has set is readable by the function — whether intended or not.

```bash
outer() {
    result="original"
    inner
    printf -- '%s\n' "${result}"  # prints "clobbered"
}

inner() {
    result="clobbered"  # no local — modifies outer's variable
}
```

This is the core reason `local` exists.  Declaring a variable `local` restricts it to the function that declares it, emulating lexical-scoping behaviour:

```bash
outer() {
    local result
    result="original"
    inner
    printf -- '%s\n' "${result}"  # prints "original"
}

inner() {
    local result
    result="clobbered"  # isolated to inner()
}
```

Dynamic scoping can be exploited deliberately — some patterns pass data between functions via shared variables rather than arguments — but accidental reliance on it is a common source of bugs.  The safe default is: always declare `local` for function variables.

## Problem

A classic example of this bug: a script author needed to save the current directory to return to it later.  Instead of using `pushd`/`popd` or a subshell, they saved the path to a variable with what seemed, at the time, perfectly reasonable:

```bash
PATH=`pwd`
```

In short: the script level variable over-rode (or "clobbered") the inherited global variable.

`PATH` defines the list of directories searched for executable commands.  A typical `/etc/environment` looks like:

```bash
PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin"
```

So let's say you try to run a command named `socks`, the shell will search the `PATH` looking for the first found match of the following:

- `/usr/local/sbin/socks`
- `/usr/local/bin/socks`
- `/usr/sbin/socks`
- `/usr/bin/socks`
- `/sbin/socks`
- `/bin/socks`
- `/usr/games/socks`
- `/usr/local/games/socks`
- `/snap/bin/socks`

(Technically it's more than that, but we'll set that discussion to the side.)

If the script was running in `/tmp`, that assignment sets `PATH=/tmp`.  The next call to `grep` sends the interpreter looking for `/tmp/grep`, which almost certainly does not exist.

This is not a rare mistake; examples appear regularly across the internet:

https://stackoverflow.com/questions/28310594/ls-not-found-after-running-read-path

There's also [this discussion](https://stackoverflow.com/questions/673055/correct-bash-and-shell-script-variable-capitalization) on this matter where you can find this comment:

>I didn't know this, and I just lost a couple hrs. over using `USER="username"` in a bash script automating some remote commands over ssh instead of `user="username"`. Ugh! Glad I know now!

## Best Practice

Very simply, by switching to the practice of lowercase variable names, we almost completely eliminate the risk of clobbering environment variables.

In other programming languages, you may find the use of scope rules.  These are used to minimise the possibility of inter-scope conflicts; so that a simple change in one part of a program doesn't explode the rest of the program.

While there are several levels of scope depending on your programming language choices, for Bourne family shells, there are essentially four:

- Global scope.  This encapsulates the following scopes:
  - Environment.  Usually exported and provided by the environment.  Example: `$PATH`
  - Shell scope.  Usually unexported and provided by the shell itself.  Example: `$RANDOM`
- Script scope
- Function scope

```bash
+----------------------------------------------------------------------+
| Global scope                                                         |
|                                                                      |
| FOO="hello"                                                          |
|                                                                      |
| +------------------------------------------------------------------+ |
| | Script scope                                                     | |
| |                                                                  | |
| | bar="world"                                                      | |
| |                                                                  | |
| | +--------------------------------------------------------------+ | |
| | | Function scope                                               | | |
| | |                                                              | | |
| | | local baz                                                    | | |
| | | baz="nice weather today"                                     | | |
| | +--------------------------------------------------------------+ | |
| +------------------------------------------------------------------+ |
+----------------------------------------------------------------------+
```

### An appeal to authority

[POSIX IEEE Std 1003.1-2008 section 8.1](https://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap08.html) specifies:

> Environment variable names used by the utilities in the Shell and Utilities volume of POSIX.1-2017 consist solely of uppercase letters, digits, and the <underscore> ( '_' ) from the characters defined in Portable Character Set and do not begin with a digit.
> ...
> The name space of environment variable names containing lowercase letters is reserved for applications. Applications can define any environment variables with names from this name space without modifying the behavior of the standard utilities.
> Note:
> Other applications may have difficulty dealing with environment variable names that start with a digit. For this reason, use of such names is not recommended anywhere.
> ....
> It is unwise to conflict with certain variables that are frequently exported by widely used command interpreters and applications

Through the use of naming conventions on top of the scopes that are present, we can enact a degree of "pseudo-scoping", and avoiding UPPERCASE variables at the script level is the simplest way to achieve this.  This gives us a four scope model:

- Shell: `UPPERCASE`
- Environment: `UPPERCASE`
- Script/File/Program: `lower_snake_case`
- Function: `lower_snake_case`, scoped locally with `local` or `typeset`

Within the script you can still change your env vars if you need to, and that falls under the guideline of knowing why and when to use UPPERCASE.  You can also interact with your shell vars e.g. `RANDOM=seed`.

Whether to call this namespacing is a definitional debate best set aside; this document uses the term pseudo-scoping to avoid conflating the two concepts.

For older shells that don't support `local`, a naming convention can approximate the same effect.  Pick a standard and stick with it e.g.

```bash
my_function() {
    local var
    var=blah
    printf -- '%s\n' "${var}"
}
```

Might instead look like this using underscore prefixed var names:

```bash
my_function() {
    _var=blah
    printf -- '%s\n' "${_var}"
    unset -v _var
}
```

Some people might even go to the effort of putting the function name into the vars e.g.

```bash
my_function() {
    my_function_var=blah
    printf -- '%s\n' "${my_function_var}"
    unset -v my_function_var
}
```

The provenance argument has merit, but the verbosity cost is high — it risks a PowerShell level of obnoxious noise.

And that gets us on to the next point.  There is another convention for avoiding variable collisions in the environment scope, and that's prefixing your vars.  Again, if you want to refer to this as namespacing, that's up to you and your interpretation of scopes vs namespaces.  But let's say, for example, you have a service named `pants` and a few scripts that interact with it e.g. `pants-ctl`, `pants-log` etc.  You might have a `.pantsenv` file that when imported to the environment, sets the following env vars:

```bash
PANTS_VAR1=foo
PANTS_VAR2=bar
PANTS_VAR3=baz
```

With those set in your environment, your `pants-*` scripts will inherit and work with them.  `aws-cli` is a good example of this, with its various `AWS_*` environment variables.

The whole point is to use rational and consistent naming practices to provide pseudo-scoping to minimise or eliminate the risk of clobbering existing environment variables.  It's simply a good, defensive coding practice.
