# The Gutterbloom Vertical Slice

## 1. Slice purpose

The Gutterbloom is a 20-to-30-minute repeatable expedition that proves the game's unusual combination of readable 3D combat, relaxed target farming, Spotlight stakes, reactive humor, companion memory, living lairs, persistent zone change, absurd loot, near-unlimited storage, and a portable upgradeable home.

It is not a tutorial prologue that gets discarded. The slice becomes the first subregion of the production Gutterbloom zone if its systems pass.

## 2. Player promise

In one expedition, the player should:

1. choose a visible reward target;
2. leave a safe social space with Picket;
3. fight three mechanically different enemy families;
4. create or decline at least two Spotlight opportunities;
5. influence the Courtesy Drain's mood;
6. receive an item worth comparing;
7. defeat or retry the Rain Treasurer without a long runback;
8. see the world change after victory;
9. feed unwanted loot to the Hearthfold with complete protections;
10. hear at least one specific callback to their own earlier play.

## 3. Route map

```text
Hearthfold Refuge
       |
Latchmarket Edge [Safe]
       |
The Dry Boot [Semi-safe]
       |
Inspection Kiosk [Picket and anchor]
       |
Floodgate Commons [Contested combat tutorial]
      / \
Spore Causeway          Tollmold Culvert
[visible, combat]       [secretive, negotiation]
      \ /
Root-Turn Junction [elite or recovery incident]
       |
The Courtesy Drain [living lair and checkpoint]
       |
Treasury Basin [Rain Treasurer boss]
       |
Lower Spillway [post-boss shortcut and changed farm route]
       |
Latchmarket return / Hearthfold anchor
```

The critical route is short and readable. The Causeway and Culvert provide equivalent reward budgets through different encounter categories. The post-boss spillway creates a five-to-eight-minute repeat route without making the first journey obsolete.

## 4. Place and conflict

Latchmarket occupies the upper roofs of a trade district swallowed by luminous drainage wetlands. The Rain Treasurer, an old Underworks office given a body and too much authority, keeps water artificially high because its instructions say reserves must never fall below emergency levels. The emergency ended centuries ago. The policy did not.

The result supports stakes and comedy:

- merchants need the lower route opened;
- Sump Knights enforce obsolete water policy;
- Tollmold colonies have built a tax ecology around the flood;
- Knuckle Newts thrive in the elevated canals;
- the Courtesy Drain believes the crisis is a backlog of maintenance tickets;
- the Herald treats a municipal disaster as a promising regional program;
- Picket knows the regulations are wrong but initially believes they must still be followed.

## 5. Local groups

### Latchmarket Cooperative

Roof merchants, haulers, gardeners, and repair crews who want predictable routes. Their slice representative is **Tamsin Vale**, a route broker who gives the first contract and clearly states its reward pool.

### Office of Water Continuity

Sump Knights and drowned clerks still executing emergency orders. They are hostile in the basin but may be appealed, redirected, or studied in later Gutterbloom content.

### Tollmold Registry

A network of sapient fungal colonies that charges tolls, accepts unusual payment, and expands wherever repeated transactions imply a road exists. It can be fought, paid, tricked, or temporarily contracted.

### The Dry Boot staff

Neutral service workers who trade rumors, food, brawl wagers, and honest practical information. They know the zone better than the official map and have no patience for the Herald's branding.

### Slice cast

- **Dava Fen:** the Dry Boot's proprietor, rumor verifier, and neutral mediator.
- **Scrip Nine:** a retired Sump Knight clerk with a nonexclusive clue to the Rain Treasurer's mandate.
- **Quoin Rusk:** the anchor specialist who helps stabilize Picket's Kiosk connection.
- **Registrar Loam:** the Tollmold delegate in one Culvert and mediation scene.
- **Due Notice:** a recurring Sump Knight state built through the promoted-enemy framework and reusable Sump Knight kit.

Skip Nall, Mara Venn, and Three-Cups exist as data-only simulation fixtures during the slice and receive full presentation during M27. `NPC_DOSSIERS.md` defines the ensemble and prevents this cast from silently becoming eight bespoke vertical-slice productions.

### Slice situations

The four implemented situation definitions are:

1. **The Invalid Rain Order:** Dava and Scrip investigate a surviving mandate fragment.
2. **Tollmold Right of Way:** Loam proposes a fungal crossing with route and ecology consequences.
3. **Anchor Under Warranty:** Quoin discovers a disputed Courtesy Drain material in the Kiosk repair.
4. **The Drink Named After You:** a promoted-enemy incident becomes rumor, recovery, and later bar comedy.

All use the lifecycle, active budgets, discovery labels, content preservation, and deterministic tests in `SITUATION_ENGINE.md`. None expires in real time.

