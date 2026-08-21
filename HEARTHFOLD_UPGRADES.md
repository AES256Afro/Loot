# Hearthfold Upgrade Specification

## 1. Purpose

The Hearthfold is the player's persistent refuge, collection home, build laboratory, and long-term expression system. It follows the profile across every zone through compatible anchors. It should turn excess loot and completed adventures into visible growth without becoming a second job.

The upgrade system has four promises:

1. Progress comes from playing the game, not waiting for real-world clocks.
2. No upgrade can damage, de-level, lock, or erase another room.
3. No Legendary or Mythic item is ever a required sacrifice.
4. Every functional upgrade exposes its exact cost and result before purchase.

All values in this document are tuning hypotheses until the vertical slice produces economy data.

## 2. Hearthfold state

A profile stores one authoritative `HearthfoldState`:

```json
{
  "schema_version": 1,
  "core_rank": "kindled",
  "reclamation_units": 186,
  "rooms": {
    "refuge": { "tier": 2, "nodes": ["quiet_corner", "recovery_cabinet"] },
    "forge": { "tier": 1, "nodes": ["known_quantity"] }
  },
  "unlocked_anchors": ["anchor.gutterbloom.latchmarket"],
  "active_attunement": null,
  "residents": ["companion.picket"],
  "visitors": [],
  "cosmetics": [],
  "reclamation_history_hash": "...",
  "transaction_sequence": 42
}
```

Room definitions are content data. Purchased state, decorations, visitors, and transaction history are save data. Moving a chair cannot change combat statistics, random seeds, or the room's tier.

## 3. Reclamation economy

### 3.1 Reclamation Units

The Reclamation Core converts player-selected equipment into **Reclamation Units**, abbreviated RU. RU purchases Hearthfold structure. Salvage and Essences remain crafting resources, so reclaiming an item is a deliberate choice between home growth and equipment work.

Preliminary base values:

| Rarity | Base RU | Design role |
| --- | ---: | --- |
| Worn | 1 | Bulk cleanup and early visible progress |
| Common | 3 | Reliable low-stakes contribution |
| Fine | 10 | Useful contribution without feeling precious |
| Rare | 30 | Meaningful accelerator |
| Exotic | 100 | Optional major contribution |
| Legendary | 300 | Optional only, never assumed by a cost curve |
| Mythic | 1,000 | Optional only, always individually confirmed |

Quality, item level, and affix count may adjust RU by a small visible multiplier. A build-defining law does not secretly increase the value in order to tempt accidental destruction.

All normal room tiers must be achievable with Worn through Rare items plus zone components. Exotic, Legendary, and Mythic contributions accelerate progress or support collectors who explicitly choose to reclaim duplicates. They are never progression keys.

### 3.2 Core growth ranks

| Rank | Cumulative RU hypothesis | Additional requirement | Unlock |
| --- | ---: | --- | --- |
| Seed | 0 | Start profile | Refuge shell, storage manifest, manual save |
| Kindled | 100 | First anchor stabilized | Reclamation, Forge shell, cosmetics |
| Rooted | 400 | Two zone components | Archive and Training Hall shells |
| Household | 1,200 | One settlement project | Conservatory and Guest Wing shells |
| Resonant | 3,500 | Three stabilized zone anchors | War Room shell and room synergies |
| Worldheld | 10,000 | Eight zone signatures | Threshold Engine and final layouts |

These are progression thresholds, not real-world timers. A player may contribute as much or as little as desired in one session. There is no daily feed cap, login streak, rested multiplier, or lost efficiency for taking a break.

### 3.3 Transaction flow

Reclamation is an explicit six-step transaction:

1. The player selects individual items or a reviewed filter result.
2. The Core removes protected items and explains each removal from the selection.
3. Unread base-item appraisals are shown before the first copy can be reclaimed.
4. The preview lists every item, RU, crafting opportunity forgone, collection effect, and reconstruction status.
5. The player holds to confirm. Legendary and Mythic items require a separate per-item confirmation and cannot enter batch confirmation.
6. The game writes a transaction journal, applies the item removals and rewards atomically, validates the result, and saves.

If saving fails, the entire transaction rolls back. There is no state in which the item is gone but the currency is missing.

### 3.4 Protection rules

The Core rejects the following by default:

- favorites and locked items;
- equipped items and every saved loadout member;
- the best owned roll of a base or curated unique;
- the only owned copy of a discovered curated unique;
- quest objects, covenant objects, and active crafting ingredients;
- overflow items that have not been appraised;
- items received during the current unreviewed Cache opening;
- anything marked `never_reclaim` by content validation.

The player may change some collection protections in settings, but cannot bypass equipped, active-loadout, quest, or transactional safety. Curated uniques remain reconstructable at a published baseline after discovery.

