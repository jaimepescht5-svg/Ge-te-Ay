# 48 — Narrative Branching & The Flag System

> The campaign promises **choices that the systems and story actually register**
> ([doc 01](01-vision.md)) and **three endings + personal codas**
> ([doc 04](04-story.md)). This doc specs the machinery underneath: how choices are
> tracked, how they ripple, and how we get wide *consequence* without
> combinatorial *explosion* ([doc 35](35-mission-flow-and-pacing.md)).

## Design goals

- **Choices feel weighty and remembered** — the world reacts now and later.
- **Authored, legible outcomes** — never a random branch; the player can trace
  *why* the world changed ([doc 01](01-vision.md)).
- **Scalable to ship** — convergence and flags, not a fully unique script per
  permutation (that way lies madness and cut content).

## The architecture: flags, meters, and gates

Three layers of state drive everything:

### 1. Flags (binary/enum facts)
Discrete records of what happened: *spared Pelham? burned the church ledger? told
La Señora the truth? saved the garage?* Set by missions and choices; read by later
content. Cheap, precise, and the backbone of reactivity.

### 2. Meters (continuous values)
Graded standings that accumulate ([doc 03a](03a-cast-relationships.md),
[doc 10](10-economy-progression.md)):
- **Faction rep** (Vegas, Crane, Police, Streets) — the rep web.
- **Relationship values** (Tomás, Ada, Lucia, Mama Yolette, Pelham).
- **Inter-crew trust** (the three leads' cohesion).
- **A loose "methods" lean** (how loud/lethal vs. quiet/clean you tend to play) —
  read for flavor and some gates.

### 3. Gates (what state unlocks/locks)
Content checks that read flags/meters to open or close jobs, dialogue, allies,
ambushes, prices, and — ultimately — the **ending fork**.

## How consequence ripples (without exploding)

We use **"wide reaction, narrow branch"**:

- **Reactive surface, convergent spine.** Choices change *dialogue, who shows up,
  available side jobs, faction behavior, prices, and small scene variants*
  (cheap, plentiful) — while the **main mission spine reconverges** at act gates
  (expensive branches kept few and meaningful).
- **Heist approaches fork the middle, rejoin the escape**
  ([doc 17](17-heist-catalog.md)) — replayability without N full scripts.
- **The big branches are deliberate and few:** the **midpoint betrayal** variant
  ([doc 04](04-story.md)) and the **Act III ending fork** are where we *spend* the
  branching budget.

## The ending fork (worked logic)

The finale ([doc 17](17-heist-catalog.md), H9) reads accumulated state to offer/
weight the three endings ([doc 04](04-story.md)):

```
IF crew_trust HIGH and saved community-flags (Reclamation, Open Water)
   and Crane-dirt collected  → "HIGH GROUND" available & emphasized
IF methods_lean = scorched and many faction enemies and key allies lost
   → "SCORCHED EARTH" available & emphasized
ELSE / default desperate-but-intact  → "CLEAN BREAK" always available
```

- **Clean Break is the always-available floor** (no player gets locked out of an
  ending), the others are **earned/unlocked** by how you played.
- The **final choice is still the player's** — state *offers and frames* the
  options; it doesn't seize the wheel. Agency to the last beat.

## Personal codas (independent resolution)

Each lead's coda resolves on **their own flags/meters**, parallel to the main fork
([doc 04](04-story.md), [doc 36](36-character-bios.md)):
- **Rae:** garage saved? (Reclamation/Garage flags)
- **Theo:** Ada clear? (Ghost-in-the-Machine flags)
- **Frankie:** wins / walks / dies a hero? (debt + Lucia + trust state)

This gives **personal** payoff regardless of the city-level ending — so two players
who both got "Clean Break" can have very different *emotional* endings.

## Tools & authoring discipline

- **A flag/meter registry** (single source of truth) so writers and designers
  reference the same state names — no orphaned or duplicate flags
  ([doc 25](25-glossary-slang.md)).
- **Editor visualization** of branch points and what reads each flag — keeps the
  web auditable and testable ([doc 20](20-tech-and-production.md)).
- **Reactivity budget per mission:** authored small variants are *encouraged*; new
  full-mission branches require sign-off (cost control).
- **No dead choices:** every offered choice sets *some* flag/meter that's read
  *somewhere* — or it's cut. ([doc 01](01-vision.md))

## Testing & legibility

- **State-driven test harness:** force flag/meter combos to reach and verify every
  gated outcome (especially all endings + codas) without 40-hour playthroughs.
- **Player legibility:** key choices get subtle acknowledgment (a callback line, a
  changed scene) so the player *feels* remembered — the point of the whole system
  ([doc 19](19-living-world-ai.md)).
- **Save-respecting:** branching never corrupts; chapter-select/replay lets players
  explore alternate branches ([doc 43](43-achievements-and-completion.md)).

## Design rules

- **Wide reaction, narrow branch** — react everywhere cheaply, branch deeply rarely.
- **Never a random outcome** — authored and traceable ([doc 01](01-vision.md)).
- **Clean Break is always reachable** — no one is locked out of *an* ending.
- **Codas make endings personal** — the city's fate and the people's fate resolve
  separately ([doc 04](04-story.md)).
- **Every choice sets a flag that's read** — or it doesn't ship.
