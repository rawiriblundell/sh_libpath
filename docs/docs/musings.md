This is a collection of design tensions that don't have clean resolutions —
cases where shellac's goals pull in opposite directions. They're worth
writing down rather than quietly deciding, because the same questions will
come up again.

---

## Abstraction depth: when to smooth over a wart

Shellac's purpose is to smooth over shell scripting warts and gotchas. But
shellac also wants to be approachable to newcomers, and a library with an
answer to every problem becomes its own problem.

A concrete example: `sort | uniq` versus `sort -u`.

The kneejerk cleanup is to collapse `sort | uniq` to `sort -u`. On GNU
systems that's fine. On Solaris and some older UNIX systems, `uniq -u` has
quirks — duplicates can slip through in ways that `sort | uniq` handles
correctly. So `sort | uniq` isn't sloppy; it's a portability choice with a
reason behind it.

The next thought is to encapsulate this into a `line_unique()` function that
detects the environment and picks the right behaviour. That's a reasonable
shellac instinct. But it's also a rabbit hole: once you start abstracting
every pipeline that has a portability footnote, you end up with a library
that wraps `sort`, `uniq`, `cat`, and eventually `ls`. At that point you've
rebuilt a compatibility layer, not a utility library.

The tension is:

- **Smooth over warts** — that's the point of shellac.
- **Don't abstract everything** — newcomers need to be able to read the
  code and recognise what's happening. A call to `line_unique` is opaque
  where `sort | uniq` is self-evident.
- **Don't silently change semantics** — collapsing `sort | uniq` to
  `sort -u` in a demo document implies they're equivalent. They mostly are,
  but writing it down as a "cleanup" papers over the reason the original
  author wrote it the way they did.

Where to draw the line is a judgement call made case by case. The heuristic
used here: abstract when the wart is invisible (the caller can't easily
detect it themselves), leave it alone when the pattern is readable and the
reason is documentable. `sort | uniq` is readable; the portability reason
belongs in a comment, not a function.
