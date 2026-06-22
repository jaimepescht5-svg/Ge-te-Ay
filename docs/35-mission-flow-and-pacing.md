# 35 — Mission Flow & Pacing

> The campaign's **structural map**: how the ~30–40 hours are sequenced, how
> individual missions are built, and how we control rhythm so the game never
> sags. Ties the story ([doc 04](04-story.md)) to the heists
> ([doc 17](17-heist-catalog.md)) and side content
> ([doc 18](18-side-stories.md)).

## The macro flow (campaign spine)

```
PROLOGUE ──► ACT I ──────► ACT II ───────────► ACT III ──► ENDINGS
"Sure Thing" "Small Fish"  "Crossfire"          "Landfall"   3 forks
   H1          H2,H3        H4,H5,H6,(H7)         H8 ► H9     + codas
   │           + first      + double-game,        + storm     Clean/
 teach 3       allies,      personal arcs deepen, set-pieces  Scorched/
 leads +       base, fence  midpoint betrayal     thin law    High Ground
 the switch                 (H7)                   open world
```

- **Tutorialization is front-loaded** (prologue) then **never repeated** — later
  missions assume mastery and remix.
- **Gates are soft:** Act progression unlocks via story beats, but the **open world
  and side content stay available**, so players set their own pace between beats.
- **The storm is the act clock:** Storm Watch radio ([doc 13](13-radio-music.md))
  escalates through Act II into III, so the player *feels* the deadline coming.

## Mission rhythm (the pacing rule)

We deliberately alternate **register** so no two consecutive missions feel the
same — the anti-"checklist museum" guard ([doc 01](01-vision.md)):

| Register | Examples | Role |
|---|---|---|
| **High-octane** | chases, shootouts, the Drawbridge set-piece | Adrenaline peaks |
| **Tense-quiet** | infiltrations, Highline, recon | Skill & breath-holding |
| **Character/heart** | garage beats, Ada/Tomás scenes, downtime vignettes | Emotional grounding |
| **Comedy** | the Gospel Cut, Frankie cons, Strangers | Tonal relief |
| **Sandbox-breather** | free hustles, races, exploration | Player-led decompression |

**Rule:** never stack two of the same register back-to-back in the main spine;
follow a peak with a breath ([doc 04](04-story.md)).

## Mission structure template (the anatomy)

Most story missions follow a flexible 5-beat shape — designed so the *middle*
breathes and the *end* spikes:

1. **Hook** (contact/cutscene/phone) — *why* and *who* ([doc 21](21-the-phone-and-meta-ui.md)).
2. **Travel** — to the site; emergent incident space; banter
   ([doc 19](19-living-world-ai.md)).
3. **Approach** — the quiet build / recon / setup (the part that rewards thought).
4. **Spike** — the thing goes loud, fast, or sideways (the set-piece / the choice).
5. **Resolve & ripple** — escape, payoff, and the **world-state change**
   (rep, Heat, news, relationships) ([doc 09](09-weapons-combat.md),
   [doc 03a](03a-cast-relationships.md)).

Heists expand beat 3–4 into the full four-phase system
([doc 07](07-missions.md)).

## Branching & player agency in flow

- **Approach branches** (Quiet/Loud/Clever) fork the *middle* of heist missions but
  reconverge at the escape — replayable without combinatorial explosion
  ([doc 17](17-heist-catalog.md)).
- **Choice branches** (who you spare, which faction you favor, who you keep loyal)
  set **flags** that surface later in dialogue, available jobs, faction rep, and
  the **ending fork** ([doc 04](04-story.md)) — wide consequences, authored
  convergence.
- **Order freedom:** within an Act, several jobs and most side arcs are
  player-ordered; only **act-transition beats** are fixed.

## Pacing the open world between beats

- **The director seeds incidents** scaled to keep wandering interesting without
  overwhelming ([doc 19](19-living-world-ai.md)).
- **Contacts call with opportunities** ([doc 21](21-the-phone-and-meta-ui.md)) so
  there's always a thread to pull — but **never nagging** (mutable, throttled).
- **Heat & tide create natural rhythm:** a hot district pushes the player
  elsewhere; the tide reschedules water routes — the world paces itself.

## Difficulty pacing

- **Skill assumption rises** with the acts (enemies, security, complexity), but
  the **per-system difficulty sliders** ([doc 23](23-accessibility.md)) let any
  player flatten that curve.
- **No difficulty spikes without telegraph** — the game warns (via intel/recon)
  before it asks for more, so failure is fair ([doc 01](01-vision.md)).

## The "session shape" target

A typical **2-hour session** should contain at least: one story/heist beat, one
register-contrast (a laugh *or* a heart moment), one piece of player-led sandbox,
and **one retellable emergent moment** ([doc 01](01-vision.md)). If playtests
don't produce that shape, pacing isn't done.

## Anti-sag safeguards (the review gates)

- [ ] No two same-register missions back-to-back in the spine.
- [ ] Every Act has ≥1 marquee set-piece **and** ≥1 quiet/heart beat.
- [ ] The storm clock is *felt* escalating from Act II onward.
- [ ] A player can always name "the next thing I want to do" without the map
      feeling like a chore list ([doc 21](21-the-phone-and-meta-ui.md)).
- [ ] The midpoint betrayal ([doc 04](04-story.md)) lands with setup, not from
      nowhere.
