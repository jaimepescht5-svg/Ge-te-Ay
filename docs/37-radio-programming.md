# 37 — Radio Programming & Original Tracks

> Programming-level detail for the dial ([doc 13](13-radio-music.md)): how each
> station is structured, sample **original-track concepts** (titles/vibes we'd
> commission, not real songs), DJ bits, ad reads, and the reactive logic. All
> invented; music is original or licensed, never soundalike
> ([doc 12](12-legal-distinctiveness.md)).

## Station programming anatomy

Each music station loops a **programmed hour** so it feels like real radio, not a
playlist on shuffle:

```
[DJ intro/ident] → track → track → [ad read] → track → [DJ bit / dedication]
→ track → [news/weather sting] → track → [station ident] → loop
```

- **Idents & stings** are short, branded, and reactive (weather stings escalate
  with the storm, [doc 13](13-radio-music.md)).
- **Ad reads** carry satire ([doc 14](14-brand-bible.md)) — see samples below.
- **Talk stations** run segments instead of tracks (monologue, caller, ad, news).

## Sample original-track concepts (commission briefs)

> *Titles and vibes to brief composers/artists — not references to real songs.*

**Sablon FM (Latin/soul):**
- *"Marea Alta"* — uptempo salsa about rising water you dance through anyway.
- *"Café y Gasolina"* — morning-show staple; warm, brassy, hopeful.
- *"La Última Casa"* — a slow bolero about the last house on a flooding block.

**Static 99.9 (storm-rock/punk):**
- *"Boarded Up"* — thrashy anthem of the people getting bulldozed.
- *"Dry Money"* — a furious chant aimed at out-of-state buyers
  ([doc 25](25-glossary-slang.md)).
- *"Eye Wall"* — building, droning, the storm as catharsis.

**Velvet Hour (soul/funk — Rae's station):**
- *"Golden Causeway"* — the sunset-cruise theme; the screenshot in audio form.
- *"Reverse 180"* — slinky instrumental funk; unofficial getaway groove.

**Brackish Beats (electronic — night):**
- *"King Tide (Midnight Mix)"* — peaks as the night cycle deepens.
- *"Neon Saltwater"* — the Strip's pulse.

**Frequency 7 (synthwave — Theo's station):**
- *"Overwatch"* — cold, precise, late-night-drive instrumental.
- *"Ghostline"* — paranoid, beautiful, surveillance-as-melody.

**The Low End (hip-hop — Frankie's station):**
- *"Sure Thing"* — braggadocio that's all front and no funds (Frankie's anthem).
- *"Sticks"* — bouncy, self-deprecating, lovable.

## DJ bits (voice samples)

- **"Mami" Celeste (Sablon FM):** *"That one's for Doña Reyes on Marlin Ave, whose
  porch is underwater again — mija, we see you, the whole Cut sees you. Here's a
  little sunshine while the city figures out where it put your tax dollars."*
- **Hex (Static 99.9):** *"They're calling it 'revitalization.' I'm calling it
  what it is. This next one goes out to every landlord with a yacht and a flood
  map. Choke on it."*
- **The Velvet Fox (Velvet Hour):** *"It's that hour, baby. Sun's going down over
  the water, somebody's running from something, and the whole coast looks like a
  promise nobody's gonna keep. Roll the window down."*
- **Pastor Goldwynn (Gospel of Gain, AM):** *"Friends, the Lord did not raise the
  waters to drown you — He raised them to see who could *afford a boat.* Text GAIN
  to give. The blessed will be buoyant."* *(satire — and a literal laundering
  front, [doc 18](18-side-stories.md))*

## Ad reads (the satire engine, [doc 14](14-brand-bible.md))

Rotated across stations between tracks:
- *NestEgg Bank:* "Underwater on your mortgage? *Literally?* NestEgg's new
  FloodSafe™ account protects your money — from you."
- *The Ark:* "When the water comes — and friend, it's coming — will you be above
  it, or in it? The Ark. Pre-register your survival today."
- *Beacon (safety app):* "Beacon keeps your family safe with 24/7 location
  tracking. *We* always know where they are. ...Don't you want to?"
- *Gator Bites:* "New! The Stormwich. Three patties, because you don't know when
  you'll eat again. Gator Bites — fried, fast, and faintly legal."

## Reactive radio logic (recap + spec)

- **Storm escalation:** Storm Watch 24 (AM) ramps coverage; music stations get
  weather stings, then distortion, then drop into emergency tones at landfall
  ([doc 13](13-radio-music.md), [doc 04](04-story.md)).
- **News reacts to the player:** big crimes get anonymized bulletins ("police are
  searching for *three* suspects…"); faction events make the news; the city's mood
  shifts ([doc 19](19-living-world-ai.md)).
- **Signal & geography:** transmitter distance = clarity/static; the **Tide
  Pirate** roams, so its signal appears and vanishes
  ([doc 18](18-side-stories.md)).
- **Per-lead defaults:** switching to a lead can default to *their* station
  ([doc 13](13-radio-music.md)) — a tiny, free characterization beat.

## Programming design rules

- **Real-radio texture:** idents, ads, dedications, and DJ patter — not naked
  playlists ([doc 13](13-radio-music.md)).
- **Music diversity is mandatory** — the dial sounds like the melting pot
  ([doc 02](02-setting-world.md)).
- **Satire lives in the ad breaks and talk shows,** carrying theme without
  cutscenes ([doc 14](14-brand-bible.md)).
- **Everything original or cleared** ([doc 12](12-legal-distinctiveness.md)).
