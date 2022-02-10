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

Code that is published on a website is almost always the copyright of its author, or the website owner, depending on the site's terms and conditions.  Copyright is also automatic from the moment a work is created.  Blindly copying and pasting code is, therefore, a copyright violation.

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

## Coding Style

Please look at some of the other code and try to be consistent with it.

### Portability

This project will try to code on the more portable side.  Perhaps not strictly portable, but at least in a way that it can be refactored up or down the portability scale as/when required.

Fundamentally: POSIX plus named arrays as a minimum.

### Compartmentalisation

I was just looking for an excuse to use that word.

One of the flaws - I think - with some of the other shell library projects, is that they get bogged down with too much re-use.  And so you get library upon library upon library dependant on one-another.  For example, one function supplied by this project is `write()`, which fixes the mess of `echo` and the verbosity of `printf` for everyday use.  You'd think that such a function would be re-used throughout other library files, and you'd be wrong.

This practise should be heavily discouraged.

Each library file should be as self-contained as possible, and should not require the inclusion of any other library.  This ultimately keeps the end-user interface simple, it ultimately keeps the core functions of `import()` and `from()` simple, it improves code re-use and derivative works, and it doesn't bog the codebase down with frustrating and highly obnoxious namespacing.


### Scoping variables

`local`

As much as I'd love to use this, [it's a mess out there](https://unix.stackexchange.com/questions/493729/list-of-shells-that-support-local-keyword-for-defining-local-variables)

So instead of using `local`, the preference will be to pseudoscope.

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

A number of other library/framework/module projects use and advocate for it.  This project will not do that.

This project will provide the capability, however, via a library named `strict.sh`.
