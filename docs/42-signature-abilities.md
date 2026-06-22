# 42 — Signature Abilities (Full Mechanical Design)

> Each lead has one signature state that defines their *fantasy* and their *role*
> in a heist ([doc 03](03-characters.md)). This doc fully specs the three —
> **Redline (Rae), Overwatch (Theo), Hot Streak (Frankie)** — their inputs,
> resource economy, upgrade trees, and how they interlock during the switch
> ([doc 05](05-gameplay-mechanics.md)). These are the **most-juiced verbs** in the
> game ([doc 39](39-game-feel-and-juice.md)).

## Shared framework

- **One signature per lead**, activated by a dedicated button when a **Focus meter**
  is charged.
- **Focus charges through *skillful play*** in that lead's domain — not a passive
  timer (drive daringly, infiltrate cleanly, fight aggressively). Style fuels
  power.
- **Drains while active;** ends when empty or re-pressed. A **cooldown** prevents
  spam.
- **Upgradable** along each lead's signature tree
  ([doc 10](10-economy-progression.md)) — longer duration, stronger effect, faster
  charge, new sub-abilities.
- **Accessibility:** can be set to toggle/hold, auto-charge, or always-available
  (assist) ([doc 23](23-accessibility.md)).

---

## Rae — **Redline** *(the fantasy: be the best driver alive)*

**Effect:** time dilates while driving; handling sharpens; the camera goes
cinematic; near-misses and perfect lines feel inevitable
([doc 08](08-vehicles.md), [doc 39](39-game-feel-and-juice.md)).

- **Charges via:** near-misses, drifts, clean overtakes, air time, precision under
  pursuit — *driving with flair.*
- **Core uses:** thread impossible gaps, nail a hairpin at speed, line up a
  ram/PIT, evade roadblocks and spike strips, stick a stunt jump.
- **Upgrade tree (Wheelcraft):**
  - *Duration & charge rate* tiers.
  - *Slipstream* — brief speed burst exiting Redline.
  - *Iron Nerve* — vehicle takes reduced damage during Redline.
  - *Ghost Lines* — a faint optimal-racing-line guide appears (also an
    accessibility boon).
  - *Stunt Mastery* — bigger air, auto-stabilize landings, more Focus from tricks.
- **On foot:** a weaker "reflex" version (brief slow-mo on dodges) at high tiers.
- **Heist role:** the **getaway & chase** — Rae turns escapes from panic into
  choreography ([doc 17](17-heist-catalog.md)).

---

## Theo — **Overwatch** *(the fantasy: see everything, control everything)*

**Effect:** a tactical-perception state — tag people, cameras, drones, and devices;
see tagged threats through walls (briefly); remote-hack and mark patrol routes
([doc 03](03-characters.md), [doc 19](19-living-world-ai.md)).

- **Charges via:** undetected movement, successful hacks, tagging enemies, silent
  takedowns — *control without contact.*
- **Core uses:** scout a site (Phase 1 of heists, [doc 07](07-missions.md)), reveal
  guard cones and routes, loop cameras, pop locks/lights remotely, coordinate the
  crew by marking targets the others can see.
- **Upgrade tree (Systems):**
  - *Tag capacity & wallhack duration* tiers.
  - *Drone* — deploy a recon drone; later, a hacking/utility drone
    ([doc 28](28-weapon-catalog.md)).
  - *Cascade* — chain-hack linked devices (whole camera networks at once).
  - *Blackout* — local EMP/grid kill: cameras, lights, alarms drop
    ([doc 19](19-living-world-ai.md)).
  - *Mark & Execute (squad)* — tag multiple threats; on the switch, the crew can
    clear them in a coordinated beat.
- **Heist role:** the **prep & infiltration** engine — turns gunfights into
  clockwork; the backbone of the Quiet lane ([doc 09](09-weapons-combat.md)).

---

## Frankie — **Hot Streak** *(the fantasy: ride the chaos, talk or punch your way out)*

**Effect:** an adrenaline/aggression *and* social state — faster reloads and
movement, brutal melee finishers, damage resistance; **and** a "fast-talk" mode
that defuses, distracts, or manipulates NPCs ([doc 03](03-characters.md),
[doc 36](36-character-bios.md)).

- **Charges via:** takedowns, close-range kills, successful cons/fast-talk, taking
  risks — *living dangerously and charmingly.*
- **Core uses (two faces):**
  - *Loud:* melee finisher chains, run-and-gun aggression, push through a pinned
    position ([doc 28](28-weapon-catalog.md)).
  - *Social:* fast-talk to hold an NPC's attention (the [Wash Day] distraction,
    [doc 22](22-sample-mission-script.md)), de-escalate, bluff past a checkpoint,
    or provoke a target.
- **Upgrade tree (Hustle):**
  - *Duration & charge rate* tiers.
  - *Finisher* — cinematic melee takedowns that restore Focus.
  - *Silver Tongue* — stronger social options; more NPCs are talk-able.
  - *Second Wind* — a one-time downed-state recovery while active.
  - *Crowd Work* — fast-talk affects multiple NPCs (a whole room's attention).
- **Heist role:** the **loud option & the people work** — improvisation when the
  plan breaks, and the face for any con-based approach ([doc 17](17-heist-catalog.md)).

---

## How they interlock (the switch synergy)

The signatures are designed to **combo across the Crew Wheel**
([doc 05](05-gameplay-mechanics.md)):

- **Theo tags → Rae & Frankie inherit the marks.** Overwatch intel persists for the
  others after a switch.
- **Theo Blackout → Frankie pushes** the now-dark room → **Rae waits in Redline**
  for the getaway. A three-beat heist rhythm.
- **Mark & Execute** literally rewards switching: Theo tags, switch to the gunner,
  clear the room in one breath.
- **Focus is per-lead,** so the player manages *three* meters — switching to spend a
  charged signature on the right lead at the right second is the **skill ceiling**
  of mastery.

## Signature design rules

- **Each is the lead's identity in a button** — fantasy first, balance second
  ([doc 01](01-vision.md)).
- **Charged by *style*, not timers** — they reward playing well, which makes
  playing well feel powerful ([doc 39](39-game-feel-and-juice.md)).
- **They make the switch *the* skill** — the best players orchestrate three
  signatures, not spam one ([doc 05](05-gameplay-mechanics.md)).
- **Fully accessible** — assist options never lock a player out of the fantasy
  ([doc 23](23-accessibility.md)).
