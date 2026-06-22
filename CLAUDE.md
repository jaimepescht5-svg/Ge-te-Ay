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
read [`docs/24a-ai-development-and-self-observation.md`](docs/24a-ai-development-and-self-observation.md)
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

From [`docs/24a-ai-development-and-self-observation.md`](docs/24a-ai-development-and-self-observation.md),
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

---

> ## Engine & prototype operating rules (from the Godot slice)
> The sections below are preserved from the Godot-slice operating manual
> (merged from `continuous-branch-integration`). They carry the engine-
> specific rules, conventions, and aesthetic direction that the `prototype/`
> code depends on.

## Hard Rules (non-negotiable)

### 1. No file over 600 lines — ever
If adding code would push a file past 600 lines, split it first, then add.
Not after. Before.

Current module boundaries:
```
scripts/main.gd       — scene root, _ready, _process, selfcheck only
scripts/world_env.gd  — sky, lighting, day/night, tide, streetlights
scripts/world_geo.gd  — districts, causeways, sea, buildings
scripts/vehicle.gd    — car/wheel setup and control loop
scripts/player.gd     — on-foot character, camera, weapons
scripts/heat.gd       — heat system, pursuers, police spawning
scripts/hud.gd        — all HUD/UI construction and updates
scripts/traffic.gd    — civilian vehicles, pedestrian NPCs
scripts/missions.gd   — mission system, money, objectives
scripts/bot.gd        — waypoint-following AI driver (selfcheck)
scripts/capture.gd    — viz frame grabber autoload
```

### 2. Selfcheck must always pass
Run this after every single feature, before committing:
```bash
cd prototype/neon-delta-slice
GAME_MODE=selfcheck SC_SECONDS=60 ./engine/Godot_v4.3-stable_linux.x86_64 \
  --headless --path . 2>/dev/null | grep -E "====|PASS|FAIL|sim="
```
Required output: `==== PASS ====`
Criteria: physics stable, car moved, top speed >50 km/h, ≥10 waypoints (in 300s run),
never fell off world (min_y > -5).

Never commit a broken selfcheck. Fix forward, not with workarounds.

### 3. No class_name anywhere in GDScript
CI parses scripts on a clean clone without the `.godot/` global class cache.
`class_name Foo` will break the parse. Use `preload()` instead:
```gdscript
const VehicleSystem := preload("res://scripts/vehicle.gd")
```

### 4. No binary assets, no external files
All geometry is procedural GDScript. No `.tscn` scene files with binary content,
no image textures loaded from disk, no audio files. Everything is built at runtime
in `_ready()`. Diffs in this repo must be human-readable.

Exception: `engine/` (the Godot binary) and `media/` (captured output frames) are
pre-existing and not touched.

### 5. GDScript const limitation
`const` only accepts compile-time literals (int, float, String, bool).
These will crash the parser:
```gdscript
const WP := PackedVector2Array([Vector2(0, 0)])  # WRONG — parse error
const C := Color(1, 0, 0)                        # WRONG
```
Use `var` for anything containing Vector2, Vector3, Color, Array, Dictionary:
```gdscript
var WP := PackedVector2Array([Vector2(0, 0)])    # correct
```

### 6. Headless safety
Any Godot feature that requires a GPU or display must be guarded:
```gdscript
if DisplayServer.get_name() != "headless":
    # SDFGI, GPUParticles3D, SubViewport, screen capture etc.
```
The selfcheck runs headless. Crashes there are CI failures.

---

## How to Work

### Read before touching
Always read the full target file before editing. Never guess at existing structure.
If a file is long, read it in sections — but read all of it.

### Commit granularly, push immediately
One logical change per commit. Push after every commit.
Don't batch 3 features into one commit. If the selfcheck breaks, you need to bisect.

Commit message format:
```
feat: <what and why in one line>
fix: <what was broken and how>
refactor: <what moved and why>
```

### Verify, don't assume
After every code change, run something that proves it works.
For Godot: the selfcheck. For scripts: `grep` for the thing you added.
"It should work" is not verification.