## 6. Picket's introduction

Picket is found trapped in an Inspection Kiosk, endlessly failing the same floodgate because the form expects a supervisor who no longer exists.

The player can free Picket through any of three equivalent actions:

- break the kiosk power coupling;
- restore power and approve the abandoned work order;
- persuade a Tollmold clerk to stamp the form as a recognized wetland authority.

The choice creates the first Comedy Memory and changes Picket's introduction callback. It does not change Picket's permanent power.

Picket's slice actions are:

- **Inspection Pulse:** mark one hazard or enemy break condition;
- **Evidence Tether:** retrieve one nearby eligible item to the player;
- **Protocol slot A:** choose route scanning or combat scanning;
- **Protocol slot B:** choose material appraisal or stronger warning duration.

Picket Trust has three slice states: Provisional, Cooperative, and Personally Concerned. Trust changes dialogue and one utility cooldown, not damage output.

## 7. Encounter sequence

### E01: Floodgate Commons

Two Knuckle Newts teach group bracing and flanking. A third enters only after the player uses a power, preventing the first fight from becoming visual noise. Picket marks the braced weak point. The Herald can award an Accolade for using the floodgate to separate the pack.

### E02A: Spore Causeway

A visible route with Knuckle Newts and a Tollmold growth hazard. The player can use fire to clear growth quickly, redirect water to move it safely, or fight around it. Excessive fire changes the Courtesy Drain toward Concerned and increases Cinder material rewards.

### E02B: Tollmold Culvert

A lower route with one negotiation, hidden Cache, and smaller combat. Payment options are Marks, a low-rarity item, a service action, or refusal. Feeding the colony a bizarre item creates an appraisal callback later. Reward value matches the Causeway, but categories lean toward utility and crafting.

### E03: Root-Turn Junction

The first elite uses one mutation. If a prior ordinary enemy qualified for promotion, it replaces the elite here with a title, tiny ceremonial marker, learned mutation, callback, and improved pool.

An Embarrassment Remnant from E01 or E02 appears on a short side path. It never contains equipment and is not placed inside another forced fight.

### E04: Courtesy Drain approach

The player sees the result of current lair mood before entering. A checkpoint and Hearthfold access sit outside the first committed encounter. The target reward pool and known mood effect appear on the entry panel.

## 8. The Courtesy Drain

The lair consists of four small functional rooms and the Treasury antechamber. Room order can change at higher Memory Rank, but the slice uses one layout with mood variations.

### Room A: Intake

A service counter scans the build and generates a maintenance category. The result explains the current mood and previews one reward-category tilt.

### Room B: Pressure Test

Moving water jets, breakable valves, and Sump Knights teach positioning. The player may repair a valve, weaponize it, or ignore it.

### Room C: Lost Property

Contains previous drops, mislabeled containers, one Cache, and a Tollmold collector. Thorough looting increases Spiteful pressure but opens better container-category rewards.

### Room D: Resolution

The lair combines its selected hazard and enemy emphasis. A resolved service ticket becomes the boss checkpoint and exit shortcut.

### Slice moods

| Mood | Common cause | Encounter change | Reward tilt |
| --- | --- | --- | --- |
| Curious | varied powers, first visit, unexpected negotiation | more scan windows and mixed hazards | powers and discovery materials |
| Concerned | repeated damage, failed jumps, ignored warnings | clearer telegraphs and rescue valves, but more control pressure | recovery, Guard, and utility gear |
| Offended | broken fixtures, attacked neutral Tollmold, excessive environmental damage | armored clerks and retaliatory plumbing | weapon and Cinder gear |
| Competitive | high Spotlight, rapid break-condition use, accepted complication | additional elite and combined hazard | higher bonus rolls and Herald items |

The base reward budget is equal. Competitive has more danger and an optional bonus roll, while the ordinary pool remains fair in every mood.

### Memory Rank

- **Rank 0, Unfiled:** first visit and normal layout.
- **Rank 1, Assigned:** unlock after first clear; exposes mood and target category before entry.
- **Rank 2, Escalated:** post-slice production target; unlocks alternate Room C and a signature champion.
- **Rank 3, Policy Review:** later Gutterbloom target; allows the player to petition for one chosen mood at an earned cost.

## 9. Spotlight opportunities

Each is optional and previews risk plus bonus. None changes base drops.

