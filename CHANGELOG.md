# Build History — NEON DELTA design bible

This log tracks the iterative expansion of the design. Newest at top.

## Round 18 — Boats & the hurricane
- **Boats**: water vehicles moored at six marinas around the islands. Press **F**
  to commandeer one and cross the open sea between districts — boats are blocked
  by land (the inverse of cars), ride the tide, and bob in the chop. Shared
  vehicle code with cars; disembarking always steps you onto solid ground.
- **The hurricane season** (docs/02 climax): on a long cycle a **named hurricane**
  builds, peaks at the eye, and passes — darkening skies, falling **rain**,
  **lightning**, a **storm surge** that floods the low ground beyond its tidal
  line, **evacuating** crowds, and **thinning** police. Live HUD warning, with the
  surge folded into the tide system so flooding and the minimap react to it.

## Round 17 — BUILDING THE WORLD: a real city, not a grid
- Replaced the prototype's flat, uniform neon grid with **Port Soleil as a
  districted archipelago** — the bible's #1 pillar ("The City Is the Star") made
  real in `game/`:
  - **Seven distinct districts** laid out per [doc 06](docs/06-map-districts.md)
    (Downtown Core, The Cut, Marisol Heights, The Reach, Cayo Brava, Bayou Verde,
    Sabal Springs), each with its own building style, palette, height, and density.
  - **The sea + causeways**: districts are islands on an open sea, connected by
    drivable bridges; water is a hard edge for the player, traffic, and police.
  - **A dynamic tide** ([doc 02](docs/02-setting-world.md)): a rising/falling tide
    that floods the low-lying districts while the high ground stays dry — the
    "flood line on the map" rendered as level geometry, with a HUD tide gauge.
  - **Landmarks for mental mapping**: the Crane Tower, The Ark arcology, the
    Lighthouse, the Drawbridge, and the Dead Mall.
  - Deterministic world seed, a north-up county minimap, and a HUD that names the
    district you're standing in. Player now spawns in **The Cut**, the crew's home
    turf. All prior systems (driving, shooting, Heat, jobs, radio) preserved.

## Round 16 — IT'S PLAYABLE: 3D prototype
- Built an actual, runnable **3D open-world game** in `game/` using Three.js
  (WebGL), self-contained in a single `index.html`, no build step:
  - Procedural neon city (block grid, glowing signs, fog, traffic, pedestrians)
  - Arcade **driving** (steal any car, handbrake, Redline boost) + **on-foot**
    third-person movement, with enter/exit
  - Hitscan **shooting** with tracers and muzzle flashes
  - **Heat / wanted system** (0–5★) with police cars that spawn and chase, can be
    wrecked or lost; Heat cools when lying low
  - **Delivery jobs** for cash, HUD, minimap, and a synth radio
- Added `game/README.md` (run instructions + controls) and featured the prototype
  at the top of the main README.
- Note: this round began as content expansion (doc 56 Extended Heists) and pivoted
  to building the actual game on request.

## Round 15 — Maturity & Market
- Added three docs:
  - 53 Decisions & Open Questions — the honest log of decisions-with-rationale,
    genuinely-open questions, and the live risk-watch (the mark of a mature bible)
  - 54 Level & Encounter Patterns — the "every space, three answers" rule plus a
    reusable toolkit of spatial, encounter, sandbox, and readability patterns
  - 55 Go-To-Market Plan — marketing principles, the beat plan, the deliberate
    "trust beat," storefront hygiene, and anti-patterns
- Updated README doc map.

## Round 14 — Experience & Encounters
- Added three docs:
  - 50 Onboarding & Tutorial — teach-by-playing philosophy, the first-3-hours
    curve, progressive disclosure, pull-not-push help, soft early failure
  - 51 Enemy & Faction Roster — the four pursuit forces, police escalation roster,
    readable enemy archetypes, faction-flavor enemies, encounter & boss design
  - 52 The Player Journey — the felt experience minute-one-to-credits, the
    emotional throughline, and the journey review gate
