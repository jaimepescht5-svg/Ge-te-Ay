# 33 — District Deep-Dive: The Cut

> The production strategy is **"one district to ship-quality first, then scale"**
> ([doc 20](20-tech-and-production.md)). This is that district — **the Cut (Old
> Soleil)** — specced in detail as the **template** that sets the quality bar,
> the per-district cost, and the pipeline for the rest of the map
> ([doc 06](06-map-districts.md)).

## Why the Cut is the template

- It's the crew's **emotional home** (Tomás's garage, the leads' first allies) —
  so it carries story weight and gets the most player hours early.
- It exercises **every core system**: dense foot traffic, canal/boat traversal,
  tight driving, stealth interiors, faction presence, tide flooding, and the
  Reclamation theme ([doc 02](02-setting-world.md)).
- If we can make the Cut sing, we know how to build the other six.

## Identity

**Old Soleil:** the historic canal district — pastel rowhouses, supper clubs,
street markets, murals, working-class melting pot — being "revitalized" into
oblivion by Crane Coastal ([doc 24](24-world-lore-timeline.md)). Warm, intimate,
lived-in, and visibly sinking. **The beating, breaking heart of the city.**

## Layout & landmarks

```
        ┌──── to Downtown Core ────┐
        │                          │
   [Marlin Ave market] —— [Canal Plaza] —— [the El station]
        │                    │  (boat hub)        │
   [Tomás's Garage] ——— [Mercado del Sol] ——— [the Murals Walk]
   (crew HQ)               (covered market)        │
        │                    │                [Mama Yo's-adjacent edge]
   [Canal row / boat docks] ─┴── [the Sinking Blocks] ── to the Glades
                                   (flood zone)
```

- **Tomás's Garage (HQ)** — the player's anchor: storage, mods, the planning Board
  ([doc 17](17-heist-catalog.md)), and the heart of Rae's arc ([doc 18](18-side-stories.md)).
- **Canal Plaza** — the social/boat hub; the Cut's town square; a boat-taxi node.
- **Mercado del Sol** — a dense covered market: crowd-cover, pickpockets, fences,
  food, and a great foot-chase arena.
- **The Murals Walk** — the people's history in paint; a collectible hunt
  ([doc 18](18-side-stories.md)).
- **The Sinking Blocks** — the flood-prone edge where the tide system is most
  dramatic; boats become essential at high tide.
- **The El station** — fast-travel + a rooftop-chase line ([doc 06](06-map-districts.md)).

## How the systems show up here (the showcase)

| System | In the Cut |
|---|---|
| **Tide/flood** ([doc 02](02-setting-world.md)) | Canal row & Sinking Blocks flood on cycle; routes open/close; boats matter |
| **Living world** ([doc 19](19-living-world-ai.md)) | Market dawn rush, supper-club nights, regulars on routes, NPC memory at the garage & stalls |
| **Faction AI** | Contested turf: Vega old-guard vs. Crane's "security"/demolition crews; the war is visible block by block |
| **Heat** ([doc 09](09-weapons-combat.md)) | Tight alleys & canals = great escapes; market crowds to vanish into |
| **Economy** ([doc 10](10-economy-progression.md)) | First fence, the 24-Hour Wash front (H2), market hustles |
| **Driving** ([doc 08](08-vehicles.md)) | Narrow, technical streets; canal boat-roads; the El for rooftop chases |
| **Theme** | The Reclamation arc ([doc 18](18-side-stories.md)) — gentrification as the slow crime under the loud one |

## Content density (the bar for "no filler")

What a player can find in the Cut alone — proving the "every block has a reason"
rule ([doc 06](06-map-districts.md)):

- **Story:** prologue aftermath beats, H2 "Wash Day" ([doc 22](22-sample-mission-script.md)),
  Reclamation arc, Rae's Garage arc.
- **Hustles:** courier runs, market collections, chop-shop orders, boat-smuggling
  to the Glades.
- **Activities:** a canal boat-race circuit, a stunt-jump over the drawbridge
  approach, gym & supper-club hangs.
- **Strangers:** the holdout grandmother, the muralist, the tenant organizer, the
  flooded-out fisherman ([doc 18](18-side-stories.md)).
- **Collectibles:** the Murals Walk, two tide-line shrines, one low-tide sunken
  cache in the canal ([doc 18](18-side-stories.md)).
- **Living seeds:** demolition-crew confrontations, a flood rescue at king tide,
  a Vega/Crane skirmish, a market pickpocket chase ([doc 19](19-living-world-ai.md)).

## Time-of-day & tide states (the district has moods)

| State | What changes |
|---|---|
| **Dawn** | Market sets up; fishermen on the canals; quiet, hopeful light |
| **Noon** | Heat, sparse crowds, exposed; demolition crews active |
| **Golden hour** | The signature look; supper clubs warming up; cruising |
| **Night** | Clubs, neon on wet stone, the Cut's other self; more crime seeds |
| **Low tide** | Sunken cache exposed; canal shortcuts on foot |
| **King tide** | Sinking Blocks flooded; boats mandatory; rescue seeds spawn |
| **Storm** | Boarding up, evacuation, looting opportunities; the Cut at its most vulnerable |

## Vertical-slice / quality checklist for the Cut

- [ ] **Five-minute corner test** passes at three different times/tides
      ([doc 19](19-living-world-ai.md)).
- [ ] A player can complete a **full Quiet, Loud, *and* Clever** run of H2 here.
- [ ] **Boat traversal** feels as good as driving when the tide's in.
- [ ] The **Reclamation theme reads** environmentally without a single cutscene
      (boarded shops, demolition notices, "luxury" hoardings over murals).
- [ ] Every landmark is **navigable from memory** ([doc 06](06-map-districts.md)).
- [ ] Art identity is unmistakable — pastel-and-rot, tide-stained, neon-warm
      ([doc 15](15-art-direction.md)).

## What building the Cut teaches the rest of the map

- **Per-district cost** (art, AI, mission, audio hours) → schedule the other six.
- **Reusable kit:** market stalls, canal/boat nav mesh, flood tech, faction-turf
  tooling, NPC-routine templates — built here, reused everywhere.
- **The bar:** every other district must hit the Cut's density and mood, or it
  doesn't ship ([doc 01](01-vision.md)).