1. **Unsupervised Maintenance:** activate two pressure valves simultaneously, adding a hazard and bonus Salvage roll.
2. **Public Demonstration:** accept the Herald's marked elite mutation and gain a Herald Cache chance.
3. **No Further Questions:** complete a Courtesy Drain room without using Picket's marked solution and gain an unusual-method bonus if successful.
4. **Keep the Route Open:** protect a neutral Tollmold clerk during combat for a utility reward.
5. **Fine, Do It Live:** at the boss gate, explicitly wager the most recently banked Spotlight rank reward for one extra boss-pool choice if successful.

The fifth opportunity is the only explicit bet. It is never preselected. Declining preserves every banked rank reward and never changes the boss's baseline pool.

## 10. Rain Treasurer boss

### Identity

The Rain Treasurer is a towering Sump Knight fused to gauges, lockboxes, and a waterwheel ledger. It interprets damage as an unauthorized withdrawal and the lowering flood as insolvency.

### Phase 1: Account Reconciliation

- circular melee sweeps teach dodge direction;
- two pressure jets cross the arena with long telegraphs;
- the exposed gauge is a Pierce weak point;
- blocking or redirecting a jet opens a Guard-break window;
- Picket identifies one safe valve after the player observes the attack once.

### Phase 2: Emergency Reserve

- water rises in two arena quadrants, then rotates;
- Tollmold plates can provide temporary footing, consume a dropped material, or be destroyed;
- one Sump Knight clerk enters, using the zone's familiar formation behavior;
- the boss stores elemental buildup in its tank, then vents it with a visible type.

### Phase 3: Liquidation

- the waterwheel detaches and becomes a moving hazard;
- the boss alternates low-water charge attacks and high-water projectile patterns;
- using the detached wheel against a valve creates a large break opportunity;
- no phase has a completion timer or automatic enrage based on elapsed time;
- higher World Temper may add mechanics later, not hidden stat inflation in the slice.

### Retry and victory

The checkpoint is outside the antechamber, with under 20 seconds to the arena. The introduction is skippable after first view. Defeat may create an Embarrassment Remnant in the antechamber, never inside the active boss.

First victory guarantees:

- one choice from three boss-pool equipment items;
- one Rain Treasurer's Boss Seal;
- one Hearthfold pressure-core upgrade component;
- the Rain Treasurer trophy imprint;
- one additional boss-pool choice if `Fine, Do It Live` succeeded;
- a Herald announcement and a Picket response that respect sincerity timing.

## 11. Twelve slice legendaries

The slice draws these existing catalog laws into a fixed targetable pool:

| Item | Primary source | Build purpose |
| --- | --- | --- |
| Second Opinion | boss choice and Longblade attunement | Afterline melee repetition |
| The Polite Hammer | promoted Sump Knight | counterattack Impact build |
| Exit Interview | Tollmold contract Cache | position and buff theft |
| Raincheck | Rain Treasurer repeat pool | missed-shot projectile planning |
| Nobody's Spear | Gutterbloom mastery | zone-element adaptation |
| Rain Treasurer's Coat | guaranteed first-kill candidate | stored elemental buildup trail |
| Fungal Formalwear | Tollmold and ecology rewards | summon armor and fire tradeoff |
| Quiet Hours | Courtesy Drain Concerned pool | silence and stored sonic burst |
| Weatherproof's Shell | The Dry Boot contract chain | environmental Guard conversion |
| Moldy Invitation | rare Tollmold Cache | bar and Hearthfold interaction |
| Anchor Seed | exploration ledger | temporary safe routing |
| Lucky Misprint | Courtesy Drain Spiteful or Competitive pool | inverted terrible affix rolls |

Every item lists its source after discovery. Boss Seals, Echo Shards, attunement, and Mercy Cache protection make each one eventually obtainable.

## 12. Living-state change

### Before victory

- water level: emergency high;
- lower spillway: blocked;
- Knuckle Newt pressure: high in rooftop canals;
- Sump Knight patrol: controls Root-Turn Junction;
- Pale Sumpcap resource: scarce;
- Latchmarket prosperity: strained;
- Courtesy Drain: unresolved backlog;
- Rain Treasurer: incumbent.

### First victory transition

- water level falls to managed medium;
- lower spillway opens as a fast farming route;
- Newts move toward exposed mud flats, changing one combat formation;
- surviving Sump Knights retreat to a smaller toll patrol;
- Pale Sumpcaps bloom along the exposed walls;
- The Dry Boot gains one vendor service and changed rumor set;
- the Courtesy Drain gains Memory Rank 1;
- a successor record begins but does not immediately replace the boss;
- the original Rain Treasurer becomes replayable as an Echo Hunt.

### Return visit

The player should notice the change through water height, route geometry, NPC placement, resource markers, map state, patrol composition, ambient sound, and short dialogue. The Herald is not allowed to be the only explanation.

## 13. Hearthfold return

The pressure-core component upgrades the Refuge Reclamation Core. The first upgrade unlocks:

