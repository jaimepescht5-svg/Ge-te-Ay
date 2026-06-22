# 53 — Decisions Log & Open Questions

> Real design bibles aren't lists of certainties — they're records of **choices
> made (and why)** and **questions still open**. This doc keeps the team honest:
> it surfaces the tradeoffs behind the confident prose elsewhere, so nothing reads
> as settled that isn't, and so future-us remembers *why*.

## Part A — Decisions made (and the roads not taken)

### D1 — Three protagonists, not one or five
**Chosen:** a switchable trio ([doc 03](03-characters.md)).
**Rejected:** a single lead (less tactical/narrative range), or a larger rotating
cast (dilutes attachment, balloons VO/animation cost).
**Why:** three is enough for distinct heist roles and a real ensemble, few enough
to make the player *love* each one and to keep production sane
([doc 20](20-tech-and-production.md)).

### D2 — Three approaches (Quiet/Loud/Clever), economically weighted
**Chosen:** mechanically distinct approaches with EV-balanced payoffs
([doc 07](07-missions.md), [doc 34](34-economy-balance.md)).
**Rejected:** loud-vs-stealth as flavor only.
**Why:** it's the heart of "crime is a craft" ([doc 01](01-vision.md)) — but it's
the single biggest content-cost decision (every heist authored 3×). Mitigated by
fork-the-middle/rejoin-the-escape ([doc 48](48-narrative-branching-system.md)).

### D3 — A living, drowning city with real tide/storm systems
**Chosen:** environment as an actor ([doc 02](02-setting-world.md),
[doc 19](19-living-world-ai.md)).
**Rejected:** static weather/skybox set dressing.
**Why:** it *is* the theme ([doc 44](44-themes-and-meaning.md)) — but the water/
flood tech is the **highest technical risk** ([doc 20](20-tech-and-production.md));
funded and prototyped first, or the concept doesn't hold.

### D4 — Public anti-predatory monetization charter
**Chosen:** cosmetics/convenience only, earnable-first, no P2W
([doc 11](11-online-multiplayer.md)).
**Rejected:** industry-standard monetization treadmills.
**Why:** trust and differentiation ([doc 26](26-pitch-and-positioning.md)). The
open business-model question is revenue sufficiency — addressed via premium box,
two paid story expansions, and fair cosmetics ([doc 30](30-post-launch-roadmap.md)),
not power sales.

### D5 — Sincere-pulp tone (punch up, never down)
**Chosen:** satire of institutions, love for people ([doc 44](44-themes-and-meaning.md)).
**Rejected:** edgelord nihilism.
**Why:** it's the only tone where the heart and the comedy both work — and the
ethical line we hold ([doc 01](01-vision.md)).

### D6 — Accessibility as a launch pillar
**Chosen:** per-system difficulty + full a11y from pre-pro
([doc 23](23-accessibility.md)).
**Rejected:** post-launch patch.
**Why:** audience reach and values; cheaper and better when built in, not bolted on
([doc 20](20-tech-and-production.md)).

## Part B — Open questions (genuinely unresolved)

> These need prototyping, playtesting, or a stakeholder call. **Flagged, not
> hidden.**

### Q1 — Map scale: how big is "big enough"?
Curated density vs. raw size ([doc 06](06-map-districts.md)). **Open:** the exact
district count and square mileage that delivers "crossing a world" without bloat.
**Resolve via:** build the Cut, measure cost/fun, extrapolate
([doc 33](33-district-deepdive-the-cut.md)).

### Q2 — Free-roam switch fidelity
Should idle leads be **fully simulated** living their lives, or convincingly faked
on switch-in? ([doc 05](05-gameplay-mechanics.md)) **Open:** the performance/illusion
tradeoff. **Resolve via:** prototype both; player can't usually tell — find the
cheapest convincing version.

### Q3 — Online ↔ single-player relationship
Shared map, separate economy ([doc 11](11-online-multiplayer.md),
[doc 45](45-solano-online-deepdive.md)). **Open:** how much *content pipeline* is
shared without online warping SP balance or schedule. **Resolve via:** firm
separation of balance; decide content-sharing per-system.

### Q4 — How punishing should "loud" really be in the Heights?
We *want* approach choice to matter ([doc 17](17-heist-catalog.md), H6). **Open:**
the exact penalty that teaches without feeling unfair/scripted.
**Resolve via:** playtest the fairness metric ([doc 01](01-vision.md)).

### Q5 — Endings: lock-in vs. always-available
Clean Break is the floor; others are earned ([doc 48](48-narrative-branching-system.md)).
**Open:** whether players should be able to *see* which ending they're trending
toward, or discover it. **Resolve via:** playtest for satisfaction vs. surprise.

### Q6 — Pirate-radio / Tide Pirate scope
A roving signal is charming but a content/audio cost
([doc 18](18-side-stories.md), [doc 37](37-radio-programming.md)). **Open:** how much
unique content it justifies. **Resolve via:** scope against player-delight ROI.

### Q7 — Creator tools: launch or post-launch, and how deep?
([doc 47](47-photo-mode-and-community.md)) **Open:** moderation cost and scope.
**Resolve via:** post-launch, gated on moderation readiness.

## Part C — Risks we're watching (cross-ref [doc 20](20-tech-and-production.md))

| Risk | Status | Owner question |
|---|---|---|
| Scope explosion | **Live** | Is the Cut on budget? |
| Water/storm tech | **Live, highest** | Does the prototype hold up? |
| 3× heist content cost | **Live** | Is fork-the-middle saving enough? |
| Online warps SP | **Watching** | Are balances truly separate? |
| Monetization revenue | **Watching** | Do expansions + cosmetics sustain it? |
| Legal/IP drift | **Mitigated** | Firewall + counsel gates ([doc 12](12-legal-distinctiveness.md)) |

## How to use this doc

- **Update it when a decision is made or a question resolves** — move items from B
  to A with a rationale.
- **Nothing here is shameful** — an honest open question is worth more than false
  certainty ([doc 01](01-vision.md)).
- **Decisions cite pillars** — when we choose, we say which pillar broke the tie.
