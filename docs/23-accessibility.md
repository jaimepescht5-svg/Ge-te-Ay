# 23 — Accessibility

> Accessibility is a **launch pillar, not a patch** ([doc 01](01-vision.md)). An
> open-world crime game asks a lot of the player — driving, shooting, sneaking,
> reading a busy world — so it must let *everyone* tune that load. The goal: the
> widest possible audience can finish the campaign their way.

## Guiding principle

**Difficulty and accessibility are different axes, and both are granular.** A
player should be able to make the game *easier to play* without making it *less
of a game*, and tune each challenge independently.

## Per-system difficulty (recap from [doc 05](05-gameplay-mechanics.md))

Not one slider — separate axes the player mixes freely:

- **Driving:** assist (auto-brake, steering/rubber-band help) → simulation.
- **Combat:** aim-assist strength, enemy lethality/health, ammo economy,
  optional auto-aim and slow-on-aim.
- **Stealth:** detection speed, alert memory, optional "forgiving" cones.
- **Economy/consequence:** how punishing money/Heat loss is.
- **Mission:** checkpoint frequency, **skip-to-action** and **skip-puzzle**
  options so no single wall blocks the story.

## Motor accessibility

- **Full remapping** of every input, on every device (controller, mouse/keyboard,
  adaptive controllers).
- **Hold/toggle for everything** (aim, sprint, crouch, cover, focus states).
- **Auto-actions:** auto-vault/traverse, auto-drive-to-waypoint, auto-park,
  vehicle "cruise to objective."
- **Reduced-input modes:** simplified control schemes; no required rapid mashing
  (mash prompts have hold/auto alternatives); no required precise timing where an
  assist can stand in.
- **Adjustable sensitivity, dead zones, and aim acceleration** per stick/axis.

## Visual accessibility

- **Scalable HUD & subtitles** (size, background, opacity, position).
- **Colorblind-safe palettes** (multiple types) with a rule that **no information
  is color-only** — Heat, factions, waypoints all use shape/icon + color.
- **High-contrast & outline modes** for enemies, interactables, and objectives.
- **Camera & motion options:** FOV control, motion-blur off, camera-shake off,
  reduce-flashing (storm lightning, neon, Redline), photosensitivity-safe mode.
- **Text-to-speech for menus**; readable typeface options.

## Hearing accessibility

- **Full subtitles & closed captions** with speaker names and **directional
  indicators** (who's talking, from where).
- **Captioned sound events:** visual cues for gunfire direction, approaching
  vehicles, alarms, and storm warnings — so audio info isn't lost.
- **Separate volume sliders** (dialogue, music, SFX, radio) and a **dialogue-boost
  / dynamic-range compression** option.
- **Visual radio:** the dial and "now playing" are readable on the phone
  ([doc 21](21-the-phone-and-meta-ui.md)).

## Cognitive & navigation accessibility

- **Clear, persistent objective text** and an on-demand "what do I do now?" recap.
- **Adjustable world-marker density** — turn the map from busy to minimal
  ([doc 21](21-the-phone-and-meta-ui.md)); icons are invitations, not chores.
- **Pathing aids:** optional guide-line/breadcrumb to the next objective; honest
  Heat/last-known-position readout so failure is legible, not mysterious
  ([doc 09](09-weapons-combat.md)).
- **No time pressure where avoidable;** where a timer is core, an assist can
  extend or remove it.
- **Pause anywhere** (including most cutscenes) with replay/skip.

## Content sensitivity

- **A content menu** with clear warnings and **skip/soften** options for specific
  content (graphic violence slider, certain themes), so players control their
  exposure ([doc 09](09-weapons-combat.md)).
- **Tone safeguard:** the game punches up, never at marginalized groups
  ([doc 01](01-vision.md)) — accessibility includes not alienating your players.

## Process commitments

- **Accessibility leads embedded** in design from prototype, not QA at the end
  ([doc 20](20-tech-and-production.md)).
- **Playtesting with disabled players** throughout, across motor, visual,
  hearing, and cognitive needs.
- **Presets** ("Relaxed," "Story-focused," "Standard," "Hardcore") that set sane
  bundles, all individually overridable.
- **Documented & discoverable** — accessibility info available *before* purchase
  and surfaced clearly in first-run setup.

## The test we hold it to

> *"Can a player with one of {limited mobility, low vision, deafness, a cognitive
> difference} finish the story and feel it was made for them?"* If any answer is
> no, the feature isn't done.
