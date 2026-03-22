Shellac is developed using Claude Code (Anthropic's CLI tool for Claude) as a
collaborative pair. This page documents how that collaboration works and what
guides it — both to be transparent about the process and because the approach
itself reflects shellac's values: clear conventions, explicit contracts, no
magic.

---

## What we've worked on together

The AI involvement spans the full development lifecycle rather than isolated
tasks:

- **Library implementation** — writing, reviewing, and refining functions
  across modules (`crypto/`, `net/`, `ssl/`, `array/`, `text/`, `numbers/`,
  `fs/`, `git/`) following the project's naming conventions and shdoc
  annotation format
- **Bug finding and fixing** — catching latent issues like the `ssl_view_cert`
  `state` case passing the cert file path to `openssl -checkend` instead of a
  seconds threshold (`${2:-0}` → `${3:-0}`)
- **Capability audits** — surveying candidate functions from similar projects
  (`bash-oo-framework`, `bash-oop`, `bash-toml`, and others), classifying them
  by license, reviewing for clean-room implementation candidates, and raising
  GitHub issues for the accepted ones
- **Coverage gap analysis** — comparing shellac's 750+ functions against the
  standard libraries of Python, Ruby, Go, and Node.js to identify meaningful
  gaps worth filling
- **Documentation** — writing `shellac_in_practice.md` (two real scripts
  rewritten side-by-side), `musings.md` (design tensions that don't have clean
  resolutions), and structural docs like `.pages` nav ordering
- **GitHub issues** — drafting and filing issues for new modules, with
  counterparts in other languages documented for context
- **MkDocs configuration** — adding `md_in_html` for side-by-side code layout
  in documentation

---

## How the collaboration works

The working pattern is closer to senior-developer/technical-lead than
autocomplete. Concrete examples:

- When asked to suggest candidates from third-party libraries, the AI reviewed
  licenses, cloned repos, identified functions worth considering, and presented
  a categorised list for the human to accept or reject — rather than silently
  importing anything
- When the AI suggested cleaning up a `sort | uniq` pipeline, the human surfaced the
  portability reason behind it (Solaris `uniq` quirks) rather than collapsing
  it to `sort -u`, and the conversation produced `musings.md` instead
- When a suggested refactor would have changed semantics (the `shellac_in_practice.md`
  loading pattern), the AI caught it and corrected its own draft

The human sets direction, makes final calls on what to accept, and owns the
codebase. The AI does research, drafts, flags tradeoffs, and surfaces things
worth knowing — but does not make unilateral decisions about design. AI is used as a
collaborative tool, not a copy-and-paste crux.

---

## What works well

- **Explicit conventions** — the shell scripting standards and naming
  conventions give the AI a clear target. It doesn't have to guess the
  preferred style for `local` declarations, case statement formatting,
  `printf` vs `echo`, or variable naming.
- **Tight feedback loops** — short exchanges ("yes, do it", "skip those",
  "that's already covered by X") keep the work moving without over-explaining.
- **GitHub Issues as session continuity** — AI sessions have no persistent
  memory of prior work beyond what's in the codebase and standing instructions.
  GitHub Issues fill that gap: accepted candidates, planned modules, and
  outstanding work are filed as issues so the next session can pick up where
  the last left off without relying on conversation history. The issue tracker
  is the shared backlog, not the AI's recall.
- **Asking before doing** for anything that touches shared state (GitHub
  issues, commits, external writes)
- **Surgical changes** — the AI is instructed to touch only what was asked,
  not to "improve" adjacent code or add unrequested features. When changes
  create orphaned imports or dead code, those get cleaned up; pre-existing
  issues get mentioned but not silently deleted.

---

## Productivity metrics

These figures were calculated at the 10-day mark of collaboration (2026-03-12
to 2026-03-21) and are intended as a honest, methodology-transparent estimate
rather than marketing copy.

### What was delivered

| Category | Detail |
|----------|--------|
| Commits | 214 in 10 active days |
| GitHub issues opened | 28 (nos. 32–59) |
| GitHub issues closed | 19 — bugs, style sweeps, audits, rename, tests, standardisation passes |
| Functions in codebase | 734 unique |

Work covered in that period: targeted bug fixes in three files; codebase-wide
`echo` → `printf` sweep; camelCase → snake\_case rename across `lib/sh/`;
case pattern style enforcement; `text/` global scope removal; third-party
library audit; project rename; tests framework; `net/` and `fs/`
standardisation; major refactors of `core/is.sh` and `units/temperature.sh`;
new functions (`array/readlist`, `text/encode`, `fs/base64`,
`net_wait_for_port`, `ssl_view_cert` days case); complete MkDocs overhaul
including CI pipeline; five documentation pages written from scratch; license
audit of 58 competing projects; cross-language stdlib coverage gap analysis.

### Manual baseline

Prior to this collaboration the codebase was maintained at roughly 30 minutes
per evening, with occasional spikes when interest ran high. At that pace,
accounting for context-switching overhead (~20% of each session spent
re-orienting) and the realistic tendency for high-overhead research tasks to
get deprioritised indefinitely:

| Work category | Estimated evenings solo |
|---------------|------------------------|
| Code refactors + bug fixes | 10–13 |
| New functions | 6–8 |
| Style sweeps (echo, camelCase, case patterns) | 8–12 |
| `text/` global scope + other audits | 5–7 |
| Project rename | 3–5 |
| Tests framework | 4–6 |
| MkDocs overhaul + CI | 6–8 |
| Documentation (5 pages) | 8–12 |
| License audit + cross-language gap analysis | 8–12 |
| GitHub issues (28, several with detailed specs) | 6–7 |
| **Total** | **64–90 evenings** |

At 30 minutes per evening that is **9–12 months of calendar time**. Several
of the research tasks (the 58-repo license audit, the four-language stdlib
comparison) likely would not have been attempted at all solo — the setup cost
exceeds what fits in a 30-minute window, so they would have stayed on the
"someday" list.

### Force multiplier

| Method | Calculation | Result |
|--------|-------------|--------|
| Calendar ratio | 9–12 months ÷ 10 days | ~27–36x |
| With scope premium (tasks not attempted solo) | × 1.5–2x | **40–70x** |

**Central estimate: 40–60x**, consistent with the figure arrived at
independently after the first week of collaboration.

The multiplier is not primarily about typing speed. It comes from: no
context-switching overhead between sessions; research tasks that are
economical at AI speed but prohibitive at human-alone speed; and the ability
to run a full audit, draft documentation, and file detailed issues in a single
sitting rather than across weeks.

---

## Guiding inputs

The AI operates under a set of standing instructions that persist across
sessions. They're reproduced here for transparency.

### Global development standards (`~/.claude/CLAUDE.md`)

Covers system environment context (AlmaLinux, multi-datacenter, Ansible
automation), general behavioural guidelines (think before coding, simplicity
first, surgical changes, goal-driven execution), and a pointer to Karpathy's
guidelines for reducing common LLM coding mistakes.

Key principles extracted:

- State assumptions explicitly; if multiple interpretations exist, present them
  rather than picking silently
- No features beyond what was asked; no abstractions for single-use code; no
  error handling for impossible scenarios
- When editing existing code: don't improve adjacent code, match existing style
  even if you'd do it differently, only clean up orphans your own changes created
- Transform tasks into verifiable goals; state a brief plan for multi-step work

### Shell scripting standards (`~/.claude/rules/shell-scripting.md`)

A detailed set of rules for bash. Critical prohibitions:

- **Never** `set -euo pipefail` or `set -e` — handle errors explicitly
- **Never** parse `ls` output — use globs or `find`
- **Never** `which` — use `command -v`
- **Never** unquoted variables
- **Never** backticks — use `$()`
- **Never** `echo` — use `printf -- '%s\n'`
- **Never** `let` or `expr` — use `$(( ))`
- **Never** bare `*` glob — use `./*`
- **Never** pipe to `while` when variables need to persist — use process
  substitution
- **Never** `eval`

Mandatory practices include: `lower_snake_case` for all variables, always
`${curly_braces}`, `local` declarations separate from assignments (to avoid
masking exit codes), `(( ))` for all numeric comparisons, and the specific case
statement format with opening parentheses on patterns and `;;` vertically
aligned.

### De-slop guide (`~/.claude/rules/deslop.md`)

A writing editor prompt for stripping AI writing patterns from drafts: em
dashes, corrective antithesis ("Not X. But Y."), dramatic pivot phrases ("But
here's the thing"), soft hedging language, staccato rhythm, gift-wrapped
endings, throat-clearing intros, copy-paste metaphors, overexplaining the
obvious, and generic examples.

Source: [Mooch Agency Deslop](https://www.mooch.agency/deslop-a60e4b10f9df43f3bf6ea366eed1b31f)