- a protected batch-feed preview;
- room-growth conversion from Worn, Common, and duplicate Fine gear;
- permanent Archive appraisals for discovered bases;
- one cosmetic pressure gauge reflecting what the Core has consumed;
- a Picket inspection scene;
- a selected next-room preview, not a forced upgrade branch.

The first use should demonstrate that excess loot has a destination without requiring the player to feed any equipped, favorite, locked, best-copy, Exotic, Legendary, or Mythic item.

## 14. Humor beats

The slice must support at least these callback chains:

1. **Kiosk choice:** how Picket was freed returns during the boss's authorization failure.
2. **Ignored warning:** a marked hazard causes an Indignity, then Picket references it only after the danger has passed.
3. **Promoted killer:** the Herald announces the promotion at Root-Turn and The Dry Boot later names a drink after the incident.
4. **Toll payment:** the specific payment becomes a mislabeled object in Lost Property.
5. **Early salvage:** reclaiming an unread new base creates a Core/catalog comment and preserves the appraisal.
6. **Courtesy mood:** the lair's final ticket text summarizes the actual behaviors that shifted its mood.
7. **Boss retry:** repeated failure changes one Picket line and one Herald line without stacking insults every attempt.
8. **Post-victory quiet:** the first settlement response receives a sincerity hold before celebration jokes resume.

## 15. Content budget

The slice should stay intentionally small:

- one player body and one production starter outfit;
- Longblade plus three additional weapon-family test sets;
- one full Riftblade kit;
- Picket with four protocols;
- three ordinary enemy families;
- six elite mutations;
- one named promoted-enemy framework;
- one lair with four moods and four rooms;
- one three-phase boss;
- 12 curated legendaries plus ordinary generated gear;
- three Cache types;
- one safe settlement edge and one semi-safe bar;
- Dava Fen and Scrip Nine as production social NPCs, Quoin Rusk as a shared service specialist, Registrar Loam in one limited scene, and Due Notice through the promoted Sump Knight framework;
- data-only simulation fixtures for the remaining Gutterbloom cast, deferred to M27 presentation;
- two Hearthfold rooms with one Reclamation upgrade;
- four authored situations serving as the slice's four world-event definitions, plus six contracts;
- the humor content targets in `HUMOR_AND_VOICE.md`.

Anything else needs to replace a slice item, not silently join the list.

## 16. Out of scope for the slice

- additional production zones;
- real-time co-op, public ghosts, leaderboards, mail, trading, or auction house;
- cloud accounts or server persistence;
- more than one full Discipline;
- advanced god covenant trees;
- player housing visits;
- seamless open-world transitions;
- procedural terrain generation;
- full voice coverage;
- final cinematic art;
- console launch work;
- paid content or supporter packs;
- arbitrary square-kilometer targets;
- real-world daily or weekly schedules.

## 17. Slice success metrics

### Comprehension

- New players can state their current reward target, safety state, Spotlight risk, boss retry route, and Reclamation protections.
- Players distinguish Herald, Picket, and Courtesy Drain motives without speaker labels.
- Players understand that low Spotlight does not reduce baseline farming.

### Feel

- Most observed combat damage can be attributed to a readable cause.
- At least three Riftblade loadouts finish the route through different strengths.
- Route traversal does not create repeated empty stretches longer than the five-to-eight-minute loop allows.

### Humor

- Players remember at least one systemic joke or callback rather than only a static line.
- Ordinary lines do not repeat in a normal 30-minute run.
- No joke covers a boss cue or undercuts the protected post-victory beat.
- Players use Picket for both utility and character interest.

### Loot and persistence

- No reward or transaction path loses owned equipment.
- Players can identify why a legendary changes a build.
- The first Reclamation transaction is understandable without outside instructions.
- Save/load reproduces inventory, Spotlight bank, Picket Trust, lair mood, promoted enemy, boss state, Hearthfold upgrade, and Comedy Memories.

### Performance

- The standard route and stress encounter meet the measured budgets in `TECHNICAL_DESIGN.md` on named hardware.
- Failures remain recorded as failures even if the slice is otherwise functional.

## 18. First implementation order

1. M00 engine/export spike.
2. M01 repository and headless harness.
3. M02 typed events plus synthetic Herald/Picket/Spotlight test.
4. M03 character and camera test gym.
5. M04 full route graybox.
6. One Knuckle Newt encounter.
7. Riftblade Longblade kit.
8. One generated item to equip, save, reload, and reclaim.
9. Picket's Inspection Pulse and one callback.
10. Courtesy Drain Intake room with two moods.

The first exported playable build should exist by step 4. It does not wait for a finished zone.
