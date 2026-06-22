# CLAUDE.md — Operating Guide for AI Agents

> **Read this first.** This repository is built and maintained **almost entirely
> by AI agents** working in parallel on separate branches. This file is the
> single source of truth for *how to work here* — what the project is, where
> things live, the rules that don't bend, and the commands that prove your work.
> If you change how the repo is built or structured, update this file in the same
> change.

---

## What this project is

**NEON DELTA** — an original, legally-distinct, GTA-inspired **open-world crime
game**, set in the fictional sinking coastal city of **Port Soleil, Solano
County**. (The repo name *Ge-te-Ay* is the genre, spelled out loud.)

The repo is two things at once:

1. **A living design bible** — 56+ numbered docs in [`docs/`](docs/) covering
   vision, world, characters, story, systems, economy, art, audio, online, and
   the legal/production scaffolding.
2. **Real, running prototypes** — a playable Three.js web build in
   [`game/`](game/) and a real-engine (Godot 4.3) self-observing slice in
   [`prototype/`](prototype/).

**New to the project?** Read [`docs/00-index.md`](docs/00-index.md) (orientation)
then [`docs/01-vision.md`](docs/01-vision.md). For *how it gets built by an AI*,
read [`docs/24-ai-development-and-self-observation.md`](docs/24-ai-development-and-self-observation.md)
— it is the philosophical core of this whole repository.

---

## Repository map

| Path | What it is | Who touches it |
|---|---|---|
| [`docs/`](docs/) | The numbered design bible (`NN-topic.md`). The canonical "what". | Narrative, design, production agents |
| [`game/`](game/) | Three.js (WebGL) playable prototype — single `index.html`, no build step. | Web-prototype agents |
| [`prototype/neon-delta-slice/`](prototype/neon-delta-slice/) | Godot 4.3 gray-box slice + self-observation rig (bots, self-checks). | Engine / gameplay agents |
| [`tools/viz/`](tools/viz/) | Visual-check harness (headless render → contact sheet + clip). | Any agent needing a visual sign-off |
| [`tools/check.sh`](tools/check.sh) | The umbrella verification entrypoint (`make check`). | Everyone, before every commit |
| `CLAUDE.md` (this file) | Agent operating guide. | Everyone |
| [`CONTRIBUTING.md`](CONTRIBUTING.md) | Branch & integration workflow, gates, definition of done. | Everyone |
| [`docs/57-repository-and-build-structure.md`](docs/57-repository-and-build-structure.md) | The authoritative repo-structure + build reference. | Everyone |
| [`CHANGELOG.md`](CHANGELOG.md) | The round-by-round build history. **Append to it.** | Everyone |
| [`Makefile`](Makefile) | One-word commands for every common task. | Everyone |

---

## The rules that don't bend

These come from [`docs/00-index.md`](docs/00-index.md) ("non-negotiable
promises") and [`docs/01-vision.md`](docs/01-vision.md) ("pillars"). When two
good ideas conflict, the one serving the higher pillar wins.

1. **Original from frame one.** Every city, brand, name, face, and line is ours.
   Never introduce a real or trademarked place/brand/character. See
   [`docs/12-legal-distinctiveness.md`](docs/12-legal-distinctiveness.md).
2. **The City Is the Star.** If a feature doesn't make Port Soleil feel more
   alive, it's suspect.
3. **Tone is sincere pulp — punch up, never down.** Satire of institutions; love
   for the people.
4. **No pay-to-win, ever. Respect the player's time.** No grind gates.
5. **Accessibility is a launch pillar, not a patch.**

## The taste wall (the one rule unique to an AI-built project)

From [`docs/24-ai-development-and-self-observation.md`](docs/24-ai-development-and-self-observation.md),
the three tiers of "good":

| Tier | Question | Who answers |
|---|---|---|
| **Correctness** | Does it run? Any NaN? Does the mission complete? | **You, fully autonomously.** |
| **Playability** | Is this corner completable? Is the economy exploitable? | **You, via bot proxies + telemetry.** |
| **Delight** | Does it *feel* good? Is the city *alive*? | **Only a human.** Never auto-judge this. |

**You may close the first two tiers by yourself. You may never grade your own
delight.** When you are both author and judge, you will cheat your own metric
(Goodhart). So:

- **Invariants are floors, not goals** — self-checks assert *no NaN / lap
  completable / loads sane*; they never claim the result is *good*.
- **Prefer screenshots over scores** — look at the thing (use `tools/viz/`), don't
  trust a number you defined.
- When the only thing left to improve is *feel*, **stop and ask the human.** Do
  not confidently "improve" the game in a direction you cannot see.

---

## How to work (the loop)

For any change to a playable system, run the self-observation loop:

1. **Build/change** the system.
2. **Run it** — headless under a virtual framebuffer + software GL if there's no
   GPU (the rigs already do this).
3. **Observe** — read telemetry *and* re-open rendered frames (`tools/viz/`).
4. **Assert invariants** — `make check` must pass (exits non-zero on any breach).
5. **Diagnose, fix, repeat.** Then hand the *feel* question to a human.

**Always run `make check` before you commit.** A change that breaks the umbrella
check does not ship.

---

## Commands (see `make help`)

```bash
make help            # list every target
make serve           # run the web prototype at http://localhost:8000
make check           # umbrella verification: doc links + prototype self-checks
make engine          # one-time: download the pinned Godot engine
make slice           # play the Godot driving slice yourself
make selfcheck       # autonomous bot self-checks (driving + on-foot), headless
make viz             # render the slice headless → contact sheet + clip
make docs            # validate internal markdown links only
```

Raw equivalents and per-rig flags live in the respective `README.md` files and in
[`docs/57-repository-and-build-structure.md`](docs/57-repository-and-build-structure.md).

---

## Conventions

- **Docs** are `docs/NN-kebab-topic.md`. New docs take the next free number and
  must be linked from both the README doc map and `docs/00-index.md`.
- **Every round of work appends to [`CHANGELOG.md`](CHANGELOG.md)** (newest at
  top) — that log *is* the project's memory across branches and agents.
- **Branches** are `claude/<topic>-<suffix>`. Read
  [`CONTRIBUTING.md`](CONTRIBUTING.md) before branching, merging, or integrating
  — parallel agents collide here, and the integration workflow is how we
  converge.
- **Keep prototypes honest.** Each prototype's README has a "scope & honesty"
  section. A gray box is a gray box; don't oversell it.
- **Engine binaries, import caches, and run artifacts are never committed**
  (see `.gitignore`). The engine is *fetched*, not stored.