- Updated README doc map.

## Round 13 — Navigation & Systems Closeout
- Added three docs:
  - 00 Master Index & Reading Guide — "start here": role-based reading paths, doc
    families, the pillars cheat sheet, and the non-negotiable promises
  - 48 Narrative Branching System — the flags/meters/gates architecture,
    "wide reaction / narrow branch," the ending-fork logic, personal codas
  - 49 Difficulty & Balance — per-system difficulty axes, what scales (and what
    never does), loud/quiet/clever EV balance, AI/tuning rules
- Added the index link to the top of the README doc map.

## Round 12 — Online, Global & Community
- Added three docs:
  - 45 Solano Online (Deep Dive) — created-character, player crews & roles, the
    co-op heist loop, fair business income, detailed anti-grief PvP structure,
    seasons & continuity
  - 46 Localization & Culturalization — culturalization (getting the melting-pot
    source right), transcreating satire/slang, technical loc requirements
  - 47 Photo Mode & Community — first-class photo mode, sharing/galleries, creator
    tools, moderation, accessibility of capture
- Updated README doc map.

## Round 11 — Mechanical & Thematic Capstones
- Added three docs:
  - 42 Signature Abilities — full mechanical design of Redline/Overwatch/Hot
    Streak (inputs, Focus economy, upgrade trees, switch synergy)
  - 43 Achievements & 100% Completion — the no-grind trophy list and the finite,
    "best-of-the-game" completion definition
  - 44 Themes & Meaning — the essay tying every system to the thesis (who owns a
    place / reinvention / the flood as reckoning; theme-as-mechanic)
- Updated README doc map.

## Round 10 — Senses & The Whole Map
- Added three docs:
  - 39 Game Feel & Juice — input, speed-reactive camera, driving/combat/traversal
    feel, haptics, "juice," and the feel review gate
  - 40 Sound Design — per-district ambience, foley, weapon/vehicle audio, the
    storm as an audio set-piece, accessibility mix rules
  - 41 The Rest of the Map — design briefs bringing the other six districts to a
    consistent ship-quality level (identity, landmarks, system fantasy, content)
- Updated README doc map.

## Round 9 — Interiority & Living Calendar
- Added three docs:
  - 36 Character Bios — full deep backstories, wounds, and arc questions for the
    three leads and the three antagonists
  - 37 Radio Programming — station programming anatomy, sample original-track
    commission briefs, DJ bits, satirical ad reads, reactive logic
  - 38 Dynamic Events Calendar — the three event layers (cyclical/scheduled/
    reactive) and the storm mega-event staging
- Updated README doc map.

## Round 8 — Granular Depth
- Went deeper and more concrete with three docs:
  - 33 District Deep-Dive: The Cut — the ship-quality template district (layout,
    landmarks, system showcase, content density, tide/time states, quality gates)
  - 34 Economy Balance — worked illustrative numbers: phase net-worth curve, heist
    payouts by approach, net-take formula, laundering economics, spending sinks,
    passive income, numeric anti-grind guarantees
  - 35 Mission Flow & Pacing — campaign spine, register-alternation rule, the
    5-beat mission template, branching/convergence, anti-sag review gates
- Updated README doc map.

## Round 7 — Product & Lifecycle
- Added three product-layer docs:
  - 30 Post-Launch Roadmap — phases, two story expansions ("Undertow,"
    "After the Water"), free-core online seasons that evolve the city, hard
    monetization lines
  - 31 Announce Trailer Script — a ~90s shot-by-shot reveal (postcard → turn →
    the switch → the storm → logo)
  - 32 FAQ — anticipated player/press/stakeholder questions, answered and
    cross-linked to the bible
- Updated README doc map.

