# NEON DELTA — Port Soleil Open-World Slice

A tiny, **real-engine** playable slice of the NEON DELTA city: the open world of
**Port Soleil** with its signature verbs unified into one scene —
**driving**, **on foot**, **shooting**, a **0–5 Heat** wanted system, and the
**tidal flooding** of the delta. It exists to prove two things at once:

1. The verbs can feel like something in a gray box (the milestone
   [doc 20](../../docs/20-tech-and-production.md) calls "prove the verbs").
2. An AI can build and **observe its own work** on a game — autonomously
   driving the loop on everything measurable, while a human stays the judge of
   feel. (The method is written up in
   [doc 24](../../docs/24-ai-development-and-self-observation.md).)

It runs on **Godot 4.3**, a genuine game engine, with real `VehicleBody3D` and
`CharacterBody3D` physics, collisions, raycasts, and rendering — not a
hand-rolled simulation. The entire world (seven districts, the causeways that
link them, every building) is built **in code** from the constants in
[`game/index.html`](../../game/index.html), so the world map lives in a readable
diff rather than a binary `.tscn`.

![chase-cam](media/hero.png)

## What's here

| File | Role |
|---|---|
| `Main.tscn` / `scripts/main.gd` | Builds the whole world in code: sea, the seven districts (ground, buildings, tidal flood overlays), the causeways, the car, the on-foot player, chase cam, HUD, the Heat/pursuer system, the tide, and the run director. |
| `scripts/bot.gd` | The reference "proxy player": a waypoint-following driver that tours all seven districts via the causeways. |
| `tools/fetch_godot.sh` | Downloads the pinned engine into `engine/` (gitignored). |
| `tools/selfcheck.sh` | Runs the autonomous self-observation pass (CI-gradeable: exits non-zero on failure). |
| `tools/plot_run.py` | Renders the top-down diagnostic of a run (needs Pillow). |
| `media/` | A hero frame, a top-down plot, and a sample passing report. |

## Port Soleil

Seven districts sit on a flooding delta, linked by raised causeways:

- **Downtown Core** — neon towers, mid-tide flooding.
- **The Cut** — dense rowhouses (the player spawns here).
- **Marisol Heights** — dry mansions on high ground.
- **The Reach** — industrial, first to flood.
- **Cayo Brava** — a low beach strip.
- **Bayou Verde** — a green swamp.
- **Sabal Springs** — dry suburbs.

A **tide** rises and falls on a 120-second cycle; `first`-flood districts go
under at high tide, `mid`-flood districts flood only near the peak, and `dry`
districts stay clear. The HUD shows LOW / RISING / HIGH / FALLING.

## Run it

```bash
cd prototype/neon-delta-slice
tools/fetch_godot.sh            # one-time: pull Godot 4.3

# 1) PLAY IT YOURSELF  (you are the judge of feel)
engine/Godot_v4.3-stable_linux.x86_64 --path .
#   Drive:  W / ↑ accelerate · S / ↓ brake · A D / ← → steer
#   E       enter / exit the car
#   On foot: W A S D move · Shift run · F fire
#   R       respawn in the car   ·   Tab cycle lead character (cosmetic)

# 2) WATCH THE BOT tour the whole world
GAME_MODE=bot engine/Godot_v4.3-stable_linux.x86_64 --path .

# 3) AUTONOMOUS SELF-CHECK  (drives the world tour, asserts, exits 0/1)
tools/selfcheck.sh                 # rendered, captures frames, builds clip.mp4
tools/selfcheck.sh --headless      # logic/telemetry only, faster
python3 tools/plot_run.py "$HOME/.local/share/godot/app_userdata/NEON DELTA — Gray Box Slice"
```

The self-check runs headless-with-rendering via **Xvfb + Mesa software GL**, so
it works on a box with no GPU or display (e.g. CI or a cloud container).

## The verbs, unified

This scene is the merge of three earlier branch prototypes into one world:

- **Driving** — a heavy, low-grip `VehicleBody3D` cruiser; deliberately not an
  F1 car. Enter/exit with **E**.
- **On foot** — a `CharacterBody3D` you walk/run with gravity + collision.
- **Shooting** — a camera-forward raycast gun (**F**); each shot raises Heat.
- **Heat** — a 0–5 wanted level that rises when you commit crimes, spawns police
  `VehicleBody3D` pursuers that chase you (up to three), and decays once you stay
  clean for a few seconds.
- **Tide** — the tidal flood overlays animate every frame.

## What the loop checks by itself

`selfcheck.sh` drives the bot on a closed tour of all seven districts, logs
telemetry, and asserts invariants — physics stability (no NaN), the car actually
moves (>1000 m), reaches a sane top speed (>60 km/h), visits at least ten
waypoints across multiple districts, and never falls off the world. It writes:

- `selfcheck.json` — the report + pass/fail.
- `frames/` — chase-cam PNGs (which the AI literally re-opens and looks at).

The number of captured frames is reported for visual review but is not itself a
pass/fail gate.

![top-down](media/run_topdown.png)

## What this slice does NOT decide

Whether the verbs are **fun**. The bot can tell you the world is *traversable,
fair, and stable*; it cannot tell you the car feels good to throw into a corner
or that a chase is tense. That is the one wire left for the human judge — by
design. See [doc 24](../../docs/24-ai-development-and-self-observation.md).

## Tuning knobs

All feel lives at the top of `scripts/main.gd`:

- **Car** — `ENGINE_POWER`, `BRAKE_POWER`, `MAX_STEER`, `STEER_SPEED`,
  `CAR_MASS`, `WHEEL_FRICTION`, `CAR_LEN/W/H`.
- **On foot** — `WALK_SPEED`, `RUN_SPEED`, `GRAVITY`, `TURN_SPEED`, `GUN_RANGE`.
- **Heat** — `HEAT_MAX`, `HEAT_DECAY`, `HEAT_CLEAN_DELAY`, `PURSUER_SPEED`,
  `PURSUER_CAP`, `HEAT_PER_SHOT`.
- **World** — the `DISTRICTS` and `CAUSEWAYS` tables, `TIDE_PERIOD`, and
  `ROAD_HALF_WIDTH` (how wide a building-free corridor is carved along the tour).

The bot's driving model lives at the top of `scripts/bot.gd`
(`SWITCH_DIST`, `STEER_GAIN`, `MAX_SPEED`, `TURN_SLOWDOWN`).
