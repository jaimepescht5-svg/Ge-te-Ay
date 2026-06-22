# 51 — Enemy & Faction Roster

> The forces that push back ([doc 09](09-weapons-combat.md),
> [doc 19](19-living-world-ai.md)). Every enemy is **telegraphed and counterable**
> ([doc 49](49-difficulty-and-balance.md)); difficulty makes them *smarter*, never
> psychic. Factions are *people with territory and motives*
> ([doc 03a](03a-cast-relationships.md)), not faceless spawn-fodder.

## The four pursuit forces

Four parallel "Heat"-style systems, each with its own triggers, territory, and feel
([doc 09](09-weapons-combat.md), [doc 19](19-living-world-ai.md)):

| Force | Triggered by | Feel | Where |
|---|---|---|---|
| **Soleil PD / Sheriff** | Public crime, witnesses | Procedural, escalating, bribable | Everywhere; densest Downtown |
| **Vega organization** | Hitting Vega money/turf | Old-school, professional, vengeful | The Reach, casinos, the Cut |
| **Crane private security** | Hitting Crane assets | Corporate, well-equipped, cold | The Heights, The Ark, Downtown tower |
| **Street crews** | Turf disputes, opportunism | Chaotic, local, reputation-driven | The Glades, Sabal, the Cut edges |

## Police escalation roster (by Heat tier, [doc 09](09-weapons-combat.md))

| Tier | Units | Behavior |
|---|---|---|
| **Noticed** | Beat cop, patrol car | Investigate, call it in |
| **Reported** | Multiple patrols | Converge on last-known-position |
| **Pursuit** | Pursuit cars, bikes, spike strips, roadblocks | Active chase, contain |
| **Crackdown** | Tactical units, helicopter, district lockdown | Overwhelming; you must *leave* |

- **No teleporting** — units have real origins and travel time
  ([doc 19](19-living-world-ai.md)).
- **Corruption layer** — some can be bribed or are on a faction payroll
  ([doc 36](36-character-bios.md)).

## Enemy archetypes (the building blocks)

Designed so encounters are **readable puzzles**, mixed and matched
([doc 49](49-difficulty-and-balance.md)):

| Archetype | Threat | The counter (its tell) |
|---|---|---|
| **Grunt** | Basic gunner | Standard cover trade; flanks if you camp |
| **Rusher** | Shotgun/melee closer | Audible charge; punish the approach |
| **Marksman** | Ranged pressure, pins you | Laser/glint tell; break LoS, flank |
| **Heavy** | Armored, soaks damage | Slow, telegraphed; hit weak points, kite |
| **Tech/Drone op** | Cameras, drones, calls reinforcements | Tag & prioritize (Theo); cut the signal |
| **Hound/tracker** | Finds you in stealth | Dog/scanner tell; misdirect, distract |
| **Lieutenant** | Buffs/coordinates a group | Marked; killing it scatters the squad |

## Faction "flavor" enemies (identity, not reskins)

- **Vega:** disciplined shooters, old-money muscle, made-men lieutenants; fight
  *smart and proud* ([doc 03a](03a-cast-relationships.md)).
- **Crane security:** corporate contractors with the best gear, drones, and
  body-cams; cold, coordinated, *expensive* ([doc 36](36-character-bios.md)).
- **Street crews:** uneven but unpredictable, lots of rushers, local knowledge;
  *chaotic and personal*.
- **Glades militias:** ambushers, traps, airboats, home-terrain advantage
  ([doc 41](41-districts-the-rest.md)).

## Encounter design (how they're used)

- **Composition over count** — a smart *mix* (marksman + rusher + lieutenant) beats
  a bigger blob; harder difficulty changes *composition and coordination*, not
  aimbot ([doc 49](49-difficulty-and-balance.md)).
- **Telegraph everything** — every archetype has an audible/visual tell so failure
  is fair and learnable ([doc 09](09-weapons-combat.md)).
- **Reward the right approach** — encounters have stealth, loud, and clever
  solutions; enemy placement supports all three ([doc 07](07-missions.md)).
- **Surrender & restraint exist** — enemies panic, flee, and surrender; the
  non-lethal path is real ([doc 28](28-weapon-catalog.md)).

## Faction war state (the living backdrop)

The **Vega–Crane cold war** runs as a background sim
([doc 19](19-living-world-ai.md)):
- **Territory** shifts over time and with player action; **flashpoints** erupt the
  player can tip ([doc 38](38-dynamic-events-calendar.md)).
- **Reprisal & memory** — hit a faction and face ambushes, bounties, and business
  raids; ally and get safe passage and intel ([doc 10](10-economy-progression.md)).
- **Boyd** floats across all of it — the corrupt cop as a recurring,
  story-triggered antagonist ([doc 36](36-character-bios.md)).

## Boss / set-piece antagonists

Not bullet-sponges — **mechanically distinct confrontations** tied to story
([doc 17](17-heist-catalog.md), [doc 04](04-story.md)):
- **Det. Boyd** — a recurring hunter (chases, traps, a final reckoning), beaten by
  *outsmarting*, not just outshooting.
- **La Señora** — confronted through the collapse of her order more than a shootout
  ([doc 36](36-character-bios.md)).
- **Sterling Crane** — the finale; the "fight" is the heist itself and the choice
  it forces ([doc 17](17-heist-catalog.md), [doc 44](44-themes-and-meaning.md)).

## Design rules

- **Every enemy is a readable puzzle** with a fair tell
  ([doc 49](49-difficulty-and-balance.md)).
- **Factions have identity** — you can tell who's shooting at you by *how* they
  fight ([doc 03a](03a-cast-relationships.md)).
- **Smarter, not cheating** at higher difficulty ([doc 19](19-living-world-ai.md)).
- **All three approaches always have an answer** in every encounter
  ([doc 07](07-missions.md)).
