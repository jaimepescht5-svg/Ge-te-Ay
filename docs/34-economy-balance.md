# 34 — Economy Balance (Worked Numbers)

> Concrete tuning targets for the economy ([doc 10](10-economy-progression.md)).
> **All numbers are illustrative first-pass values** for balancing intent, not
> final — they exist to prove the curves are coherent and the anti-grind promise
> is real. Currency unit: **$ (in-game dollars).**

## The core curve (intent)

The campaign's **heist payouts fund the next chapter** so the player *never has to
grind* ([doc 10](10-economy-progression.md)). Side income makes you rich faster
and buys toys, but is never a gate on the story.

| Phase | Player net worth target (clean) | Drives |
|---|---|---|
| Prologue end | ~$5k (the split of the bag) | Survival |
| Act I mid | ~$40k | First front (car wash), basic gear |
| Act I end | ~$120k | First real heist payout |
| Act II mid | ~$500k | Businesses online, mid heists |
| Act II end | ~$1.5M | The Drawbridge Job |
| Act III | ~$3–5M+ | Storm scores; finale stakes |

## Heist payouts (gross, before cut & laundering)

Tuned so **Quiet > Loud > Clever-base**, but Clever can spike with the right
setup, and greed (optional objectives) adds risk-weighted upside.

| Heist | Quiet | Loud | Clever | Optional bonus |
|---|---|---|---|---|
| H2 Wash Day | $90k | $60k | $75k | +$20k (safe in office) |
| H3 Open Water | $140k | $100k | $130k | +$30k (second buoy) |
| H4 Repossession | $200k | $150k | $180k | +Theo intel (story) |
| H5 Gospel Cut | $160k | $120k | $200k | +church ledger (story lever) |
| H6 Highline | $400k | $250k* | $360k | +$80k (second vault) |
| H7 Drawbridge | $700k | $550k | $650k | betrayal (story) |
| H8 Eye of Storm | $900k | $700k | $1.1M | +reserve vault |
| H9 Ark Gala | $1.5M+ | $1.2M+ | $1.8M+ | branches → endings |

\* Loud at H6 (the Heights) is **deliberately punished** — high security, fast
police — so the number alone undersells the real cost (Heat, repairs, crew
losses). The economy *teaches* approach choice.

## The "cost of doing business" (why gross ≠ take)

Every job's **net** depends on the plan — the Board is a budget
([doc 17](17-heist-catalog.md)):

```
NET TAKE  =  GROSS
           − crew cut (hired specialists: 10–25% each, scaling with skill)
           − intel/blueprint source cut (5–15% if bought, not scouted)
           − equipment & prep costs (gear, vehicles, disguises)
           − Heat fallout (repairs, ditched vehicles, bribes, lost time)
           − laundering spread (see below)
```

**Design intent:** cheaper crew & bought intel raise the *gross-to-net* loss via
risk (panic, failure, extra Heat). Scouting yourself (Theo) and a skilled crew
cost more up front but keep more of the gross. **There is no free money — only
tradeoffs.**

## Laundering economics

Dirty cash must be cleaned to be safe/investable ([doc 10](10-economy-progression.md)):

| Front | Launder cap / day | Spread (fee) | Audit risk if over-pushed |
|---|---|---|---|
| 24-Hour Wash | $15k | 8% | Low |
| Supper club | $25k | 10% | Med |
| Casino front | $50k | 12% | High |
| Chop shop | $20k | 6% | Med |

- **Spread** is the laundering "tax" (the cost of clean money).
- **Over-laundering** past the daily cap spikes **audit risk** → a Heat/mission
  event. Greedy speed vs. patient safety — a real choice.
- **Owning more/upgraded fronts** raises total daily capacity → big scores need
  laundering *infrastructure*, a reason to build the empire
  ([doc 10](10-economy-progression.md)).

## Spending sinks (illustrative prices)

| Category | Range | Notes |
|---|---|---|
| Compact / sedan | $8k–$30k | Cheap, disposable getaway cars |
| Muscle / sport | $60k–$150k | The fun tier |
| Supercar / hyper | $400k–$2M | Status & end-game |
| Boats | $20k–$300k | The water fleet ([doc 27](27-vehicle-catalog.md)) |
| Aircraft | $500k–$3M | Late-game freedom |
| Weapons/gear | $500–$25k | + attachments ([doc 28](28-weapon-catalog.md)) |
| Business fronts | $150k–$2M | Income + laundering capacity |
| Safehouses/property | $80k–$1M | Fast travel, storage, Heat cooldown |
| Vehicle mods | $1k–$60k | Visual + performance ([doc 08](08-vehicles.md)) |
| Wardrobe | $50–$5k | Cosmetic sink ([doc 29](29-wardrobe-and-customization.md)) |
| Bribes/favors | $5k–$100k | Cut Heat, buy intel, grease deals |

## Passive income (the empire layer)

| Asset | Net income / in-game day | Risk |
|---|---|---|
| Car wash | $2k | Audit, raid |
| Supper club | $4k | Faction shakedown |
| Casino | $10k | High Heat target |
| Smuggling route | $6k (variable) | Interdiction missions |
| Vending/parking fronts | $500 each | Negligible |

Income **requires active defense** — rivals and cops attack businesses
([doc 10](10-economy-progression.md), [doc 19](19-living-world-ai.md)) — so it's
never fully passive.

## Anti-grind & fairness guarantees (now numeric)

- **Main-path sufficiency:** completing story heists at *base* (no optional
  objectives, average approach) keeps net worth **≥ each phase target** above —
  you can finish the game without a single hustle.
- **Failure ceiling:** a botched heist costs **only prep + Heat fallout** (capped
  at ~the job's prep budget), **never** banked clean money or owned assets.
- **Catch-up:** if a player drops below the phase floor, fences pay a small premium
  and easy hustles surface — a gentle hand up, not a handout
  ([doc 10](10-economy-progression.md)).
- **Hoarder tax:** carrying huge **dirty** cash raises suspicion/Heat — incentivizing
  spending and laundering over hoarding, keeping the economy in motion.
- **No purchasable advantage** in single-player at all; online cosmetics-only
  ([doc 11](11-online-multiplayer.md)).

## Balancing process

- **Spreadsheet model first** (these curves), then **playtest-tune** against the
  target metrics in [doc 01](01-vision.md) ("Did you feel forced to spend money to
  keep up?" <5% yes).
- **Re-tune per difficulty axis** ([doc 23](23-accessibility.md)) — the *economy*
  axis adjusts payouts/penalties without touching combat or driving.
