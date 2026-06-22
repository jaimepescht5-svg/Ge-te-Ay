# 05 — Core Gameplay

## The core loop

> **Scheme → Equip → Travel → Execute → Escape → Spend → Repeat**, all inside a
> living city that reacts to every step.

1. **Scheme.** Pick a job (story, side, or emergent). For scores/heists, scout,
   plan, and choose an approach.
2. **Equip.** Pick the lead(s), loadout, vehicles, gadgets, disguises, and crew.
3. **Travel.** Drive/boat/fly there — traversal *is* gameplay, full of emergent
   incident.
4. **Execute.** Do the thing: loud, quiet, or clever. Improvise when it breaks.
5. **Escape.** Beat the Heat (see [doc 09](09-weapons-combat.md)) and disappear.
6. **Spend.** Bank it, launder it, upgrade your leads, your base, your fleet,
   your businesses ([doc 10](10-economy-progression.md)).

## Moment-to-moment verbs

- **Drive / boat / fly** — the soul of traversal (see [doc 08](08-vehicles.md)).
- **Shoot / fight / take down** — cover-based gunplay + grounded melee
  ([doc 09](09-weapons-combat.md)).
- **Sneak / hack / tag** — Theo's domain, but available to all via gadgets.
- **Talk / con / intimidate** — Frankie's social verbs; dialogue with stakes.
- **Climb / vault / parkour** — readable, momentum-based traversal on foot.
- **Loot / fence / launder** — turning chaos into capital.

## The switch (signature system)

Hold a button to bring up the **Crew Wheel** and switch between available leads.

- **Free-roam switch:** camera pulls up and out to the next lead, wherever they
  are in the city — they were living their own life.
- **Mission switch:** instant tactical swap between leads positioned for a job
  (Rae in the car, Theo on overwatch, Frankie on the floor). The heart of heist
  play.
- **Cooldown & rules:** brief cooldown to prevent spam; some missions lock to one
  lead; an idle lead can be given a **standing order** (hold position, cover,
  bring the car around) that they execute via simple AI.

## Reactive world systems

The city is a web of systems the player plucks:

- **Witness & report:** crimes seen by NPCs raise Heat; no witnesses, no Heat.
  Sightlines, lighting, and crowd density matter.
- **Economy reacts:** rob a district and security tightens there; flood a market
  with stolen goods and fence prices drop.
- **Faction reputation:** every job nudges your standing with Vegas, Crane, cops,
  and street crews — opening and closing options. (See [doc 10](10-economy-progression.md).)
- **Tide & weather:** routes, hiding spots, and mission availability shift with
  the live environment ([doc 02](02-setting-world.md)).
- **NPC memory (local):** rough up a shopkeeper and he won't serve you tomorrow;
  tip a valet and your car's always ready.

## Activities & emergent play

Beyond missions, the city is dense with things to *do*, designed to spawn stories:

- **Hustles** — repeatable freelance jobs (courier runs, repo work, collections,
  smuggling, bounty pickups) that feed the economy.
- **Street races & stunt jumps** — Rae's playground; time trials, point-to-points,
  pink-slip races.
- **Properties & businesses** — buy, run, and defend income-generating fronts.
- **Hobbies** — gym, ranges, golf, fishing, club nights, arcades — that double as
  light progression and tone.
- **Random encounters** — muggings, breakdowns, deals gone wrong, storm rescues:
  small authored seeds that the systems grow.

## Difficulty & accessibility (per-system)

Difficulty is **not one slider**. Players tune each axis:

- **Driving:** assist (rubber-band help, auto-brake) → simulation.
- **Combat:** aim assist strength, enemy lethality, ammo economy.
- **Stealth:** detection speed, alert memory.
- **Economy:** how punishing money/Heat loss is.
- **Accessibility:** full remap, hold/toggle everything, scalable HUD/subtitles,
  colorblind palettes, traversal/aim assists, audio cues for visual events, and
  a content-sensitivity menu with skip/soften.

## Save & flow

- Autosave at beats + manual save anywhere safe.
- Mission **checkpoints with restart-from-here and skip-to-action** options.
- A "ghost car / quick travel" system gated behind discovery (taxis, the metro,
  owned vehicles) so the world stays earned but never tedious.