## Round 6 — Catalogs & Customization
- Added three player-facing catalog docs:
  - 27 Vehicle Catalog — the full invented fleet (compacts→hypercars, off-road,
    bikes, boats, aircraft, unique earned vehicles) with relative stat tiers
  - 28 Weapon Catalog — the full arsenal across melee→heavy, a complete non-lethal
    line, Theo's gadgets, and attachment/legality/Heat systems
  - 29 Wardrobe & Customization — per-lead signature looks, clothing as a system
    (concealment, disguise, weather, faction colors), acquisition, photo synergy
- Updated README doc map.

## Round 5 — Depth & Pitch
- Added three docs that deepen the world and frame the sell:
  - 24 World Lore & Timeline — the invented 1700s→present history of Solano County
    (drained-and-sold, boom/storm/rebuild, the Vega century, Crane's Reclamation)
  - 25 Glossary & Slang — a design-term glossary + an invented Port Soleil street
    lexicon (a wheel/key/mouth, dry money, spring rain, "that's Soleil")
  - 26 Pitch & Positioning — elevator pitch, the differentiation table, audience,
    store blurb, and tagline candidates
- Updated README doc map.

## Round 4 — Craft & Production
- Added four craft/production docs:
  - 20 Tech & Production — technical pillars, engine stance, scope discipline,
    milestone roadmap, team shape, no-crunch ethics, risk register
  - 21 Phone & Meta UI — the diegetic phone hub (apps, notifications, map),
    HUD philosophy, the Crew Wheel
  - 22 Sample Mission Script — "Wash Day" written out in full to lock the voice
    and show systems-in-fiction
  - 23 Accessibility — full spec across motor, visual, hearing, cognitive, and
    content-sensitivity, plus process commitments
- Updated README doc map.

## Round 3 — Content Depth
- Added four content/system docs:
  - 17 Heist Catalog — the 9 marquee scores (H1–H9), each with Quiet/Loud/Clever
    approaches, teaching goals, rewards, and fallout; H9 branches into the endings
  - 18 Side Stories — 7 named arcs + strangers anthology, hustles, collectibles,
    each with mechanics and a tangible reward/ending lever
  - 19 Living World & AI — NPC ecology & memory, faction territorial AI, dynamic
    environment as actor, emergent "seed" director, police/crew AI, fidelity LOD
  - 03a Cast & Relationships — full relationship web, antagonist motivations,
    dynamic relationship values, casting/voice direction
- Updated README doc map.

## Round 2 — Texture & Voice
- Added four flavor-and-depth docs that give the world its accent:
  - 13 Radio & Music (12-station dial, DJs, reactive talk radio, adaptive score
    with per-lead leitmotifs and a storm motif)
  - 14 Brand Bible (master list of invented brands: food, tech/apps, megaprojects,
    vehicle makes, weapon manufacturers, media, with satirical ad voice)
  - 15 Art Direction (the "sun-bleached paradise rotting at the waterline" look;
    per-district palettes, lighting moods, UI identity, photo mode, VFX)
  - 16 Vertical Slice — the playable prologue "The Sure Thing" beat by beat,
    teaching the three leads + the switch and ending on the welding hook
- Updated README doc map.

## Round 1 — Foundation
- Established the original IP: **NEON DELTA**, set in **Port Soleil, Solano County**.
- Wrote the core bible: README + 12 foundational docs.
  - 01 Vision & Pillars
  - 02 World & Setting
  - 03 Characters (the switchable trio + antagonists)
  - 04 Story & Structure (3 acts, 3 endings)
  - 05 Core Gameplay (loop, switching, reactive systems)
  - 06 Map & Districts (7 districts + connective tissue)
  - 07 Missions & Heists (4-phase heist system)
  - 08 Vehicles & Driving (land/sea/air, the water network)
  - 09 Weapons, Combat & Heat (legible pursuit system)
  - 10 Economy & Progression (dirty/clean money, laundering, businesses)
  - 11 Online & Shared World (anti-predatory monetization charter)
  - 12 Legal Distinctiveness (originality firewall)
- Core creative liberties taken: invented city/state, three-protagonist crew,
  live tide/storm world system, faction reputation web, hurricane-climax Act III.
