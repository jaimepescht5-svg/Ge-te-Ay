# 54 — Level & Encounter Design Patterns

> A reusable toolkit of **spatial and encounter patterns** so designers across a
> huge map build to a consistent quality bar ([doc 33](33-district-deepdive-the-cut.md))
> and so every space supports the three approaches ([doc 07](07-missions.md)).
> Patterns are starting points, not straitjackets.

## The golden rule: every space, three answers

Any meaningful location must afford **Quiet, Loud, and Clever**
([doc 07](07-missions.md), [doc 51](51-enemy-and-faction-roster.md)). Concretely,
a heist/combat space should ship with:

- **≥2 entrances** of differing risk (front/loud, side/quiet, roof-or-water/clever).
- **A stealth path** (cover, shadow, vertical or flanking route, hackable
  obstacles) ([doc 09](09-weapons-combat.md)).
- **A loud arena** (layered cover, flanking lanes, a defensible fallback).
- **A clever lever** (a power box to cut, an evac to trigger, a disguise checkpoint,
  the tide/storm to exploit) ([doc 42](42-signature-abilities.md)).
- **≥2 exits**, ideally onto different traversal layers (road / water / roof /
  rail) ([doc 08](08-vehicles.md)).

## Core spatial patterns

### P1 — The Three-Door Vault
The canonical heist room: a target with a loud door, a quiet door, and a clever
bypass; a guarded approach; a timed/alarmed escape. Used H2/H6/H9
([doc 17](17-heist-catalog.md)).

### P2 — The Chase Corridor
A traversal space *designed* for pursuit: alternating tight/open beats, branching
shortcuts (alleys, canals, rooftops), environmental hazards, and a "release valve"
where a skilled player can break line-of-sight and drop Heat
([doc 09](09-weapons-combat.md)). The Cut's alleys and the causeway are exemplars
([doc 06](06-map-districts.md)).

### P3 — The Vertical Stack
Downtown/Heights pattern: a multi-floor objective rewarding climbing, helipads,
and Overwatch sightlines ([doc 41](41-districts-the-rest.md)); stealth *down* or
fight *up*.

### P4 — The Open Ambush Field
The Reach/Glades pattern: long sightlines + scattered hard cover = marksman/heavy
country; rewards positioning, vehicles, and flanking
([doc 51](51-enemy-and-faction-roster.md)).

### P5 — The Crowd Blender
Markets, clubs, galas, festivals: dense NPCs to hide weapons and vanish into
([doc 19](19-living-world-ai.md)); social-stealth and disguise shine; going loud is
*costly* (witnesses, panic). Mercado del Sol, the Velvet Room, the Ark Gala
([doc 33](33-district-deepdive-the-cut.md)).

### P6 — The Water Gate
A space where the **tide changes the layout** ([doc 02](02-setting-world.md)):
routes open/close, boats become mandatory, hidden channels appear at low tide. The
Glades and the Sinking Blocks ([doc 41](41-districts-the-rest.md)).

### P7 — The Storm Stage
Act III pattern: blackouts, flooding, debris, and thinned enemies reshape a *known*
space into a new one ([doc 38](38-dynamic-events-calendar.md)) — familiarity turned
uncanny, the clever approach supercharged.

## Encounter composition patterns

Mix archetypes ([doc 51](51-enemy-and-faction-roster.md)) into readable problems:

| Pattern | Composition | Tests |
|---|---|---|
| **Pressure & Pin** | Marksman + grunts | Don't camp; break LoS, flank |
| **The Squeeze** | Rusher + ranged | Manage distance, prioritize |
| **The Wall** | Heavy + support | Patience, weak points, kiting |
| **The Net** | Tech/drone + hound | Stealth puzzle; cut signal, misdirect |
| **The Spine** | Lieutenant + squad | Decapitate to scatter |

Harder difficulty = **smarter composition & coordination**, not aimbot
([doc 49](49-difficulty-and-balance.md)).

## Sandbox seeding patterns (open world)

For the living world between missions ([doc 19](19-living-world-ai.md),
[doc 38](38-dynamic-events-calendar.md)):

- **The Invitation** — a vista/landmark/oddity that pulls the player off-route
  (icons are invitations, not chores, [doc 21](21-the-phone-and-meta-ui.md)).
- **The Seed** — a small authored incident (mugging, breakdown, skirmish) the
  systems grow.
- **The Reward Pocket** — a hidden cache/secret rewarding curiosity (sunken caches,
  murals, [doc 18](18-side-stories.md)).
- **The Rhythm Node** — a time/tide-specific activity (dawn market, king-tide
  rescue) teaching the city's pulse ([doc 38](38-dynamic-events-calendar.md)).

## Readability & navigation patterns

- **Landmark anchoring** — every district has 2–3 silhouette landmarks for mental
  mapping ([doc 06](06-map-districts.md), [doc 41](41-districts-the-rest.md)).
- **Sightline storytelling** — important places are *seen* before reached
  ([doc 15](15-art-direction.md)).
- **Affordance honesty** — climbable, hackable, breachable, and cover surfaces read
  clearly (with high-contrast options, [doc 23](23-accessibility.md)).
- **The flood line as a level cue** — high/low ground is *legible*, carrying theme
  and navigation at once ([doc 44](44-themes-and-meaning.md)).

## Quality gates (per space)

- [ ] Passes the **three-answers** rule above.
- [ ] **≥2 in, ≥2 out**, onto differing traversal layers.
- [ ] Reads at a glance (landmarks, affordances, sightlines).
- [ ] Has a **time/tide/storm variant** where the district supports it
      ([doc 38](38-dynamic-events-calendar.md)).
- [ ] Passes the **five-minute corner** test if it's open world
      ([doc 19](19-living-world-ai.md)).
- [ ] No filler — a reason to stop, fight, hide, or look ([doc 01](01-vision.md)).

## Design rules

- **Patterns are scaffolding, not templates** — combine and subvert them; avoid
  copy-paste spaces players can pattern-match ([doc 01](01-vision.md)).
- **Three approaches, always** — the non-negotiable ([doc 07](07-missions.md)).
- **The environment is a tool** — tide, storm, crowds, and verticality are level
  mechanics, not backdrop ([doc 02](02-setting-world.md)).