### Check for remote changes before pushing
The repo has concurrent agents. Always:
```bash
git fetch origin claude/continuous-branch-integration-nkgogl
git pull --rebase origin claude/continuous-branch-integration-nkgogl
```
before pushing. If rebase fails, resolve conflicts — don't force push.

### When adding a big feature, plan the split first
Before writing code, write out (in a comment or in your head) which file owns it
and whether adding it will breach 600 lines. If yes, refactor the target file first.

### Don't add debug code to commits
`ND_DEBUG=1` print statements, temporary `print()` calls, commented-out experiments:
remove before committing. The log should be clean on every commit.

---

## Godot 4.3 Specifics

### VehicleBody3D drives in local +Z
`car.global_transform.basis.z` is the forward direction. Not `-z`.

### Steering convention
Positive `car.steering` = clockwise = RIGHT turn.
Bot's cross product: positive = target is to the LEFT → negate before applying:
```gdscript
car.steering = -bot_steer * MAX_STEER
```

### Material cache
Always cache materials by color. Never create `StandardMaterial3D` inside a loop:
```gdscript
var _mat_cache: Dictionary = {}
func _mat(hex: int) -> StandardMaterial3D:
    if _mat_cache.has(hex):
        return _mat_cache[hex]
    var m := StandardMaterial3D.new()
    m.albedo_color = _hex(hex)
    _mat_cache[hex] = m
    return m
```

### Causeway collision alignment
BoxShape3D for flat surfaces: set `col.position = Vector3(0, -1.0, 0)` so the top
surface sits at y=0, flush with district ground. Without this offset a 2m-tall box
centered at y=0 has its top at y=+1 — a 1m step the car can't climb.

---

## Aesthetic Direction

**Lighting: realistic, physically plausible. Not synthwave.**
- Sun: warm golden hour (start tod ≈ 0.70), accurate color temperature ramp
- Night: sodium/amber streetlights, cool blue moonlight
- Fog: warm dark, not purple or violet
- Building windows: warm amber (residential), cool fluorescent (commercial)

**Neon accents are small details only:**
- Building signs in downtown/cut (not every building)
- Police light bars (cyan/magenta strobe — the legitimate source)
- UI elements
- NOT the sky, NOT the fog, NOT the ground

**World districts have distinct moods:**
- Downtown: dense, tall, golden uplighting
- The Cut: gritty, rowhouses, warm sodium
- Heights: wealthy, clean, warm white uplighting
- The Reach: industrial, orange safety lighting, heavy fog
- Cayo Brava: beachfront, cool evening light, lighthouse
- Bayou Verde: dark, green-tinged fog, sparse lighting
- Sabal Springs: suburban, warm residential glow

---

## What NOT to Do

- Don't touch `game/` — it doesn't exist anymore
- Don't create a PR without the user asking
- Don't push to main
- Don't use `--no-verify` or skip hooks
- Don't let a file grow past 600 lines hoping to refactor later
- Don't add synthwave/neon colors to lighting or sky
- Don't leave debug prints in committed code
- Don't amend published commits — new commit instead
- Don't `git reset --hard` without checking what you'd lose
- Don't run `git add -A` — stage specific files by name

---

## Selfcheck Quick Reference

```bash
# Fast sanity check (60s sim):
cd prototype/neon-delta-slice
GAME_MODE=selfcheck SC_SECONDS=60 ./engine/Godot_v4.3-stable_linux.x86_64 \
  --headless --path . 2>/dev/null | grep -E "====|PASS|FAIL|sim="

# Full check (300s sim, definitive):
GAME_MODE=selfcheck SC_SECONDS=300 ./engine/Godot_v4.3-stable_linux.x86_64 \
  --headless --path . 2>/dev/null | grep -E "====|PASS|FAIL|sim="

# With debug telemetry:
ND_DEBUG=1 GAME_MODE=selfcheck SC_SECONDS=30 ./engine/Godot_v4.3-stable_linux.x86_64 \
  --headless --path . 2>/dev/null

# Watch commits land (progress monitor):
git fetch origin claude/continuous-branch-integration-nkgogl && \
  git log --oneline origin/claude/continuous-branch-integration-nkgogl | head -15
```
