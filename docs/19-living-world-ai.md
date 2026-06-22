# 19 — The Living World & AI

> Pillar #1 is "The City Is the Star" ([doc 01](01-vision.md)). This doc specs the
> systems that make Port Soleil feel **alive, reactive, and remembered** rather
> than a stage set of waiting props.

## NPC ecology

The crowd is not wallpaper. NPCs run on a **needs-and-schedule** model scaled by
distance (full fidelity near the player, statistical far away):

- **Daily routines:** civilians have homes, jobs, and habits — markets at dawn,
  offices by day, clubs at night, shift changes at the port. Density and type
  shift by **district, time, weather, and tide** ([doc 02](02-setting-world.md)).
- **Roles & archetypes:** workers, tourists, hustlers, addicts, cops, gang
  members, street vendors, the unhoused, the elderly — each with distinct
  behaviors, not reskins.
- **Reactions are tiered:** a gunshot escalates a bystander from *curious →
  alarmed → flee → call it in* based on distance, cover, and crowd contagion
  (panic spreads).

## Local NPC memory

Persistence at the human scale makes the world feel real:

- **Shopkeepers, valets, bartenders, fences** remember recent treatment — rob or
  rough them and service/prices change; tip and they help.
- **Recurring faces:** a handful of named background NPCs reappear on their routes,
  so the player builds a mental map of "regulars."
- **Memory decays** sensibly so the world forgives over time (and so it's cheap to
  simulate).

## Faction AI (the parallel powers)

Beyond police Heat ([doc 09](09-weapons-combat.md)), the **Vegas, Crane's private
security, and street crews** run as **territorial actors**:

- **Territory & patrols:** factions hold districts; their presence, aggression,
  and patrol density respond to player rep and recent events.
- **Faction war state:** the Vega–Crane conflict is a live background sim — flare-
  ups, takeovers, and reprisals happen with or without the player, and the player
  can tip the balance.
- **Reprisal & memory:** hit a faction hard and expect ambushes, bounties, and
  business attacks; ally with one and get safe passage, discounts, and intel.

## The dynamic environment as an actor

The world's physical systems actively shape play:

- **Tide** opens/closes routes and smuggling channels on a cycle.
- **Weather/storm** changes crowd density, police presence, NPC behavior
  (boarding up, evacuating, looting), and unlocks weather-only content.
- **Power grid:** storms and player sabotage cause **rolling blackouts** that
  ripple across districts — darkening streets, killing cameras, enabling heists.
- **Traffic & economy:** road events (accidents, jams), market prices, and fence
  rates respond to time, district, and player crime saturation.

## Emergent incident system ("seeds")

A director layer spawns **authored seeds** the systems then grow, tuned to keep
the world surprising without feeling random:

- **Seed examples:** a mugging, a breakdown, a deal gone bad, a police stop, a
  street race forming, a storm rescue, a faction skirmish.
- **Director logic:** pacing-aware (more seeds when the player is wandering, fewer
  mid-mission), location-aware (the right seed for the district), and
  Heat-aware (won't dogpile a player already in trouble).
- **Outcomes feed systems:** intervene and gain rep/loot/Heat; ignore and the seed
  resolves on its own — the city doesn't wait for you.

## Police AI specifics

- **Believable origins & travel** — no teleporting; units come from real stations
  and patrols ([doc 09](09-weapons-combat.md)).
- **Last-known-position search** — they pursue where they *think* you are; juking
  them is a skill.
- **Corruption layer** — some cops can be bribed or are on faction payroll; the
  law is porous by design, supporting the theme.

## Companion & crew AI

- **Standing orders** for idle leads and hired crew (hold, cover, drive, follow).
- **Competent but not psychic** — allies help meaningfully without trivializing the
  mission; they can be downed and need support (reinforcing "survive together").
- **Specialist quality scales with pay** ([doc 10](10-economy-progression.md)) —
  cheap crew panic and miss; elite crew execute.

## Performance & fidelity strategy

- **LOD'd simulation:** full behavior in a bubble around the player; cheaper
  statistical sim beyond; persistent *state* (faction control, business
  ownership, Heat) is always tracked even when not rendered.
- **Determinism where it matters** so designers can author and test reliably;
  controlled randomness where it adds life.

## The test we hold it to

> *"Stand on a corner for five minutes and do nothing. Is it interesting?"*
> If the answer isn't yes — routines, reactions, a seed, a faction patrol, the
> tide creeping up the curb — the living-world systems aren't done.