## 4. Upgrade grammar

Each room has five tiers:

- **Tier 0, Shell:** the space exists but provides only navigation and decoration.
- **Tier 1, Useful:** one complete core function.
- **Tier 2, Specialized:** choose two nodes from a horizontal set.
- **Tier 3, Connected:** unlocks cross-room synergies and visitor interactions.
- **Tier 4, Signature:** a room-defining feature, visual transformation, and collection goal.

Tier purchases unlock capacity and new verbs. They should not simply add global damage, health, armor, or loot rarity. Build power comes from gear, Disciplines, powers, and covenants. Hearthfold power comes from information, preparation, experimentation, targeting, convenience, and world connection.

Node swaps are free inside the Hearthfold after a brief non-timed transition. Cosmetics never occupy functional node slots.

## 5. Room trees

### 5.1 Refuge

**Thesis:** recovery, profile safety, and a place that visibly remembers the journey.

| Tier | Capability |
| --- | --- |
| 1 | Healing, loadout wardrobe, named manual saves, basic Archive access |
| 2 | Recovery Cabinet, Quiet Corner, Trophy Wall, or Visitor Seat nodes |
| 3 | Saved preparation presets and protected sincere companion scenes |
| 4 | **The Long Table**, a configurable gathering that previews zone and relationship consequences |

The Recovery Cabinet replenishes ordinary expedition consumables to a known baseline when returning from a completed activity. It does not produce items while the player is away or create a login obligation.

### 5.2 Forge

**Thesis:** transparent item improvement and build experimentation.

| Tier | Capability |
| --- | --- |
| 1 | Salvage, quality improvement, and recipe work |
| 2 | Affix tuning, socket work, Appearance Bench, or Material Study nodes |
| 3 | Named-synergy preview and deterministic before-and-after simulation |
| 4 | **Law Crucible**, which modifies one allowed support property without replacing a curated item's identity |

Every Forge operation previews cost, outcome range, affected protections, and whether it changes the item's validation seed. There is no durability or repair function.

### 5.3 Archive

**Thesis:** make an enormous collection searchable, intelligible, and useful.

| Tier | Capability |
| --- | --- |
| 1 | Advanced filters, saved searches, best-copy groups, collection codex |
| 2 | Family attunement, appraisal library, Origin Desk, or duplicate analysis nodes |
| 3 | Curated unique reconstruction and source-ledger route planning |
| 4 | **Impossible Index**, a cross-zone search for discovered laws, interactions, sources, and missing collection links |

Archive attunement influences an explicitly labeled target-farm bonus. It does not reduce unrelated drops or consume Spotlight.

### 5.4 Training Hall

**Thesis:** remove the cost and uncertainty from learning a build.

| Tier | Capability |
| --- | --- |
| 1 | Practice targets, combat trace, power respec, damage summaries |
| 2 | Hazard room, enemy behavior projection, build comparison, or input drills |
| 3 | Saved encounter simulations using previously discovered enemies |
| 4 | **Contradiction Arena**, where players test deliberately strange law combinations under deterministic conditions |

Training simulations grant no exclusive items and never require consumables. Optional challenge rewards are cosmetic, informational, or alternate-source currencies.

### 5.5 Conservatory

**Thesis:** preserve and study zone ecology without turning the game into a calendar.

| Tier | Capability |
| --- | --- |
| 1 | Cultivate discovered plants and display harmless creatures |
| 2 | Material plot, habitat study, mutation lens, or recipe-grafting nodes |
| 3 | Predict ecology reactions and prepare reversible field interventions |
| 4 | **Borrowed Biome**, a miniature stateful habitat that unlocks research contracts and cosmetic variants |

Cultivation advances through completed expeditions, rest actions, and bounded simulation ticks. Nothing withers during offline time. There are no crops that demand a real-world return window.

### 5.6 Guest Wing

**Thesis:** make relationships physically present and mechanically legible.

| Tier | Capability |
| --- | --- |
| 1 | One resident room and one visitor seat |
| 2 | Specialist workshop, faction parlor, divine alcove, or companion nook nodes |
| 3 | Two-party meetings and mediated conflict scenes |
| 4 | **Open Invitation**, which allows a rotating cross-zone gathering with previewed opportunities |

Residents and visitors add services, conversations, investigations, or contracts. Removing a guest does not erase their relationship progress.

### 5.7 War Room

**Thesis:** understand and influence living zones without converting play into administration.

| Tier | Capability |
| --- | --- |
| 1 | Zone state summaries, contracts, threat forecasts, active successor list |
| 2 | Patrol map, ecology forecast, opportunity board, or Temper planner nodes |
| 3 | Cross-zone consequence previews and saved expedition plans |
| 4 | **Table of Possible Disasters**, which compares several interventions and their likely state changes |

