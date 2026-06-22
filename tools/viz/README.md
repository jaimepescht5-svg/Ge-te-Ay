# viz — visual-check harness

A small tool to close the **visual** half of the self-observation loop
([doc 24](../../docs/24a-ai-development-and-self-observation.md)): render a Godot
scene with no GPU, glance it as one image, and hand a human a clip to confirm.

```
run a scene  ─►  frames/  ─┬─►  contact.png   (one grid → AI reads it at a glance)
(Xvfb+softGL)              └─►  clip.mp4/.gif  (→ human confirms on a phone)
```

Why it exists: every time a change needs a visual sign-off, this makes it **one
command** instead of a hand-rolled pipeline — easy for the AI to check first,
and easy to forward to a human once the AI is happy.

## Setup

```bash
pip install -r tools/viz/requirements.txt
# a Godot 4.3 binary somewhere; point at it with --engine or $VIZ_GODOT
export VIZ_GODOT=prototype/neon-delta-slice/engine/Godot_v4.3-stable_linux.x86_64
```

## Commands

```bash
# Everything at once: run a project, build a contact sheet + clip
python3 tools/viz/viz.py check \
    --project prototype/neon-delta-slice \
    --env GAME_MODE=selfcheck --env SC_SECONDS=28 \
    --env CAP_INTERVAL=0.16 --env CAP_MAX=180 \
    --frames-out /tmp/run_frames --frames /tmp/run_frames \
    --gif --width 640 --fps 24 --max 12

# Or piecemeal:
python3 tools/viz/viz.py run     --project <dir> --env K=V --frames-out /tmp/f
python3 tools/viz/viz.py contact /tmp/f --max 12 --cols 4   # grid for the AI
python3 tools/viz/viz.py clip    /tmp/f --gif --width 640   # mp4(+gif) for a human
```

- `--frames-out DIR` sets `$VIZ_OUT`, where capture writes frames. Projects that
  honour it (NEON DELTA does, and any project using `capture.gd`) drop frames
  there, so you control the location instead of hunting the user-data dir.
- Rendering runs under **Xvfb + Mesa software GL** (`LIBGL_ALWAYS_SOFTWARE=1`),
  so it works on a CI box or container with no GPU. `--headless` skips rendering
  entirely (logic only — no frames).

## Using it in another Godot project

Add `capture.gd` as an autoload, then run with `VIZ_CAPTURE=1`:

```ini
# project.godot
[autoload]
VizCapture="*res://path/to/capture.gd"
```

```bash
VIZ_CAPTURE=1 VIZ_OUT=/tmp/f VIZ_SECONDS=10 \
  python3 tools/viz/viz.py run --project <dir> --frames-out /tmp/f
```

It captures the root viewport on a timer and quits on its own — engine-agnostic,
works on any scene.
