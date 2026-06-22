# Project Health Assessment — NEON DELTA

*Assessed 2026-06-22. A candid, no-spin read of where this project actually stands.*

## TL;DR

NEON DELTA is a **clean-room, legally-distinct open-world crime game** developed
by parallel AI agents in "Rounds." It is, in practice, **a ~6,100-line design
bible (60 docs) plus two playable prototypes** — a Three.js browser build and a
Godot slice.

- **As a *game project*:** terminally over-scoped. Open-world crime is the single
  most expensive genre in existence ($100M+, hundreds of people, 5+ years). No
  amount of docs closes that gap with the current setup. This will not become a
  shippable AAA game.
- **As an AI-driven creative / worldbuilding / portfolio exercise:** genuinely
  strong. Coherent world, disciplined design, real legal-distinctiveness work,
  and two things you can actually run. That puts it ahead of ~99% of "I'm going
  to make a GTA" projects, which never produce anything runnable.

Grade it as the second thing, not the first.

## What's in the repo

| Area | Substance |
|---|---|
| Design docs (`docs/`) | 60 files, ~6,100 lines — vision, world, characters, story, economy, online, localization, level patterns, GTM. |
| Three.js game (`game/`) | ~1,160-line single `index.html`. Drive/walk/shoot, wanted level, delivery jobs, districted city, tides, **boats + hurricane season**. |
| Godot slice (`prototype/`) | ~1,720 lines GDScript. Driving + on-foot verbs, enter/exit car, aiming, headless self-check rig, viz capture. |
| Tooling | `make check` gate, doc link-checker, self-check scripts, `VizCapture` autoload, `.claude/` session hook. |

## Health by dimension

**Scope vs. capacity — RED.** The design describes a full AAA open world; the
build is two toy prototypes. The ratio of plans to code is ~5:1. This gap is
structural, not a matter of more effort.

**Branch hygiene — was RED, now GREEN (this assessment fixed it).** Five
parallel `claude/*` branches had diverged with genuinely split, unmerged work
(the Three.js game advanced on one branch, the Godot slice on two others). There
was no canonical trunk. They are now consolidated — see below.

**Two-engine problem — YELLOW.** A Three.js demo *and* a Godot slice, neither
connected to the other or to the docs. That's two dead-end stacks, not one
prototype with momentum. **Recommendation: pick one.** Godot if you want any
real shot at it becoming a game; Three.js if it stays a web showcase. Maintaining
both dilutes already-thin engineering.

**Doc organization — GREEN.** Well-structured and internally linked (link-checker
passes on all 67 markdown files). The one numbering collision (duplicate `24-`)
was fixed in this pass (the AI-dev appendix is now `24a-`).

**Verifiability — GREEN (relative).** The self-check rigs and `make check` gate
are a real asset and unusual for a project this size — they let agents catch
regressions without a human in the loop.

## What this assessment changed

Consolidated all five divergent branches into a single trunk
(`claude/system-health-assessment-p9nf7g`), preserving every branch's unique work:

1. Based the trunk on `ai-project-scaffolding` (most complete: 94 files, CLAUDE.md,
   Makefile, CI hooks).
2. Merged `building-world` — took its `game/index.html` (a clean superset:
   boats, hurricane, real boatable canals; 1,163 vs 994 lines), hand-merged the
   CHANGELOG.
3. Merged `transgenor` — enter/exit car, mouse-look aiming, neon pass on the
   Godot slice.
4. Merged `continuous-branch-integration` — reconciled its `VizCapture` autoload
   refactor against transgenor's heavier slice by hand, routing frame-counts
   through the autoload and removing the dead bespoke-capture symbols.
5. Resolved the `docs/24` numbering collision.

All five source branches are now ancestors of the trunk. The doc link-checker
passes. (The Godot self-check could not be run here — the engine isn't fetched
in this environment — so the prototype merge is verified by static review, not a
runtime pass.)

## Recommended next moves

1. **Make this trunk the canonical branch** and retire the old `claude/*`
   branches so future agents converge on one source of truth.
2. **Commit to one engine.** Decide Godot vs Three.js and delete or archive the
   other. The split is the main thing quietly rotting the project.
3. **Right-size the ambition in the README.** Frame it honestly as a design
   bible + prototypes, not an in-development AAA title — that's the truthful and
   more impressive framing anyway.
4. **Run `make check` with the engine fetched** to get a real runtime pass on the
   consolidated Godot slice before building further on it.