Forecasts use information the profile has earned. They expose uncertainty rather than pretending the simulation is perfectly predictable.

### 5.8 Threshold Engine

**Thesis:** late-game routing, optional challenge access, and refuge expression.

| Tier | Capability |
| --- | --- |
| 1 | Expanded anchor routing and return-point choice |
| 2 | Pocket route, Echo Hunt, visual shell, or visitor routing nodes |
| 3 | Seeded challenge configuration with isolated rule modifiers |
| 4 | **World Door**, a customizable hub for mastered routes and future zones |

The Threshold Engine never locks ordinary travel behind Spotlight, ratings, or real-world cooldowns. Challenge modifiers are opt-in, reversible, and cannot damage the normal save.

## 6. Cross-room synergies

Synergies reward an interconnected home without creating one mandatory build order.

| Rooms | Synergy | Result |
| --- | --- | --- |
| Forge + Archive | Known Quantity | Preview source history and upgrade potential on item comparison |
| Archive + War Room | Hunter's Margin | Pin a discovered source and produce a route checklist |
| Training Hall + Forge | After-Action Workbench | Replay a combat trace against a proposed item change |
| Conservatory + Guest Wing | Visiting Habitat | Ecology specialists and unusual residents unlock research scenes |
| Refuge + Guest Wing | Someone Saved You a Seat | Protected relationship scenes and group debriefs |
| War Room + Threshold Engine | Better Door Policy | Save cross-zone expedition routes and preferred return anchors |
| Conservatory + Forge | Responsible Improvisation | Discover recipes from ecology tags without consuming display specimens |
| All rooms at Tier 3 | A House With Opinions | Hearthfold ambient reactions and a profile-wide visual transformation |

No synergy adds an invisible global multiplier. Each changes a visible interface, preparation option, source of information, or authored interaction.

## 7. Personality and humor

The Hearthfold develops a quiet nonverbal personality through lighting choices, furniture alignment, doors that anticipate favorite routes, the Reclamation Core's judgmental sorting noises, and rooms reacting to trophies. It does not become another nonstop narrator.

Rules:

- ambient jokes obey the same silence budget as other commentary;
- sentimental scenes receive sincerity holds;
- Reclamation jokes never obscure cost or confirmation;
- the home may disapprove theatrically but never alter a transaction in secret;
- Picket may inspect upgrades, but cannot spend RU or rearrange protected items.

## 8. Optional defense simulations

Home-defense scenarios are Training Hall or Threshold Engine simulations. The player opts in from a preview showing rules and rewards. Failure restores the pre-simulation state. Rooms, stored items, residents, cosmetics, and anchors cannot be damaged or de-leveled.

These scenarios may temporarily disable selected room services inside the simulation only. Rewards focus on cosmetics, building variants, practice data, and alternate acquisition routes. No unique build item requires victory.

## 9. Vertical slice scope

The Gutterbloom slice builds only what can be proven well:

- Seed to Kindled Core progression;
- Refuge Tier 1 and one Tier 2 node;
- Forge Tier 1;
- Reclamation transaction, protections, rollback, and first-appraisal pause;
- one visible cosmetic change after the permanent upgrade;
- Picket's introduction, inspection, and one Hearthfold callback;
- one anchor outside Latchmarket and return to the same exit point.

The slice does not build cultivation, passive generation, War Room simulation, divine guests, or the Threshold Engine.

## 10. Validation and acceptance tests

Automated tests must prove:

- any normal room tier is reachable without reclaiming Exotic, Legendary, or Mythic items;
- protected items cannot enter a transaction through manual selection, filters, controller shortcuts, overflow, or migration;
- a failed write leaves both items and RU unchanged;
- replaying a committed transaction cannot duplicate RU;
- changing decorations cannot affect combat or loot seeds;
- offline time cannot remove progress, residents, plants, opportunities, or efficiency;
- node respecs cannot strand saved items or invalidate a loadout;
- reconstruction always returns the published baseline unique;
- room definitions with circular prerequisites fail content validation;
- all costs fit within bounded integer storage and serialize exactly.

Playtest acceptance:

- a new player understands why the Hearthfold follows them;
- reclaiming common loot feels useful but never compulsory after every expedition;
- the first permanent upgrade is visible and meaningful;
- collectors trust the protection preview;
- returning home feels restorative, not like opening an administration screen;
- no tester believes that waiting until tomorrow improves progression.

## 11. Deferred decisions

The following wait for economy simulations and playtests:

- exact RU multipliers and tier costs;
- maximum resident and visitor counts;
- whether room layouts use fixed sockets or a light free-placement system;
- how much deterministic cultivation output is useful without becoming passive-income pressure;
- whether more than one Archive attunement is healthy at endgame;
- whether shared Hearthfold visits belong in a future co-op scope.
