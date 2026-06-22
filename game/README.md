# NEON DELTA — Playable 3D Prototype

A real, runnable 3D open-world crime sandbox built with **Three.js** (WebGL). It
turns the [design bible](../docs/00-index.md) into something you can actually
**drive, walk, shoot, and get chased** around in.

This is an original work — no real or trademarked city, brand, or character. See
[docs/12 — Legal Distinctiveness](../docs/12-legal-distinctiveness.md).

---

## ▶ How to run

The game is a single self-contained `index.html`. It loads Three.js from a CDN, so
you need an internet connection the first time.

### Easiest: a local web server (recommended)
```bash
cd game
python3 -m http.server 8000
# then open http://localhost:8000 in a modern browser (Chrome/Edge/Firefox)
```

### Or: just open the file
Double-clicking `game/index.html` works in most browsers too (the game code is
inlined to avoid local-file security blocks). If you see a load error, use the
local-server method above.

> Requires a desktop browser with WebGL and a mouse + keyboard.

---

## 🎮 Controls

| Input | Action |
|---|---|
| **W A S D** | Move on foot / drive a car |
| **Mouse** | Look around & aim (crosshair) |
| **Left click** | Shoot |
| **F** | Steal the nearest car / exit the car |
| **Space** | Handbrake (while driving) |
| **Shift** | Sprint on foot / boost (Redline) while driving |
| **J** | Start a new delivery job (when idle) |
| **R** | Toggle the radio (Velvet Hour) |
| **Esc** | Release the mouse |

Click the title screen to start (this also locks the mouse and starts audio).

---

## 🌃 What's in it

- **An open neon city** — Port Soleil, procedurally laid out in a block grid with
  glowing signs, traffic, and pedestrians, under a moody fog ([art direction](../docs/15-art-direction.md)).
- **Driving** — steal any car and tear around with arcade handling, a handbrake,
  and a Redline boost ([vehicles](../docs/08-vehicles.md)).
- **On-foot** — walk, sprint, and shoot in third person.
- **Shooting & chaos** — hitscan gunplay; civilians scatter as your **Heat** rises.
- **Wanted level (Heat)** — a 0–5★ star system; police cars spawn and **chase**
  you, and you can lose them or wreck them. Heat cools when you lie low
  ([Heat system](../docs/09-weapons-combat.md)).
- **Delivery jobs** — drive to the markers to earn cash (more Heat = bigger payout).
- **HUD + minimap + synth radio** for that Port Soleil feel.

---

## 🔭 Scope & honesty

This is a **playable prototype / vertical-slice toy**, not the full game in the
bible. It proves the core loop — *drive, shoot, draw heat, lose the cops, get
paid* — in a real 3D world you can move around in. It deliberately keeps to one
self-contained file with no build step so anyone can run it in seconds.

Natural next steps (see the bible): the three switchable leads
([doc 03](../docs/03-characters.md)), the four-phase heists
([doc 07](../docs/07-missions.md)), the tide/storm world system
([doc 02](../docs/02-setting-world.md)), and better art/audio.

---

## 🛠 Tech notes

- **Three.js r160** via ESM import map from `unpkg`. No bundler, no install.
- Pure custom kinematics (no physics engine) for predictable, lightweight play.
- All logic is in the inlined module in `index.html` — read it, hack it, extend it.
