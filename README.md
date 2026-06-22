# NEON DELTA

### An open-world crime saga. Sun, sin, and salt water.

> *"Everybody in Solano County is running from something. Most of them are doing it at ninety miles an hour."*

**NEON DELTA** is a third-person, open-world action game set in a fictional
sun-bleached metropolis on a fictional Gulf coast. You drive, you scheme, you
shoot, you climb a criminal ladder slick with neon and saltwater — and you do
it your way, across a living city that never stops moving.

This repository is the **living design bible** for the game: vision, world,
characters, story, systems, economy, and the technical and legal scaffolding
that keeps it an original work.

---

## The one-paragraph pitch

In the drowning paradise of **Port Soleil**, three strangers are bound together
by one catastrophically botched score. A washed-up stunt driver, a burned
intelligence contractor, and a small-time grifter with big-time debts decide
the only way out of the hole is to dig straight through the people who put them
there — the cartels, the developers, the cops, and the storm-chasing billionaires
buying the coast out from under everyone. It's a story about reinvention,
loyalty, and the American hustle, told in a city that is one hurricane away from
the bottom of the sea.

---

## What this is (and isn't)

This is a **clean-room, legally distinct** open-world crime game design. It
borrows the *genre* — open worlds, driving, shooting, heists, crime sandboxes —
none of which any company owns. It deliberately invents its own:

- **City & geography** (Port Soleil / Solano County, not any real or trademarked city)
- **Characters, names, and likenesses**
- **Story, factions, and brands**
- **UI language, radio, and tone**

See [`docs/12-legal-distinctiveness.md`](docs/12-legal-distinctiveness.md) for
the full firewall.

---

## Documentation map

| Doc | What's inside |
|-----|---------------|
| [00 — Master Index & Reading Guide](docs/00-index.md) | **Start here** — where to begin and how the docs relate |
| [01 — Vision & Pillars](docs/01-vision.md) | The creative north star and design pillars |
| [02 — World & Setting](docs/02-setting-world.md) | Port Soleil, Solano County, the era and tone |
| [03 — Characters](docs/03-characters.md) | The crew, the antagonists, the supporting cast |
| [03a — Cast & Relationships](docs/03a-cast-relationships.md) | The full social web and relationship systems |
| [04 — Story & Structure](docs/04-story.md) | Three-act narrative, themes, branching |
| [05 — Core Gameplay](docs/05-gameplay-mechanics.md) | The moment-to-moment loop |
| [06 — Map & Districts](docs/06-map-districts.md) | The city's neighborhoods and the wider county |
| [07 — Missions & Heists](docs/07-missions.md) | Mission design philosophy and the heist system |
| [08 — Vehicles & Driving](docs/08-vehicles.md) | The fleet and the driving model |
| [09 — Weapons & Combat](docs/09-weapons-combat.md) | Gunplay, melee, and the threat system |
| [10 — Economy & Progression](docs/10-economy-progression.md) | Money, businesses, skills |
| [11 — Online & Shared World](docs/11-online-multiplayer.md) | The persistent multiplayer city |
| [12 — Legal Distinctiveness](docs/12-legal-distinctiveness.md) | Keeping it original |
| [13 — Radio & Music](docs/13-radio-music.md) | The dial, DJs, and adaptive score |
| [14 — Brand Bible](docs/14-brand-bible.md) | Every invented brand in the world |
| [15 — Art Direction](docs/15-art-direction.md) | The visual identity |
| [16 — Vertical Slice: Prologue](docs/16-vertical-slice-prologue.md) | The playable opening, beat by beat |
| [17 — Heist Catalog](docs/17-heist-catalog.md) | The nine marquee scores |
| [18 — Side Stories](docs/18-side-stories.md) | Character arcs, strangers, collectibles |
| [19 — Living World & AI](docs/19-living-world-ai.md) | NPC ecology, faction AI, emergent systems |
| [20 — Tech & Production](docs/20-tech-and-production.md) | Engine pillars, scope, milestones, risks |
| [21 — Phone & Meta UI](docs/21-the-phone-and-meta-ui.md) | The in-fiction phone hub and HUD |
| [22 — Sample Mission Script](docs/22-sample-mission-script.md) | "Wash Day" written out to show the voice |
| [23 — Accessibility](docs/23-accessibility.md) | The full accessibility spec |
| [24 — World Lore & Timeline](docs/24-world-lore-timeline.md) | The deep history of Solano County |
| [25 — Glossary & Slang](docs/25-glossary-slang.md) | Team terminology + in-world street slang |
| [26 — Pitch & Positioning](docs/26-pitch-and-positioning.md) | The elevator pitch and market framing |
| [27 — Vehicle Catalog](docs/27-vehicle-catalog.md) | The full fleet: land, sea, air |
| [28 — Weapon Catalog](docs/28-weapon-catalog.md) | The full arsenal and gadgets |
| [29 — Wardrobe & Customization](docs/29-wardrobe-and-customization.md) | Dressing the leads; clothing as a system |
| [30 — Post-Launch Roadmap](docs/30-post-launch-roadmap.md) | Expansions, seasons, and the monetization lines |
| [31 — Announce Trailer Script](docs/31-announce-trailer-script.md) | The ~90s reveal trailer, shot by shot |
| [32 — FAQ](docs/32-faq.md) | Anticipated questions, answered |
| [33 — District Deep-Dive: The Cut](docs/33-district-deepdive-the-cut.md) | One district to ship-quality, the template |
| [34 — Economy Balance](docs/34-economy-balance.md) | Worked numbers, curves, anti-grind guarantees |
| [35 — Mission Flow & Pacing](docs/35-mission-flow-and-pacing.md) | Campaign structure, mission anatomy, rhythm |
| [36 — Character Bios](docs/36-character-bios.md) | Deep backstories for the principal cast |
| [37 — Radio Programming](docs/37-radio-programming.md) | Station programming, original tracks, ad reads |
| [38 — Dynamic Events Calendar](docs/38-dynamic-events-calendar.md) | The living city's cyclical, scheduled & reactive events |
| [39 — Game Feel & Juice](docs/39-game-feel-and-juice.md) | Camera, input, haptics, and the polish that sells it |
| [40 — Sound Design](docs/40-sound-design.md) | Ambience, foley, weapons, vehicles, the storm |
| [41 — The Rest of the Map](docs/41-districts-the-rest.md) | Design briefs for the other six districts |
| [42 — Signature Abilities](docs/42-signature-abilities.md) | Full design of Redline, Overwatch, Hot Streak |
| [43 — Achievements & Completion](docs/43-achievements-and-completion.md) | The trophy list and 100% definition |
| [44 — Themes & Meaning](docs/44-themes-and-meaning.md) | What the game is actually about |
| [45 — Solano Online (Deep Dive)](docs/45-solano-online-deepdive.md) | Crews, co-op heists, businesses, anti-grief |
| [46 — Localization & Culturalization](docs/46-localization-and-culturalization.md) | Shipping the city's voice worldwide, respectfully |
| [47 — Photo Mode & Community](docs/47-photo-mode-and-community.md) | Capture, sharing, creator tools, moderation |
| [48 — Narrative Branching System](docs/48-narrative-branching-system.md) | The flags/meters/gates choice machinery |
| [49 — Difficulty & Balance](docs/49-difficulty-and-balance.md) | Per-system difficulty axes and balance design |

---

## Status

🟢 **Active design.** This bible is being iterated and expanded continuously.
See [`CHANGELOG.md`](CHANGELOG.md) for the build history.
