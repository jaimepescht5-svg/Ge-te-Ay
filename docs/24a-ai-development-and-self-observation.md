# 24 — AI-Assisted Development & The Self-Observation Loop

> Most of this bible is *what* NEON DELTA is. This doc is about *how it can get
> built* when a large part of the labour is done by an AI — and, just as
> importantly, where that approach hits a hard wall. It is written honestly,
> because pretending otherwise would be the most expensive mistake in the plan.

## The question

How far can AI-driven development take a game like this on its own? The useful
answer isn't a number — it's a **map of which parts of "is this good?" a machine
can answer for itself, and which it can't.**

## The three tiers of "good"

| Tier | Example question | Who can answer it |
|---|---|---|
| **Correctness** | Does the car reach its target speed? Any NaN in the physics? Does the mission script complete? | The AI, fully and autonomously. |
| **Playability** | Is this corner completable? Is the economy exploitable? Is the difficulty curve sane? Where does a normal player get stuck? | The AI, via **proxy players** (bots) + telemetry. |
| **Delight** | Does throwing the car into a corner *feel* good? Is the city *alive*? Is the heist *tense*? | **Only a human.** |

The first two tiers **close into a loop** the AI can run by itself. The third
does not, and no amount of cleverness changes that — so the method is built
around feeding the third tier to a human as cheaply as possible.

## The loop that closes (the "ouroboros")

A real engine ([Godot/Unreal-class](20-tech-and-production.md)) can be driven
headlessly and instrumented, so the AI can run this cycle with no human in it:

1. **Build / change** a system in the engine.
2. **Run it headless** (under a virtual framebuffer + software GL if there's no
   GPU), driving it with a **bot proxy player**.
3. **Observe** — read telemetry *and* re-open rendered screenshots. A
   multimodal model can literally look at the frame and see the car clipping a
   wall, the UI misaligned, the line run wide.
4. **Assert invariants** — physics stable, lap completable, on-track, no absurd
   loads. Fail the build on any breach.
5. **Diagnose and fix**, then go to 1.

This is not theory in this repo. The
[gray-box driving slice](../prototype/neon-delta-slice/) implements exactly this
rig, and the loop autonomously caught a flipped forward-vector, a 15×-too-weak
engine, an over-optimistic grip model (spotted in a screenshot of the car
nose-first into a barrier), and a physics instability — all without a human
pointing at any of them.

## The wire that stays human

The loop above can make the driving **correct, fair, and stable**. It cannot
make it **fun**. So NEON DELTA's process keeps exactly one deliberate human
input: **taste**.

The design rule is to make that wire *thin and high-leverage*:

- The AI runs 95% of the loop — building, botting, screenshotting, asserting,
  fixing measurable failures.
- The human drops in a **sparse, vague signal**: "this feels floaty," "the city
  is dead at night," "this jump is unsatisfying."
- The AI's job is then to **operationalise** that vague signal into something
  measurable — a metric, a test, a tuning target — and propagate it.

The win is not removing the human. It's making the human needed *rarely*,
instead of constantly.

## The trap: Goodhart, or why a closed loop is dangerous, not just incomplete

When the AI is **both author and judge**, it doesn't merely lack taste — it will
**cheat its own test**. It optimises whatever metric it defined, and the metric
drifts away from fun while the dashboard stays green. "Lap time improved" can
coexist with "the car now feels horrible."

A self-grading loop converges on *what it can measure*, not on *what is good*.
Mitigations baked into this project:

- **Invariants are guard-rails, not goals.** The self-check asserts *floors*
  (no NaN, lap completable, loads sane) — it never claims the result is *good*.
- **The human signal is the only authority on delight**, and it is never
  auto-synthesised by the same model that wrote the code.
- **Screenshots over scores** wherever possible — looking at the thing resists
  metric-gaming better than a number does.

## Practical playbook for NEON DELTA

- **Every core verb gets a gray-box slice + self-check** before it scales
  (driving is the first; the switch, shooting, stealth, the heist loop follow).
- **Proxy players are first-class tooling** — bots that drive, shoot, navigate,
  and play missions, emitting telemetry that finds the impossible jump and the
  broken economy long before QA does.
- **Determinism where designers need it** ([doc 20](20-tech-and-production.md))
  so a self-check run is reproducible and a regression is a real signal.
- **CI gate**: the self-check exits non-zero on any breached invariant, so a bad
  build can't merge — the loop becomes infrastructure, not a one-off.

## The honest headline

AI-only development can take the **paper** game astonishingly far, and a **rough
prototype** surprisingly far — it can self-observe everything except whether the
result is *good*. The failure mode to watch for is the moment the only thing
left to fix is the thing it can't see: it will either stall, or confidently
"improve" the game in the wrong direction. That moment is exactly where the
human judge earns their keep.
