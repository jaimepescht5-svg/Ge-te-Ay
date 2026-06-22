# 40 — Sound Design (Non-Music)

> Music has its own docs ([13](13-radio-music.md), [37](37-radio-programming.md)).
> This is everything *else* the player hears — the ambience, foley, weapons,
> vehicles, UI, and the storm — the audio that makes Port Soleil a **place** and
> makes the verbs feel good ([doc 39](39-game-feel-and-juice.md)).

## Audio thesis

**Sound is half of feel and most of immersion.** A city you can hear with your eyes
closed — and tell *which district, what time, what's coming* — is the goal. Audio
also carries gameplay information (threats, Heat, the storm) and must do so
accessibly ([doc 23](23-accessibility.md)).

## Ambience: the city you can hear

Each district has a **distinct soundscape** layered by time/tide/weather
([doc 06](06-map-districts.md), [doc 38](38-dynamic-events-calendar.md)):

| District | Signature ambience |
|---|---|
| Downtown Core | Traffic hum, AC drone, club bleed, helicopter wash, glass-canyon reverb |
| The Cut | Markets, music from windows, lapping canal water, gulls, scooters |
| Marisol Heights | Quiet, sprinklers, distant gates, manicured *absence* of noise |
| The Reach | Cranes, containers, ship horns, rail, machinery, sodium-lit emptiness |
| Cayo Brava/Keys | Surf, halyards clinking, gulls, party bass, jet-craft |
| Bayou Verde | Insects, frogs, airboat fans, birds, the deep hush of the swamp |
| Sabal Springs | Cicadas, AC units, highway drone, strip-mall jingles, heat-silence |

- **Tide & weather rewrite ambience** — floodwater, wind, rain on different
  surfaces; the soundscape *tells you* the world state.
- **Reactive crowd VO** — district-appropriate, multilingual barks and chatter
  that respond to the player ([doc 19](19-living-world-ai.md)).

## Foley & body audio (grounding the player)

- **Surface-specific footsteps** (wet stone, sand, swamp muck, marble, gravel),
  fabric rustle, gear/jewelry rattle (per lead — Frankie's gold, Rae's keys).
- **Interaction foley** — doors, locks, vaults, hotwiring, looting; tactile and
  specific so actions feel *physical* ([doc 39](39-game-feel-and-juice.md)).
- **Per-lead movement signatures** — subtle differences so you can almost hear who
  you're playing.

## Weapon audio (the punch)

- **Layered gunshots:** mechanical action + report + tail/reflection that changes
  with the space (tight room vs. open causeway vs. canyon of towers).
- **Distance & material modeling** — far gunfire sounds far; bullets *thunk*,
  *crack*, or *ping* by surface ([doc 28](28-weapon-catalog.md)).
- **Suppressed ≠ silent** — a meaningful, satisfying difference that supports the
  Quiet lane ([doc 09](09-weapons-combat.md)).
- **Audio sells the hit** more than visuals — the meat of combat feel
  ([doc 39](39-game-feel-and-juice.md)).

## Vehicle audio (Rae's whole world)

- **Per-vehicle engine character** — modeled load/RPM, gear shifts, turbo, exhaust
  note; a muscle car and a supercar should be unmistakable by ear
  ([doc 27](27-vehicle-catalog.md)).
- **Surface & speed** — tire chirp, gravel, the causeway expansion-joint boom, the
  drag and splash of floodwater.
- **Boats & aircraft** — airboat fan roar, hull slap, seaplane spool-up; the water
  and air fleets get full treatment ([doc 08](08-vehicles.md)).
- **Redline audio** — engine note deepens and the world ducks as time dilates; an
  audio signature for the signature verb.

## The storm (the audio set-piece)

Act III's hurricane is **scored in sound design** as much as music
([doc 38](38-dynamic-events-calendar.md)):

- **Building dread** — wind rising layer by layer, rain intensifying across
  surfaces, distant transformers blowing.
- **Landfall** — a wall of wind, debris impacts, structural groans, the deep
  pressure of the surge, the radio dissolving into emergency tones
  ([doc 37](37-radio-programming.md)).
- **The eye** — sudden, uncanny near-silence; just dripping and the player's own
  breath — the most powerful audio moment in the game.

## UI & feedback audio

- **Diegetic-leaning UI sounds** (the phone, the Crew Wheel) that fit the world
  ([doc 21](21-the-phone-and-meta-ui.md)).
- **Informative cues:** Heat-proximity stings, threat directionality, low-health
  heartbeat, objective pings — clear, never fatiguing.

## Accessibility & mix (critical)

- **Captioned sound events** — visual indicators for gunfire direction, vehicles,
  alarms, storm warnings, so audio info is never *only* audio
  ([doc 23](23-accessibility.md)).
- **Separate volume buses** (dialogue, SFX, music/radio, ambience) +
  **dialogue-boost / dynamic-range compression** for clarity and night-play.
- **3D/spatial audio** for immersion and competitive fairness (online,
  [doc 11](11-online-multiplayer.md)).
- **No information conveyed by sound alone** — a hard accessibility rule
  ([doc 23](23-accessibility.md)).

## Sound design rules

- **Hearability of the world state** — a blindfolded player should sense district,
  time, tide, threat, and storm stage.
- **Audio-led feel** — let sound carry the weight of impacts and speed
  ([doc 39](39-game-feel-and-juice.md)).
- **Original & licensed-clean** — recorded/created assets; no lifted signatures
  ([doc 12](12-legal-distinctiveness.md)).
- **Restraint in the mix** — a clear hierarchy so the important sound always cuts
  through.
