# jsonprint.sh

A shell function library to assist with formatting shell script output in json.

## Pre-emptive FAQ

Let's get real.  Nobody is asking any questions at all, let alone frequently.

This is, therefore, a *pre-emptive* FAQ where I guess what you'll ask.

### What is it?

`jsonprint.sh` is a function library that you source into your shell scripts.
You can then use its functions to format your outputs into a json structure.

It is similar to the python based project, [jc](https://github.com/kellyjonbrazil/jc),
and can do similar work, but it can also serve a different purpose.  Namely
portable shell scripting and representing desired information, rather than
rewriting the output of existing commands as `jc` seems to be focused on.

### What isn't it?

* A tool that will magically take any input and figure it all out for you
* A tool that is full of input validation and hand-holding
* Robust, stable, performant, a smart idea
* Something you should use if you can avoid it

### Why is it?

For quite a while I have been wondering about what various UNIX utilities would
look like if they had some kind of `--json` option, which could remove some
degree of fragility from shell scripting if paired up with something like `jq`.

I've had a career full of fixing other people's shell scripting disasters.
I have fixed a lot of fragile code that, for any of a number of reasons, won't
ever be rewritten into another language.  I have fixed code where the
"glue language" nature of shell makes it _really_ the right tool for the job.
A lot of this would be more robust if we could simply deal with a structured
format like json within the glue language model, rather than praying to extract
something reliably from an often baroque pipeline sequence.

And there are often times when shell is just what you're forced to use, for
better or worse, and for a wide range of reasons, so we may as well try to make
the best of it for those situations.

I know that this won't exactly take off and be a thing, but one afternoon,
for my own amusement, I started writing a few functions.  And it wound up being
a lot easier than I expected to both curate and use.  And so here we are.

I also agree with people on both sides of the fence about `jc`, and many of the
same arguments very likely apply here:

* https://www.reddit.com/r/linux/comments/fd2z8m/jc_v180_released_jsonify_your_cli/fjjgjga/
* https://blog.kellybrazil.com/2019/11/26/bringing-the-unix-philosophy-to-the-21st-century/

### Are you aware of "${project}"?  Why don't you just use that?

This is my rifle.  There are many like it, but this one is mine.

### Examples

For a basic example, let's emit the load average of the system.  Consider this
block of `bash` code, with comments removed:

```bash
include ../lib/jsonprint.sh

get_epoch() {
  if date -u '+%s' | grep '%s' >/dev/null 2>&1; then
    printf -- '%s\n' "null"
  else
    date -u '+%s'
  fi
}

get_uptime_output() {
  uptime | sed -n -e 's/^.*load average: //p'
}

if [[ -r "/proc/loadavg" ]]; then
  read -r one_min five_min fifteen_min _ _ < /proc/loadavg
else
  IFS=', ' read -r one_min five_min fifteen_min < <(get_uptime_output)
fi

json_open
  json_open_obj load_average
    json_num 1min "${one_min}"
    json_append_num 5min "${five_min}"
    json_append_num 15min "${fifteen_min}"
    json_append_num utctime "$(get_epoch)"
  json_close_obj
json_close
```

*(Refer to `bin/json_loadavg` for latest full code with comments)*

This is what the output looks like:

```bash
▓▒░$ bash json_loadavg
{"load_average": {"1min": 0.6, "5min": 0.97, "15min": 1, "utctime": 1583097518}}
```

This is what the output looks like when pretty printed via `jq`, you can see
how the indentations match up with how I've indented the code above:

```bash
▓▒░$ bash json_loadavg | jq -r '.'
{
  "load_average": {
    "1min": 0.6,
    "5min": 0.97,
    "15min": 1,
    "utctime": 1583097520
  }
}
```

*(**n.b** Indenting the function calls as shown isn't necessary,*
*but it adds to readability IMHO)*

`json_open()` simply prints `{`

`json_open_obj()` will open an object, in this case we have given it an argument,
so it will generate `"load_average": {`

We have previously gathered our statistics and put them into variables, so it's
a simple matter of calling each function and feeding those variables in.

We know each value is going to be a number, so we call `json_num()` and give
it our first key value pair for the one minute average, with the key `1min` and
the value `"${one_min}"`.  This will give the output:

```bash
"1min": 0.6
```

We know that the next key value pairs will be stacked onto this, so we call
`json_append_num()` for those extra entries.  This function differs from
`json_num()` in that it prepends a comma and space, giving us:

```bash
"1min": 0.6, "5min": 0.97
```

Subsequent invocations of `json_append_num()` will continue to stack keyvals.

*(**n.b** `json_num()` and `json_append_num()` will detect if the shell*
*variables are blank and in that situation will output `null`.)*

`json_close_obj()` simply prints `}`

`json_close()` simply prints `}`

---

For a very slightly more advanced example, let's take the formatting of `uname`
and json-ify it.  Because `uname` does not natively give out safely parsable
output, we do have to make multiple calls to it, which is unfortunate and
annoying, but relatively low impact.

Here's the code, without comments:

```bash
include ../lib/jsonprint.sh

json_open
  json_open_obj uname
    json_str nodename "$(uname -n)"
    json_append_str os_kernel "$(uname -s)"
    uname -o >/dev/null 2>&1 && json_append_str os_name "$(uname -o)"
    json_append_str os_version "$(uname -v)"
    json_append_str release_level "$(uname -r)"
    json_append_str hardware_type "$(uname -m)"
    uname -i >/dev/null 2>&1 && json_append_str platform "$(uname -i)"
    uname -p >/dev/null 2>&1 && json_append_str processor "$(uname -p)"
  json_close_obj
json_close
```

*(Refer to `bin/json_uname` for latest full code with comments)*

This is what the output looks like when pretty-printed via `jq`, you can see
how the indentations match up with how I've indented the code above:

```bash
▓▒░$ bash json_uname | jq -r '.'
{
  "uname": {
    "nodename": "minty",
    "os_kernel": "Linux",
    "os_name": "GNU/Linux",
    "os_version": "#30~18.04.1-Ubuntu SMP Fri Jan 17 06:14:09 UTC 2020",
    "release_level": "5.3.0-28-generic",
    "hardware_type": "x86_64",
    "platform": "x86_64",
    "processor": "x86_64"
  }
}
```

`json_open()` simply prints `{`, and likewise, `json_close()` simply prints `}`

`json_open_obj()` will open an object, in this case we have given it an argument,
so it will generate `"uname": {`

We have selected the nodename to be our first key value pair, and we know that
the value will be a string, so we call `json_str()` with the args `nodename` and
`"$(uname -n)"`.  This will give the output:

```bash
"nodename": "minty"
```

We know that subsequent key value pairs will be stacked onto this, and the
values will be strings, so we call `json_append_str()` for those extra entries.
This function differs from `json_str()` in that it prepends a comma and space,
giving us:

```bash
"nodename": "minty", "os_kernel": "Linux"
```

Subsequent invocations of `json_append_str()` will continue to stack keyvals.

Some versions of `uname` support options that may be nice to have, so we use
idioms like `uname -o >/dev/null 2>&1 && json_append_str os_name "$(uname -o)"`
That is to say:  If `uname -o` works, then generate e.g.
`"os_name": "GNU/Linux"`, otherwise, if `uname -o` doesn't work, then don't do
anything here.  This kind of idiom allows us to script portably, but to also
throw in GNU-ish nice-to-haves when and where we decide it's appropriate.

More advanced examples are available in the `bin/` directory.

### Why not a 'real' language? [insert smug face here]

In my professional past, I have worked on rusty-iron commercial unix machines
that do not have the likes of `python` or even `perl`.  Yes, seriously.  And,
even if they had one or both of these, they'd be ancient versions and very
likely devoid of their respective json modules.

There's also the wee issue of very-lightweight containers where the likes of
`python` might be strictly verboten.

You know what will *always* be there?  A POSIX compliant shell.

Almost always, this is [some variant of `ksh`.](https://www.in-ulm.de/~mascheck/various/shells/)

While this project is *really* for my own amusement, there are, for better or
worse, practical applications.  Perhaps you've got some small monitoring script
that you want to output in json format, but firing up a `python` instance is
really overkill.  Who knows?

### [insert different face here] But... but... my 'real' language

Yeah, I get it.  You might like to take a look at the very promising [oil shell.](http://www.oilshell.org/)

And read some of the [robust](https://news.ycombinator.com/item?id=16154438)
[discussions](https://news.ycombinator.com/item?id=22150603) around it.

Then give it your time and attention.  If you want to.

### I'm still upset and want a 'real' language [insert angry face here]

[I've got so much respect for you](https://www.youtube.com/watch?v=sl8uPLRN4kw)

### Why would you want to deal with json in shell at all?  That's nuts

I agree, it is a bit nuts.  Mostly for interactive use where throwing glue into
streams is fine.  But for shell scripting itself, you really want as much
robustness as you can get your hands on.

Consider this:  Experienced practitioners of the Unix shell are familiar
with its myriad warts, syntax oddities and edge cases.  One of the most classic
of which is the parsing `ls` trap.

`ls` is great for interactive use, where you need human readable output.

`ls` is also among the worst things for shell scripting.

Many newbie shell scripters will try to write code where they pluck details out
of `ls`, usually with some inefficient code like:

```bash
PERMISSIONS=`ls -la $FILE | cut -d ' ' -f1`
OWNER=`ls -la $FILE | cut -d ' ' -f3`
GROUP=`ls -la $FILE | cut -d ' ' -f4`
FILENAME=`ls -la $FILE | cut -d ' ' -f9-`
```

There's a number of problems here.

* UPPERCASE variables.  For Kildall's sake, just stop it.
  * Shell doesn't have strict scoping/namespacing
  * That said, UPPERCASE is, *de facto via convention*, the "global" scope
  * In other languages, clobbering the global scope is _strongly_ discouraged
  * We should adopt good habits/practices from other languages where possible
  * Ergo:  **Don't use UPPERCASE unless you know why you need to**
  * _There are, annoyingly, exceptions to the rule.  Like `$http_proxy`_
* Backtick command substitution.  I'm damn near 40.  This crap was superseded
  by `$()` when I was soiling nappies.  Just stop it.
  * Unless you're writing SVR4 `sh` package scripts for Solaris packages.  Ugh.
* Unquoted variables.  `shellcheck` is going to have kittens!
* Multiple avoidable calls to an external program
* Because date/timestamps might be different, there's no guarantee that the
  filename will be at the suggested field.  I've seen an attempt at working
  around this with a double invocation of `rev` e.g.
  `ls -la $FILE | rev | cut -d '' -f1 | rev`
  ...or something similarly nonsensical
* Then you've got whitespace-in-filename challenges
* Alternatively, you could use non-portable `awk {gsub(marine)}` soup
* It's an unspoken golden rule of shell scripting:
  Do not [parse ls](https://mywiki.wooledge.org/ParsingLs).

A slightly saner approach to this example might look something more like

```bash
while read -r; do
  set -- "${REPLY}"
  fsobj_mode="${1}"
  fsobj_owner="${3}"
  fsobj_group="${4}
  shift 8
  fsobj_name="${*}"
done < <(ls -la "${fsobj}")
```

Of course this is still prone to errors like date/timestamp vs locale issues.

In a json structure, these problems go away somewhat e.g:

```bash
▓▒░$ bash json_ls | jq -r '.[env.PWD][] | select(.fileName=="json_uname")'
{
  "fileName": "json_uname",
  "fileOwner": "rawiri",
  "fileGroup": "rawiri",
  "fileMode": 664,
  "sizeBytes": 919,
  "fileModified": 1582941110,
  "fileAccessed": 1582941111,
  "fileType": "regular file",
  "dereference": "json_uname"
}
```

And the greatest part?  We can build that structure using `stat`, and stay well
clear of `ls`.

Why *wouldn't* you want that kind of improvement for shell scripting?

### What about json's special characters?

Sure.  So what you're getting at is edge cases like "newlines in a filename".

`jsonprint.sh` provides a function, `json_escape_str()` which handles this.
It is currently not plumbed in to any other function and only works when
manually called.  The example script, `json_ls`, uses this function, and it's
_mostly_ there:

```bash
▓▒░$ touch "$(printf "foo\n-rw-r--r-- 1 skeeto skeeto 0 Feb  6 15:49 bar")"
▓▒░$ ls -la
total 44
drwxr-x--- 2 rawiri rawiri  258 Mar  2 22:58  ./
drwxr-x--- 5 rawiri rawiri   72 Feb 29 14:50  ../
-rw-r----- 1 rawiri rawiri    0 Mar  2 22:58 'foo'$'\n''-rw-r--r-- 1 skeeto skeeto 0 Feb  6 15:49 bar'
```

...

```bash
▓▒░$ bash json_ls | jq -r '.'
{
  "/home/rawiri/git/jsonprint/bin": [
    {
      "fileName": "foo\n-rw-r--r-- 1 skeeto skeeto 0 Feb  6 15:49 bar",
      "fileOwner": "rawiri",
      "fileGroup": "rawiri",
      "fileMode": 640,
      "sizeBytes": 0,
      "fileModified": 1583143088,
      "fileAccessed": 1583143088,
      "fileType": "regular empty file",
      "dereference": "foo$\n-rw-r--r-- 1 skeeto skeeto 0 Feb  6 15:49 bar"
    },
```

*(This example edge case was from a reddit discussion for `jc`.*
*Further down this page is a description about how this function works.*)

### How about spaces in key names?

Yeah, this is where shell bites us in the ass a bit.

For the sake of portability and simplicity, these functions work directly on
their positional parameters, and we don't depend on `getopt` or `getopts`.

While I _could_ implement something like e.g.

```bash
json_str -k lots of words here -v somevalue
```

That would be more complicated than it needs to be.

Until something more elegant becomes obvious, for the moment, you can use
something like this:

```bash
json_num "\"${key}\"" "${value}"
```

This will deliver `${key}` with literal double-quotes, which are stripped by the
functions.  E.g this line from `vmstat -s`:

```bash
15375000 K total memory
```

Via a little juggling and then fed into `json_num()` as above, becomes this:

```bash
"K total memory": 15375000,
```

Or you can sanitise your key names - swap spaces for underscores for example.

If you _don't_ put in those literal double quotes, the function will essentially
work like:

```bash
json_num K total memory 15375000

$1=K
$2=total

I'm validating my inputs, and "total" is not a number, it's exception time...
```

### What are the main problems with this, apart from, you know, everything else?

Apart from everything else?  Right now, the main gotcha is handling the logic
around an unknown number of inputs when looping.

Say you're looping over some lines and formatting it into key value pairs.  For
the sake of demonstration, we'll use four lines of input.

If you ran this blindly through a formatting function, this might come out like:

```bash
{"a": "b", "c": "d", "e": "f", "g": "h",}
```

The issue is very subtle - there is a trailing comma on the last pair.  That's
going to break things.

To get around this, I've naturally tried out a number of approaches.  Perhaps
the simplest is to use one of the append functions and a single-use variable to
track how many times you've gone through a loop.  For example

```bash
loop_iter=0
json_open_obj
  while read -r _key _value; do
    if (( loop_iter == 0 )); then
      json_str "${_key}" "${_value}"
      (( loop_iter++ ))
    else
      json_append_str "${_key}" "${_value}"
    fi
  done < <(some_input)
json_close_obj
```

If we step through this, we open an object with `json_open_obj()`, which produces:

```bash
{
```

Next, we read into `_key` and `_value`, then test whether `loop_iter` is 0.  
If it's 0, then we're on our very first run through the loop, and so we need to
use `json_str()` (because the value `b` is a string, duh).  This, combined with
`json_open_obj()` gives us:

```bash
{"a": "b"
```

Then we iterate `loop_iter` up by one, making it equal to `1`.

If that's the only keypair to be generated, then the loop finishes, there's no
trailing comma, and all is well.  `json_close_obj()` is called, and we get:

```bash
{"a": "b"}
```

If there's more keypairs to be generated, because `loop_iter` is now `1`, we
switch over to `json_append_str()`.  So the next line of input would be
generated like (note the preceding comma and space):

```bash
, "c": "d"
```

Meaning a stacked output of:

```bash
{"a": "b", "c": "d"
```

There is no trailing comma, so it can be safely closed at any point.  And as we
loop through the input, we simply stack our key value pairs this way.
After a full run through, we have:

```bash
{"a": "b", "c": "d", "e": "f", "g": "h"}
```

And for the most part this works, I just haven't thought of a cleaner way to
handle this (yet?)

### I'm looking at the code, why aren't you using local variables?

Not all shells support the `local` keyword/scope.  So as a convention, I use
underscore prepended variables and explicitly `unset` them at the end of
each function.  Or I should be doing that.

This means that the library itself is more readily portable, and if it's not
immediately portable to a certain bourne-family shell, then it shouldn't be much
effort to update it.

The downside is that if a function exits mid-flight, there's no trapping to
ensure that the variables are unset.  But if this happens, we probably have a
bigger issue to investigate.

BUT, if your script(s) that you source this into support a `local` scope, go
ahead and use that capability - and you probably should.

## List of Functions

All functions start with `json_`, even when this may seem weird.  I might change
that standard in the future to something like `jprint_` or `printj_`.  Or not.

I originally provided both `json_[thing]_append` style and `json_append_[thing]`
functions.  This wass the case for all `_open`, `_close` and `_append` functions.

This meant a lot of duplicated code and related maintenance overheads.

I've elected to use the `json_[open|close|append]_[thing]` format.

### json_die()

This function prints an exception message to stderr and immediately exits.
It is our variant of `die()`.

It has an equivalent counterpart: `json_exception`.

### json_open()

Very simply prints a curly opening bracket: `{`

Would normally be used to denote the opening of a block of json.

### json_close()

The opposite of `json_open`.  It prints: `}`.

### json_comma()

This function literally prints a `,`, just in case you need one of those.

### json_decomma()

This function removes a trailing comma from its input.  This is from when the
library was structured differently, but may still be of some use.

### json_require()

**Args:** (Required).  Any number of paths to files or command names.

**Example:** `json_require /proc/cpuinfo lscpu`

If your script requires a file (or files) or a command (or commands), then you
can use `json_require()` to check the existence of these.

Failure will emit a message like:

```bash
{ "Warning": "the_thing not found or not readable" }
```

And the function will also invoke `exit 1`.  This means that you should use this
basically immediately after sourcing the library, so that your code fails early.

This obviously cannot test for a particular version or type of a command, but
that might be nice e.g. `json_require gnu-tar`

### json_gettype()

**Args:** (Required).  One string.

**Example:** `json_gettype 0.05`

This function attempts to determine the "type" that a particular value is.  It
emits a determination from the following list:

* float
* int
* bool
* string

Floats and Integers are obvious.  Booleans are determined, case insensitive,
from the following values:

* on
* off
* yes
* no
* true
* false

Everything else is classed as a string.

The purpose of this function is to allow you to determine which output function
to select, for example:

```bash
case $(json_gettype "${_value}") in
  (int|float) json_append_num "${_key}" "${_value}" ;;
  (bool)      json_append_bool "${_key}" "${_value}" ;;
  (string)    json_append_str "${_key}" "${_value}" ;;
esac
```

See, also, `json_auto()` and `json_append_auto()`

### json_open_arr()

**Args:** (Optional).  One string.

**Example:** `json_open_arr jboss_server_stats`

This function opens an array block and accepts an optional arg.

If no argument is supplied, it simply outputs:

```bash
[
```

If an argument is supplied, it outputs:

```bash
"arg": [
```

### json_close_arr()

**Options:** `-c` or `--comma`.  When selected, this emits a trailing comma.

The opposite of `json_open_arr()`.  It prints: `]`.

If used with `-c` or `--comma`, it prints `],`.  This is the opposite approach
to the `_append` functions.

### json_append_arr()

**Args:** (Optional).  One string.

**Options**: `-n` or `--no-bracket`.
              When selected, this omits the leading bracket.

**Example:** `json_append_arr jboss_application_stats`

This function appends an array to another array.  It emits the closing block for
the previous array, the comma seperator, and then opens the new array.

If no argument is supplied, it simply outputs:

```bash
],[
```

If an argument is supplied, it outputs:

```bash
], "arg": [
```

If `-n` or `--no-bracket` is specified, the leading bracket is omitted i.e.
the output becomes either:

`,[`

or

`, "arg": [`

### json_open_obj()

**Args:** (Optional).  One string.

**Example:** `json_open_obj jboss_queue_stats`

This function opens an array block and accepts an optional arg.

If no argument is supplied, it simply outputs:

```bash
{
```

If an argument is supplied, it outputs:

```bash
"arg": {
```

### json_close_obj()

**Options:** `-c` or `--comma`.  When selected, this emits a trailing comma.

The opposite of `json_open_obj()`.  It prints: `}`.

If used with `-c` or `--comma`, it prints `},`.  This is the opposite approach
to the `_append` functions.

### json_append_obj()

**Args:** (Optional).  One string.

**Options**: `-n` or `--no-bracket`.
              When selected, this omits the leading bracket.

**Example:** `json_append_obj jboss_memory_stats`

This function appends an object to another object.  It emits the closing block
for the previous object, the comma seperator, and then opens the new object.

If no argument is supplied, it simply outputs:

```bash
},{
```

If an argument is supplied, it outputs:

```bash
}, "arg": {
```

If `-n` or `--no-bracket` is specified, the leading bracket is omitted i.e.
the output becomes either:

`,{`

or

`, "arg": {`

### json_escape_str()

**Args:** (None).  This functions reads stdin from a pipe.

**Example:** `somecommand | json_escape_str`

Some characters in json must be escaped.  A lot of advice at the better end of
a google will center around using `perl` or `python` to do this.  If we assume
that, then we may as well just use `perl` or `python` for everything else.
Right?!

So this function converts its stdin into a single column of octals.  Then it
finds any undesirable octals and prints an escaped replacement.

This might be computationally expensive, so try to avoid it if you can.  I have
not undertaken any performance testing, so OTOH it may well be reasonable.  YMMV.

### json_str()

**Args:** (Required).  Two args: Key and Value.  If the value is blank or
literally 'null', we return `null` (unquoted)

**Options:** `-c` or `--comma`.  When selected, this emits a trailing comma.

**Example:** `json_str CPU_Model "${cpu_model}"`

This function formats a string key value pair, in the format: `"key": "value"`.
String values are quoted.

If used with `-c` or `--comma`, it prints `"key": "value",`.
This is the opposite approach to the `_append` functions.

### json_append_str()

As per `json_str()`, it just drops the `-c`/`--comma` options, and pre-pends a
comma i.e. `, "key": "value"`.  It otherwise behaves exactly the same.

### json_num()

**Args:** (Required).  Two args: Key and Value.

**Options:** `-c` or `--comma`.  When selected, this emits a trailing comma.

**Example:** `json_num Memory "${memory_value}"`

This function formats a number (int or float) key value pair, in the format:
`"key": value`.  Numerical values are unquoted.

The value is validated to ensure that it is an integer or float, if it isn't,
an exception will be thrown and the script will exit via `json_die()`.

Leading zeroes are not allowed in json as they can be interpreted as octal, so
this function strips them as well.  In order to handle this and floats, we use
`printf`'s float format rather than the signed decimal format specified in the
json spec.

If used with `-c` or `--comma`, it prints `"key": value,`.
This is the opposite approach to the `_append` functions.

### json_append_num()

As per `json_num()`, it just drops the `-c`/`--comma` options, and pre-pends a
comma i.e. `, "key": value`.  It otherwise behaves exactly the same.

### json_bool()

**Args:** (Required).  Two args: Key and Value.

**Options:** `-c` or `--comma`.  When selected, this emits a trailing comma.

**Example:** `json_bool interfaceActive True`

This function formats a boolean true/false key value pair, in the format:
`"key": value`.  Boolean values are unquoted.

The value is validated to ensure that it is one of a recognised set of options.
If it isn't, an exception will be thrown and the script will exit
via `json_die()`.

The list is as follows:

* on
* off
* yes
* no
* true
* false

These are recognised in a case-insensitive manner, and converted to their
respective `true` or `false` forms in lowercase.

If used with `-c` or `--comma`, it prints `"key": value,`.
This is the opposite approach to the `_append` functions.

### json_append_bool()

As per `json_bool()`, it just drops the `-c`/`--comma` options, and pre-pends a
comma i.e. `, "key": value`.  It otherwise behaves exactly the same.

### json_auto

**Args:** (Required).  Two args: Key and Value.

**Example:** `json_auto interface eth0`

This function attempts to use `json_gettype()` to automatically determine how
to address the value that is given to it.  It is currently untested, but in
theory it should work just fine.

### json_append_auto

**Args:** (Required).  Two args: Key and Value.

**Example:** `json_append_auto interface eth0`

This function attempts to use `json_gettype()` to automatically determine how
to address the value that is given to it.  It is currently untested, but in
theory it should work just fine.

### json_from_dkvp()

NOTE: Work In Progress.  Do Not Use

This function takes a comma or equals delimited key-value pair input and emits
it in a way that can be used by e.g. `json_str()`

**Example:** a variable named `line` that contains `Bytes: 22`

```bash
json_num $(json_from_dkvp "${line}"
"Bytes": 22
```

The intent with this function is to loop through a series of
delimited key value pairs (i.e. dkvp) and to restructure them slightly
into a json-friendly visage.

### json_foreach()

**Args:** (Required).  Any number of key value pairs all in one line.

**Options:** `-n` or `--name`.  When selected, this gives the surrounding
             object a name.

**Example:** `json_foreach key1 value1 key2 value2 .. keyN valueN`

This function takes any number of parameters and blindly structures every pair
in the sequence into json keypairs, within an optionally named object structure.

If the option `-n` or `--name` is used, the object is given a name e.g.

`json_foreach --name cpu_details Brand Intel Model Pentium-D MHz 2100`

Will be printed as

`"cpu_details": {"Brand": "Intel", "Model": "Pentium-D", "Mhz": 2100}`

If the object name option is not used, then the object simply isn't named.

The key is stripped of any trailing instance of `:` or `=` and both the key
and value are trimmed of whitespace either side of them.

The value type is then determined via `json_gettype()` and the appropriate
output function selected and used.

Finally, the object is closed.

This object is structured in isolation.  If you want to append it to something,
you might use `json_comma()` before invoking this function.

There is no major input validation here, you must ensure that the input is sane.

### json_readloop()

This is a test function for reading input line-by-line and automatically
figuring out how to address its inputs.  Untested.  Will likely change.

Similar to `json_foreach()`, but it reads line by line rather than addressing
a sequence of positional parameters...

### json_timestamp()

This function is intended for situations where timestamping an object may be
required or useful.  For example: you're presenting metrics that require some
kind of timestamp, usually this would be for tracked series data and similar.
Or you're outputting data that needs a timestamp to compare to - a file mtime
(in epoch format) vs the current epoch, for example.

This is a way of expressing "these are the facts _as at_ time index xyz"

It calls `json_append_obj() --no-brackets`, so it _must_ be run after a close
function like `json_close_obj` or `json_close_arr`.  It then outputs its
information, and then calls `json_close_obj()`.

It outputs either of the following formats:

```bash
, "timestamp": {"utc_epoch": 1583137512}
```

Or, for systems that don't support `date +%s`:

```bash
, "timestamp": {"utc_YYYYMMDDHHMMSS": 20200302100832}
```

In real life usage, it looks like this:

```bash
▓▒░$ bash json_loadavg | jq -r '.'
{
  "load_average": {
    "1min": 2.64,
    "5min": 2.22,
    "15min": 2.02
  },
  "timestamp": {
    "utc_epoch": 1583142468
  }
}
```

## More resources

In no particular order:

* https://json.org
* https://stedolan.github.io/jq/
* https://jqplay.org/
* https://github.com/antonmedv/fx
* https://github.com/jpmens/jo
* https://github.com/Juniper/libxo
* https://github.com/kellyjonbrazil/jc
* https://github.com/dylanaraps/nosj
