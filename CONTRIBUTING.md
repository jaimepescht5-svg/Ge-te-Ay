# Contributing — the AI-agent workflow

This is an **AI-only project**: most commits come from autonomous agents working
in parallel. That makes *discipline about branches, gates, and the changelog*
more important here than on a normal repo, because there is no human reviewer
catching every collision. Read [`CLAUDE.md`](CLAUDE.md) first; this doc is the
mechanical "how we converge" layer.

---

## 1. Branches

- One unit of work = one branch, named `claude/<topic>-<suffix>`
  (e.g. `claude/building-world-78y8pq`).
- Branch from the **most complete integration branch**, not from a stale tip.
  When in doubt, list branches and pick the superset (the one with `docs/` +
  `game/` + `prototype/` + `tools/`).
- **Never force-push a shared/integration branch.** Never push to a branch you
  weren't assigned.

## 2. The changelog is the shared memory

Agents don't share context — **the [`CHANGELOG.md`](CHANGELOG.md) does.** Every
round of work appends a dated, titled entry at the **top**:

```markdown
## Round NN — TITLE: one-line of what changed and why
- bullet of the concrete change, linking the doc/system it touches
```

If you don't write it down, the next agent re-discovers it the hard way.

## 3. Gates — what must be true before you commit

Run from the repo root:

```bash
make check
```

This is the umbrella self-check. It must exit `0`. It runs:

- **Doc-link validation** — no broken internal markdown links (always runs).
- **Prototype self-checks** — if the Godot engine is present (`make engine`),
  the driving + on-foot bots drive the slices headlessly and assert their
  invariants (physics stable, lap/waypoints completable, loads sane, Heat
  behaves). These are **floors, not a verdict on fun** (see the taste wall in
  `CLAUDE.md`).

If a change touches a playable system, also eyeball it: `make viz` renders a
contact sheet you can read at a glance, plus a clip to forward to a human.

## 4. Integration (converging parallel branches)

Because many agents fan out, branches drift. To integrate:

1. Start from the chosen base/integration branch.
2. Merge sibling branches one at a time; prefer **merge** over rebase so the
   round history stays legible.
3. Resolve `docs/` collisions by **keeping both** where they're additive
   (different doc numbers) and reconciling the README doc map + `00-index.md`.
4. After each merge, run `make check`. Don't stack a second merge on a red tree.
5. Reconcile `CHANGELOG.md` so every merged round survives (newest at top).
6. Record the integration itself as a round entry.

The branch named `claude/continuous-branch-integration-*` exists for exactly
this. Treat it as the convergence point, not a feature branch.

## 5. Definition of done

A change is done when:

- [ ] `make check` is green.
- [ ] Any new playable behavior has a **bot/self-check or a `viz` contact sheet**
      backing the claim — not just prose.
- [ ] Docs touched are linked from the README map **and** `docs/00-index.md`.
- [ ] `CHANGELOG.md` has a new round entry at the top.
- [ ] The change respects the **non-negotiable promises** and the **taste wall**
      (`CLAUDE.md`): nothing real/trademarked, no self-graded "delight," no
      pay-to-win, accessibility intact.
- [ ] No engine binaries, import caches, or run artifacts staged (`git status`
      is clean of `engine/`, `.godot/`, `frames*/`, `*.import`).

## 6. What stays human

You can take correctness and playability to the wall by yourself. **Feel,
beauty, tension, and "is the city alive" are a human's call.** When you reach the
point where the only thing left to improve is something you cannot measure,
*stop and surface it* rather than optimizing a proxy. That hand-off is the whole
method — see [`docs/24a-ai-development-and-self-observation.md`](docs/24a-ai-development-and-self-observation.md).
