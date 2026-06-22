# 20 — Technical Direction & Production

> This is a **design bible**, not an engine spec — but a design this ambitious has
> to be honest about how it gets built. This doc frames the technical pillars,
> scope discipline, milestones, team shape, and risks.

## Technical pillars (what the tech must deliver)

1. **A seamless, streaming open world** — no loading walls between districts,
   land/sea/air traversal, interiors that matter.
2. **A simulated city** — LOD'd NPC ecology, faction AI, traffic, and persistent
   world state ([doc 19](19-living-world-ai.md)).
3. **Dynamic environment** — day/night, tide, weather, and a full storm system
   that reshapes geometry and gameplay ([doc 02](02-setting-world.md)).
4. **Water as a first-class system** — rendering, physics, and flood/tide
   simulation, because the whole theme rides on it.
5. **The switch** — fast, seamless protagonist swapping with off-screen world
   persistence.
6. **Online at parity** — the same world simulated for shared play
   ([doc 11](11-online-multiplayer.md)).

## Engine stance

- **Buy vs. build:** favor a mature, licensable AAA engine with strong open-world,
  streaming, and rendering foundations; invest custom tech only where the game's
  identity demands it (**water/tide/flood, the switch, faction sim, adaptive
  audio**). Don't reinvent solved problems.
- **Tooling is a feature:** world-building, mission scripting, and the emergent-
  seed director need first-class editor tooling — content velocity is the real
  bottleneck on a game this size.
- **Determinism where designers need it** for authoring and test; controlled
  randomness for life.

## Scope discipline (how a game this big ships)

The fastest way to kill this project is to build all of it at once. Strategy:

- **Vertical slice first** — the prologue ([doc 16](16-vertical-slice-prologue.md))
  proves the pillars before the world is scaled.
- **One district to ship-quality** (the Cut) as the template that sets the bar and
  the per-district cost, *then* scale.
- **Systems before content** — the heist, Heat, faction, and world sims must be
  solid before mass mission production, or everything gets rebuilt.
- **Cut from the edges, never the core** — the three leads, the switch, the heist
  craft, and the living city are non-negotiable; district count, vehicle count,
  and side-arc count flex.

## Milestone roadmap (illustrative)

| Phase | Goal | Exit criteria |
|---|---|---|
| **Concept** | Lock vision, IP, pillars | This bible; originality review ([doc 12](12-legal-distinctiveness.md)) |
| **Prototype** | Prove the verbs | Driving, shooting, stealth, the switch feel good in a gray box |
| **Vertical Slice** | Prove the game | The prologue is fun, looks like the art target, passes review gates |
| **First Playable / 1 District** | Prove the pipeline | The Cut at ship quality; per-district cost known |
| **Production** | Build the world | Districts, heists, side arcs to bar; systems locked |
| **Alpha** | Content complete | Whole campaign playable start-to-end |
| **Beta** | Polish & fix | Stability, performance, accessibility, balance, localization |
| **Online** | Shared world | Solano Online at parity; monetization charter enforced |
| **Launch** | Ship | Day-1 quality; no crunch-debt; post-launch plan ready |

## Team shape (disciplines that make-or-break this)

- **World/level design & environment art** (the biggest lift — the city is the
  star).
- **Systems/gameplay engineering** (switch, Heat, factions, heists, water).
- **Narrative** (3 leads, branching, side arcs, a *lot* of reactive dialogue).
- **AI engineering** (ecology, factions, police, companions, the director).
- **Tools engineering** (content velocity).
- **Audio** (adaptive score + the reactive dial — a signature, not an afterthought).
- **Tech art / rendering** (water, weather, the look in [doc 15](15-art-direction.md)).
- **Accessibility & UX** as a discipline from day one ([doc 23](23-accessibility.md)).
- **QA & live-ops** scaled for an open world + online.

## Production values & ethics

- **No crunch as a plan.** Realistic scope and dates; overtime is a failure
  signal, not a strategy. Sustainable pace is a production pillar.
- **Diverse, well-supported team** — the melting-pot fiction demands authentic
  voices in the room, not just on screen.
- **Localization & culturalization** planned early, not bolted on.

## Risk register (top risks & mitigations)

| Risk | Mitigation |
|---|---|
| **Scope explosion** | Vertical slice + one-district-first; cut from edges |
| **Systems-vs-content collision** | Lock core sims before mass content |
| **Water/storm tech is hard** | Prototype it *early*; it's core, fund it first |
| **The switch underwhelms** | Prove it in the prototype; it's the signature verb |
| **Open-world emptiness** | The "five-minute corner" test ([doc 19](19-living-world-ai.md)) |
| **Online warps single-player** | Separate economy/balance; SP never gated by online |
| **Legal/IP exposure** | The firewall ([doc 12](12-legal-distinctiveness.md)) + counsel gates |
| **Live-service trust** | The monetization charter as a hard, public commitment |

## Definition of done (the whole game)

> A player can lose forty hours in Port Soleil, tell a dozen stories no script
> wrote, feel the three leads in their hands and their heart, never feel nickel-
> and-dimed, and never once mistake the city for anywhere else.
