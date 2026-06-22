# 49 — Difficulty & Balance

> Pulls together the difficulty philosophy scattered across the bible
> ([doc 01](01-vision.md), [doc 05](05-gameplay-mechanics.md),
> [doc 23](23-accessibility.md), [doc 34](34-economy-balance.md)) into one coherent
> design: **how challenge is tuned, separated into axes, and balanced to be fair,
> legible, and welcoming** without being toothless.

## Philosophy

- **Difficulty ≠ accessibility, and both are granular.** A player can make the game
  *easier to play* (accessibility) and/or *less punishing* (difficulty)
  independently, per system ([doc 23](23-accessibility.md)).
- **Fair before hard.** Challenge must always be **legible** — the player
  understands why they failed and how to do better ([doc 01](01-vision.md)). We
  never trade fairness for difficulty.
- **Welcoming, not toothless.** The default should respect a broad audience; the
  hard end should genuinely test mastery ([doc 42](42-signature-abilities.md)). Both
  ends are first-class.

## Per-system difficulty axes (the core idea)

No single slider. The player tunes each independently
([doc 05](05-gameplay-mechanics.md)):

| Axis | What it tunes | Easy end | Hard end |
|---|---|---|---|
| **Driving** | Handling assists, traffic aggression | Auto-brake, rubber-band help, forgiving grip | Full sim weight, no aids |
| **Combat** | Aim assist, enemy health/lethality, ammo | Strong assist, tanky you, plentiful ammo | Free-aim, lethal enemies, scarce ammo |
| **Stealth** | Detection speed, alert memory, cone size | Forgiving cones, short memory | Sharp senses, persistent search |
| **Economy** | Payout size, penalty severity | Generous, soft failure | Lean, punishing fallout |
| **Heist complexity** | Guard density, timer pressure, intel given | More intel, fewer guards | Minimal intel, full opposition |

Plus **presets** ("Relaxed / Story / Standard / Hardcore") that set sane bundles,
all individually overridable ([doc 23](23-accessibility.md)).

## What scales with difficulty (and what doesn't)

**Scales:** enemy health/damage/accuracy/perception, enemy numbers and
coordination, security density, timer windows, economy generosity, assist strength.

**Never scales (held constant for fairness):**
- **Legibility** — you always see *why* you're wanted and where they think you are
  ([doc 09](09-weapons-combat.md)); this is sacred at every difficulty.
- **No teleporting/cheating AI** — higher difficulty = smarter, not psychic
  ([doc 19](19-living-world-ai.md)).
- **Story access** — no ending, mission, or beat is locked behind a difficulty.
- **The anti-grind floor** — main-path payouts still fund progression even on the
  leanest economy ([doc 34](34-economy-balance.md)).

## The challenge curve (macro)

- **Skill *assumption* rises by act** (Act III security/enemies > Act I), but the
  **per-axis sliders let any player flatten that curve**
  ([doc 35](35-mission-flow-and-pacing.md)).
- **No untelegraphed spikes** — recon/intel warns before the game asks for more, so
  difficulty is always *fair* ([doc 17](17-heist-catalog.md)).
- **Mastery has headroom** — signature-ability skill ceilings
  ([doc 42](42-signature-abilities.md)) and Hardcore tuning reward expert play
  without gating anyone out.

## Balancing the three pillars of play (loud/quiet/clever)

The economy and design must keep **all three approaches viable** so difficulty
doesn't railroad playstyle ([doc 07](07-missions.md), [doc 34](34-economy-balance.md)):

- **Quiet:** highest payout, lowest Heat, highest skill demand — rewarded, not
  mandatory.
- **Loud:** reliable, expensive, hot — always a valid fallback.
- **Clever:** situational, spectacular, risky — the spice.
- **Balance rule:** buff/nerf to keep these *roughly* equal in *expected value at
  equal skill*, so the player chooses on **fun/fiction**, not on a dominant meta.

## Encounter & AI balance

- **Telegraphed, counterable threats** — every enemy type has a readable tell and a
  fair answer ([doc 09](09-weapons-combat.md)).
- **Squad AI scales by coordination, not aimbot** — harder enemies flank, suppress,
  and flush, they don't laser you through smoke ([doc 19](19-living-world-ai.md)).
- **Companion/crew AI scales with pay, not difficulty** — your help stays competent
  so the game gets harder *for you*, not by sabotaging allies
  ([doc 10](10-economy-progression.md)).

## Tuning process

1. **Model first** — spreadsheet the economy ([doc 34](34-economy-balance.md)) and
   combat/stealth values to coherent first-pass curves.
2. **Playtest against the [doc 01](01-vision.md) metrics** — especially "did you
   understand why you failed?" (≥85% yes) and "forced to grind?" (<5% yes).
3. **Tune per axis** — adjust one system without disturbing others (the point of
   separate axes).
4. **Iterate with accessibility playtesters** across the full range
   ([doc 23](23-accessibility.md)).

## Design rules

- **Fairness and legibility never scale away** — the floor of every difficulty.
- **Separate axes** so players sculpt their own challenge
  ([doc 05](05-gameplay-mechanics.md)).
- **All three approaches stay viable** at all difficulties
  ([doc 07](07-missions.md)).
- **Hard means smarter, never cheating** ([doc 19](19-living-world-ai.md)).
- **Nothing story-critical is difficulty-gated** ([doc 23](23-accessibility.md)).
