# CLAUDE.md — Agent Operating Manual

This file is read automatically by every Claude Code session. Follow everything here
without being asked. These rules exist because we learned them the hard way.

---

## The Game

**Neon Delta: Port Soleil** — a 3D open-world action game in Godot 4.3.
Think GTA 5 meets subtropical delta city. Realistic lighting, not synthwave neon
(neon is a small accent detail on signs, police light bars, and UI only).

**The Three.js prototype is dead.** `game/` is gone. Godot only.

---

## Active Branch

All work goes to: `claude/continuous-branch-integration-nkgogl`

Always:
```bash
git fetch origin claude/continuous-branch-integration-nkgogl
git pull --rebase origin claude/continuous-branch-integration-nkgogl
# ... do work ...
git push -u origin claude/continuous-branch-integration-nkgogl
```

Never push to main or any other branch without explicit user instruction.

---

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
