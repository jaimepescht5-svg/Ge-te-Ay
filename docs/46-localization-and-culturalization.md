# 46 — Localization & Culturalization

> A game this verbal (reactive dialogue, radio, satire, slang) and this rooted in a
> **multilingual melting-pot city** ([doc 02](02-setting-world.md)) lives or dies
> on localization. This doc specs how we ship Port Soleil's voice in many
> languages **without flattening it** — and how we get the in-fiction culture
> right.

## Two different jobs

- **Localization** = translating and adapting the game for other languages/regions.
- **Culturalization** = getting the *source* world's depicted cultures right and
  respectful in the first place (the melting pot is the *setting*, not a costume).

Both are **planned from pre-production**, not bolted on
([doc 20](20-tech-and-production.md)).

## Culturalization (getting the source world right)

Port Soleil's identity is its melting pot — warm-climate, port-culture, Latin and
Caribbean and immigrant communities woven together ([doc 02](02-setting-world.md)).
To honor that, not caricature it ([doc 01](01-vision.md)):

- **Authentic voices in the room** — writers, consultants, and cast from the
  cultures depicted; multilingual writers for the code-switching dialogue
  ([doc 03a](03a-cast-relationships.md)).
- **Code-switching is canon** — Spanish/Creole/English mixing in the Cut and the
  Glades is *natural*, written by people who live it, with subtitles that respect
  it (translate meaning, keep flavor) ([doc 25](25-glossary-slang.md)).
- **Specificity over shorthand** — characters are individuals with detailed lives,
  never a demographic stand-in ([doc 36](36-character-bios.md)).
- **Satire punches up** — at institutions and power, never at the communities that
  make the city what it is ([doc 44](44-themes-and-meaning.md)).
- **Sensitivity review** of depictions, slang, religion (the Gospel of Gain
  satirizes *grift*, not faith), and imagery ([doc 14](14-brand-bible.md)).

## Localization scope

- **Full localization** (text + voice) for major markets; **text localization** for
  a wider set — scoped realistically by the production plan
  ([doc 20](20-tech-and-production.md)).
- **Everything localizable:** UI, subtitles, the phone & apps
  ([doc 21](21-the-phone-and-meta-ui.md)), mission text, the *reactive* radio/news
  ([doc 37](37-radio-programming.md)), billboards and in-world brand text
  ([doc 14](14-brand-bible.md)), and the satire.

## The hard parts (and how we handle them)

### Translating satire & comedy
Jokes rarely survive literal translation. We use **transcreation** — local writers
re-author the *intent* of a gag, ad read, or DJ bit so it lands in-language, not a
dead literal version ([doc 37](37-radio-programming.md)).

### Translating invented slang
The Port Soleil lexicon ([doc 25](25-glossary-slang.md)) — *a wheel, dry money,
spring rain, that's Soleil* — gets **per-language equivalents** that keep the
double meanings (especially the flood/money puns) where possible, with a glossary
shared across all localization teams for consistency.

### The multilingual source
Spanish/Creole already in the *English* build needs careful handling in *other*
locales (e.g., the Spanish localization must keep the code-switch *feeling* without
making it invisible) — a known hard problem, briefed to each team.

### Reactive/templated text
News bulletins and barks assembled from fragments ([doc 19](19-living-world-ai.md))
must be **grammatically robust per language** (gender, plurals, word order) — built
with a localization-aware string system from day one, not concatenated English.

## Technical localization requirements

- **No hardcoded strings; full string externalization** and a localization-aware
  templating system (handles plurals, gender, ordering).
- **UI that reflows** for text expansion (German/Russian run long) and supports
  non-Latin scripts and RTL where in scope ([doc 21](21-the-phone-and-meta-ui.md)).
- **Subtitle system** with size/background/speaker/direction options — overlaps
  with accessibility ([doc 23](23-accessibility.md)).
- **Voice pipeline** sized for many languages × a *lot* of reactive lines — a real
  production cost, planned early.

## Regional & ratings considerations

- **Ratings vary by region** — plan the content-sensitivity tooling
  ([doc 23](23-accessibility.md)) to also serve regional compliance (toggle/soften
  specific content) without gutting the game.
- **Cultural review per market** for imagery, gestures, and themes that read
  differently abroad — adjust respectfully, document decisions.

## Process & rules

- **Loc & culturalization embedded from pre-pro** — not a final-quarter scramble
  ([doc 20](20-tech-and-production.md)).
- **Shared glossary & style guide** (terms, slang, brand names, tone) across all
  language teams for consistency ([doc 25](25-glossary-slang.md)).
- **Transcreate, don't transliterate** comedy and slang.
- **Honor the source culture first** — if the English build caricatures, no
  translation fixes it; get it right at the root ([doc 01](01-vision.md)).
