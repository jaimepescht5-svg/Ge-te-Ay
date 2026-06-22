# 57 — Repository & Build Structure

> Most of this bible is *what* NEON DELTA is. This doc is the **map of the
> repository itself** — where every kind of work lives, how to run and verify it,
> and the scaffolding that lets parallel AI agents build it without tripping over
> each other. It is the companion to
> [`CLAUDE.md`](../CLAUDE.md) (the operating guide) and
> [`CONTRIBUTING.md`](../CONTRIBUTING.md) (the workflow).

## The shape of the repo

```
Ge-te-Ay/
├── CLAUDE.md          ← agent operating guide (read first)
├── CONTRIBUTING.md    ← branch + integration workflow, gates, definition of done
├── README.md          ← the front door + full doc map
├── CHANGELOG.md       ← round-by-round build history (shared memory)
├── Makefile           ← one-word commands for every common task
│
├── docs/              ← the design bible: NN-kebab-topic.md (this lives here)
│
├── game/              ← Three.js (WebGL) playable prototype — single index.html
│
├── prototype/
│   └── neon-delta-slice/   ← Godot 4.3 gray-box slice + self-observation rig
│       ├── scripts/        ← main.gd, track.gd, bot.gd, sandbox.gd, foot_bot.gd
│       ├── tools/          ← fetch_godot.sh, selfcheck*.sh, plot_run.py
│       ├── engine/         ← fetched Godot binary (GITIGNORED — never committed)
│       └── media/          ← committed hero frame, plots, sample reports
│
├── tools/
│   ├── viz/           ← visual-check harness (headless render → contact sheet + clip)
│   ├── check.sh       ← umbrella verification (what `make check` runs)
│   └── check_links.py ← internal markdown link validator
│
└── .claude/
    ├── settings.json       ← harness config, incl. the SessionStart hook
    └── hooks/session-start.sh  ← prints environment readiness on session start
```

## Where new work goes

| If you're writing… | Put it in… | And remember to… |
|---|---|---|
| Design / narrative / systems prose | `docs/NN-topic.md` (next free number) | link it from README map **and** `00-index.md` |
| Web-prototype gameplay | `game/index.html` | keep it single-file, no build step; update `game/README.md` |
| Engine gameplay / a new verb slice | `prototype/.../scripts/` + a `selfcheck` | assert invariants, not "fun" |
| A reusable check or visual tool | `tools/` | wire it into `make check` if it's a gate |
| Anything machine-local (engine, caches, frames) | nowhere — it's gitignored | fetch/regenerate it, never commit it |

## Running & verifying everything

The [`Makefile`](../Makefile) is the single entrypoint. `make help` lists all
targets; the essentials:

| Command | Does |
|---|---|
| `make serve` | Serves `game/` at `http://localhost:8000`. |
| `make check` | **The gate.** Doc-link validation + prototype self-checks (if engine present). Exits non-zero on any failure. |
| `make engine` | One-time download of the pinned Godot 4.3 binary into `prototype/.../engine/`. |
| `make slice` | Play the Godot driving slice yourself (you judge feel). |
| `make selfcheck` | Run the driving + on-foot bots headless and assert invariants. |
| `make viz` | Render the slice headless → contact sheet (for the AI) + clip (for a human). |
| `make docs` | Validate internal markdown links only (fast). |

## The self-observation rig, in one picture

This is the loop from [doc 24](24a-ai-development-and-self-observation.md), made
concrete by the scaffolding:

```
   change a system
        │
        ▼
   run headless  ──(Xvfb + Mesa software GL, no GPU needed)
        │
        ▼
   bot proxy drives/walks/shoots/plays   ──►  telemetry + frames
        │                                          │
        ▼                                          ▼
   assert invariants (selfcheck → 0/1)      tools/viz → contact sheet
        │                                          │
        ▼                                          ▼
   make check (CI gate, floors only)        a human judges FEEL ← the taste wall
```

The first two columns are fully autonomous. The last box is the deliberate,
thin, high-leverage human wire. Keep it thin; never automate it away.

## Environment notes

- **Web prototype** needs only `python3` (for the static server) and a desktop
  browser with WebGL. It loads Three.js from a CDN on first run.
- **Engine prototype / self-checks** need the Godot 4.3 binary (`make engine`),
  plus `xvfb` + Mesa software GL for headless rendering (present in the standard
  container). `make check` *skips* the engine checks gracefully when the binary
  isn't fetched, so doc validation still runs anywhere.
- **viz** needs `pip install -r tools/viz/requirements.txt` (Pillow, etc.).
- The `.claude/` SessionStart hook reports what's available the moment a web
  session opens, so an agent knows immediately whether it can run the rigs.
