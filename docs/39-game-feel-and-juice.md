# 39 — Game Feel & Juice

> "Game feel" is the invisible layer that separates a competent open-world game
> from one that's a *joy* to simply move around in. This doc specs the
> moment-to-moment tactility — camera, input, feedback, haptics, and "juice" —
> that makes Port Soleil feel good in the hands ([doc 01](01-vision.md) pillar #2:
> *Freedom With Friction*).

## The feel thesis

**Every core verb should be satisfying before any content is attached.** If
driving an empty street, firing at a wall, or vaulting a railing isn't already
fun, no mission will save it. We tune **feel first, content second**
([doc 20](20-tech-and-production.md)).

## Input feel

- **Low-latency, readable response.** Inputs register instantly; the character is
  responsive but *weighted* — momentum exists, but never input lag disguised as
  realism.
- **Analog everything.** Walk/jog/sprint, lean, throttle, and aim are analog and
  expressive, not binary.
- **Forgiveness windows.** Coyote-time on traversal, generous interaction radii,
  and snap-to-cover that never feels sticky — assists that hide friction without
  removing skill.

## Camera (the unsung hero of feel)

- **Speed-reactive FOV & pull-back** — the car-cam widens and drops as you
  accelerate; the world *rushes*; braking settles it. Speed you can feel without a
  number ([doc 08](08-vehicles.md)).
- **Contextual framing** — combat tightens and lowers; exploration breathes wide;
  the switch pulls up and out ([doc 05](05-gameplay-mechanics.md)).
- **Subtle, tasteful shake & sway** (toggleable for accessibility,
  [doc 23](23-accessibility.md)) — impacts, engine rumble, footfalls.
- **Cinematic auto-angles** on near-misses and stunts (Redline leans into this,
  [doc 08](08-vehicles.md)) — the game flatters your best moments.

## Driving feel (the crown jewel)

- **Weight transfer you can read** — the nose dives, the body rolls, the rear
  steps out; the car *talks* to you ([doc 08](08-vehicles.md)).
- **The handbrake is a verb** — satisfying, controllable rotation; the soul of a
  fun getaway.
- **Surface & speed feedback** — tire chirp, gravel rattle, the hollow boom of a
  causeway expansion joint, the drag of floodwater. Audio + haptics + camera all
  agree.
- **Redline** — time dilation with chromatic smear, a deepened engine note, and a
  controller-rumble pulse; the most *juiced* moment in the game
  ([doc 03](03-characters.md)).

## Combat feel

- **Weighty weapons** — recoil, muzzle flash, shell ejection, a meaty report;
  every gun has a personality you feel ([doc 28](28-weapon-catalog.md)).
- **Hit feedback is unmissable** — impact flinches, blood/material spatter (content
  slider, [doc 09](09-weapons-combat.md)), hit-markers (optional), ragdoll +
  partial canned reactions blended.
- **Impact pauses (hitstop)** — a few frames of freeze on heavy melee and finishers
  for crunch, tuned to feel powerful without sludgy.
- **Audio leads the punch** — the *sound* sells the hit more than the visual.

## Traversal feel

- **Momentum-based parkour** — readable vault/climb/slide with weight; no floaty
  spider-climbing ([doc 05](05-gameplay-mechanics.md)).
- **Footstep & foley grounding** — surface-specific footfalls, fabric, gear rattle
  so the body feels *present* ([doc 40](40-sound-design.md)).

## Haptics (controller)

- **Granular rumble & adaptive triggers** — road texture, engine load, weapon
  resistance (trigger tension on heavy guns), the dull thud of a body-blow, the
  rising buzz of Redline.
- **Diegetic & informative** — haptics double as feedback (low health pulse, Heat
  proximity) — and are fully scalable/disable-able
  ([doc 23](23-accessibility.md)).

## "Juice" (the polish that sells everything)

The small, multiplicative feedback that makes actions feel *alive*:

- **Screen & world reactions:** dust kicks, water spray, neon bloom flares,
  paper/leaves scattering, NPCs flinching and reacting.
- **Anticipation & follow-through** in animation — nothing snaps; everything winds
  up and settles.
- **Particles, decals, and persistence** — skid marks, bullet holes, shattered
  glass that *stays* a while; the world remembers the moment
  ([doc 19](19-living-world-ai.md)).
- **Audio-visual-haptic agreement** — the golden rule: every impactful action hits
  all three channels at once.

## The feel test (review gate)

> *"Hand someone a controller with no objective, in an empty block. Do they smile
> in sixty seconds — from driving, shooting a wall, or just moving?"* If not, the
> feel work isn't done — and no level design can compensate
> ([doc 01](01-vision.md)).

## Feel design rules

- **Tune feel in a gray box** before content production scales
  ([doc 20](20-tech-and-production.md)).
- **Flatter the player's best moments** (cinematic angles, hitstop, Redline) — make
  competence *look* and *feel* cool.
- **Everything juicy is also toggleable** for accessibility and taste
  ([doc 23](23-accessibility.md)).
- **Restraint at scale** — juice every *core* verb hard; don't drown the screen in
  constant effects that fatigue.
