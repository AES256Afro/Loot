# Living Zone Design Template

## 1. Purpose

This template turns a zone idea into a dense, replayable area with ecology, settlements, lairs, bosses, humor, targetable rewards, and visible change. It prevents scope from being measured only in square kilometers or enemy count.

A good zone has a clear identity, three to six memorable subregions, several useful routes, at least one safe or semi-safe social space, a local ecological problem, multiple valid interventions, and reasons to return after its headline boss is gone.

The template is a production contract. A zone does not enter full art production until its route graybox, state budget, source tables, and unique gameplay thesis pass review.

## 2. Zone summary card

Complete this one-page card first:

- **Zone ID and working title:** stable namespace plus original player-facing name.
- **One-sentence fantasy:** what the player should tell a friend happened here.
- **Primary gameplay verb:** the recurring action this zone makes interesting.
- **Secondary verbs:** two supporting actions or decisions.
- **Visual thesis:** shapes, scale, materials, color ranges, and silhouette rules.
- **Audio thesis:** ambience, music materials, quiet spaces, and danger signals.
- **Ecology pressure:** what is changing and who benefits.
- **Civic pressure:** what the settlement or local allies need.
- **Power pressure:** faction, demigod, god, or living-lair agendas.
- **Reward identity:** item families, materials, laws, powers, cosmetics, and crafting roles.
- **Comedy triangle:** which three voices disagree about the zone and why.
- **Return promise:** what changes or becomes targetable after the first major resolution.

If the one-sentence fantasy, primary verb, and return promise could describe another zone unchanged, the pitch needs another pass.

## 3. Player experience goals

Define three to five observable goals. Examples:

- players learn to read moving water as both route and combat tool;
- a settlement feels useful before its problem is solved and changed afterward;
- two ecology interventions produce different encounters with equivalent reward budgets;
- a route discovered early becomes a meaningful shortcut after the boss;
- the zone's main joke remains funny because it changes context rather than repeating a line.

Also define what the zone deliberately does not test. A stealth-focused subregion does not silently turn the entire zone into mandatory stealth. A traversal zone still needs accessible alternate routes.

## 4. Spatial structure

### 4.1 Macro layout

Specify:

- three to six subregions;
- one arrival route and one early orientation landmark;
- one protected civic core or clearly communicated absence of one;
- zero to three semi-safe social spaces such as bars, camps, ferries, or markets;
- two or more traversal loops;
- two permanent shortcuts;
- one optional secret route with a nonexclusive reward;
- one major living lair;
- one headline boss arena or equivalent resolution site;
- compatible Hearthfold anchors and their unlock rules;
- streaming cell boundaries and sightline budgets.

No zone has a minimum land area. Travel time, decision density, route meaning, and reuse after state changes are the measures that matter.

### 4.2 Route matrix

For every major destination, author at least two reasonable approaches when the fiction allows it.

| Route | Unlock | Pressure | Main verb | Reward identity | State sensitivity | Accessible alternative |
| --- | --- | --- | --- | --- | --- | --- |
| Example A | Visible from arrival | Patrols | Direct combat | Source family A | Closes or changes after event | Longer low-hazard path |
| Example B | Ecology interaction | Hazard | Traversal | Material family B | Opens after intervention | Tool-assisted bypass |

Routes should differ in play, information, or reward source, not only length. Fast travel and Hearthfold routing remain valid after discovery. The zone never punishes their use with worse loot or relationship loss.

## 5. Subregion sheet

Complete one sheet for each subregion.

### Identity

- one-line player fantasy;
- landmark and navigation silhouette;
- palette and lighting variation within the zone thesis;
- distinct ambient sound and combat warning;
- dominant material and traversal surface;
- local humor target that does not rely on one repeated line.

### Ecology

- producer, scavenger, predator, modifier, and apex roles where relevant;
- resource that moves through the local loop;
- pressure that changes populations or routes;
- one player intervention and one autonomous transition;
- what happens if the player ignores it;
- what remains available in every valid state.

Ecology simulation can be abstract. Only state that affects routes, encounters, rewards, visuals, sound, factions, or authored scenes needs runtime representation.

### Encounters

- ordinary enemy families and encounter roles;
- one combination unique to this subregion;
- one elite mutation interaction;
- one neutral, allied, or negotiable actor where appropriate;
- one encounter that demonstrates the primary zone verb;
- retreat and re-entry behavior;
- spawn and population caps.

### Hazards

For each hazard define telegraph, safe read distance, affected actors, mitigation, accessible alternative, state dependencies, and interaction with powers. Instant-kill hazards are not a default design tool. Failure should create recovery play unless a clearly isolated challenge advertises different rules.

### Discoveries

- one route discovery;
- one ecology or faction fact;
- one item source clue;
- one Comedy Memory candidate;
- zero to two secret spaces;
- one post-state-change difference.

### Spotlight opportunities

List authored combinations that may earn positive Spotlight. Each must be optional and reproducible without requiring a specific accessibility setting, speed threshold, damage taken, death, or rare item.

Ordinary traversal, farming, retreat, and repeated target kills remain reward-complete at zero Spotlight.

## 6. Ecology and living-state model

### 6.1 State dimensions

Use three to seven compact dimensions. Typical dimensions include:

- resource abundance;
- predator pressure;
- hazard intensity;
- settlement prosperity;
- faction control;
- patrol pressure;
- route stability;
- lair mood;
- boss or demigod succession;
- divine attention.

Each dimension should use a small enum or bounded numeric range with named bands. Do not simulate continuous detail that produces no player-facing outcome.

### 6.2 Transition table

| Trigger | Preconditions | State changes | Immediate feedback | Delayed result | Preserved content | New opportunity |
| --- | --- | --- | --- | --- | --- | --- |
| Player intervention | Known state | Bounded deltas | Visual, audio, UI | Spawn and route update | Alternate source path | Follow-up contract |
| Autonomous tick | Activity completed | Bounded deltas | Ledger notice | Ecology shift | Core story route | Discovery or event |
| Boss resolution | Boss active | Succession proposal | Settlement and Herald response | New ecology regime | Boss Echo Hunt | Successor chain |

Transitions happen through completed play, travel, explicit rest, and authored cross-zone events. Closing the game freezes authoritative world and social state. Return processing may rebuild indexes and summarize the saved state, but cannot advance populations, erase quests, degrade a settlement, or reduce rewards.

### 6.3 Content preservation

Every major state transition records:

- which sources remain in the world;
- which sources move to Echo Hunts, contracts, successor encounters, or Archive reconstruction;
- which routes change but retain accessible alternatives;
- which dialogue and visual layers update;
- how the player can discover the new state;
- whether an earlier state can be revisited through a simulation or pocket route.

Living does not mean disposable. The player should create history without deleting paid-for content or locking a needed build item forever.

## 7. Settlements and safety

### 7.1 Safety spectrum

Mark every social location as:

- **Sanctuary:** no combat or theft; full menus and safe saving.
- **Civic safe:** protected during ordinary state, with previewed story exceptions that never destroy storage.
- **Semi-safe:** social rules suppress ordinary combat, but authored incidents may occur with clear exits and protected services.
- **Field camp:** rest and limited services, vulnerable only while the player accepts a local event.
- **Wild:** ordinary zone rules.

Bars should feel semi-safe because people, factions, and the building have rules, not because the UI lies about danger. Service access, exits, and save behavior remain clear during any incident.

### 7.2 Settlement state

Define:

- services available on arrival;
- two to four local groups and their compatible conflicts;
- prosperity and threat bands;
- visual layers for major states;
- residents who move, leave, arrive, or change roles;
- projects with previewed costs and results;
- how target farming remains available if leadership changes;
- bar or town gossip derived from typed Comedy Memories.

Settlement decline can change presentation and opportunities, but cannot erase the Archive, Hearthfold access, essential vendors, or the only source of a build-defining item.

## 8. Living lair sheet

Each major lair declares:

- identity, purpose, history, and current occupant;
- Temperament and two to four mood states;
- inputs that change mood;
- route, encounter, hazard, puzzle, and reward changes per mood;
- equivalent total reward budget across valid approaches;
- one way the lair remembers prior expeditions;
- one relationship with a settlement, ecology actor, god, or demigod;
- one successor or post-resolution state;
- commentary voice charter or nonverbal communication rules.

A lair should alter at least two systems when its mood changes. Different-colored lights alone do not make it living.

No lair requires a deliberate death, ratings rank, real-world return window, or inaccessible reflex test for mastery.

## 9. Boss and succession sheet

### 9.1 Boss thesis

Define:

- the boss's role in ecology and civic pressure;
- the player skill or zone verb being tested;
- three readable phases or state transitions at most for the first encounter;
- adds, hazards, and arena interactions;
- retreat, checkpoint, and retry behavior;
- noncombat resolution if supported;
- baseline reward table, first-clear Cache, Seals, and target route;
- Herald, Picket, settlement, lair, and divine reactions.

### 9.2 Aftermath

The boss outcome should affect at least three of these:

- route;
- resource;
- ecology population;
- settlement service or appearance;
- faction control;
- successor candidate;
- lair mood;
- reward source;
- contract set;
- ambient sound or weather layer.

Defeated bosses remain available through an authored repeat context such as an Echo Hunt, successor ritual, simulation, or persistent world role. Repeats may have variants, but the baseline unique pool remains targetable.

## 10. Reward identity

Complete the zone reward sheet before encounter population:

- two to four base item families strongly associated with the zone;
- one to three materials;
- six to twelve standard affixes;
- two to four special affixes;
- two to six curated laws or uniques;
- one boss Seal pool;
- one earned Cache;
- one crafting or Reclamation component;
- one cosmetic family;
- target sources, pity thresholds, alternate paths, and reconstruction rules.

World-state branches can alter which source is convenient, which cosmetic variant appears, or which support affix is weighted. They cannot permanently remove the only acquisition path for a build law.

## 11. Humor and commentary plan

### 11.1 Voice triangle

Choose three perspectives with different motives. For each, define:

- what the voice wants from the player;
- what it misunderstands about the zone;
- what it knows that the others do not;
- preferred sentence shape and targets;
- protected sincere topics;
- lines or joke structures it must never use;
- how its attitude can change after the zone resolution.

The Herald does not have to be one of the three. A bar, lair, god, settlement official, item appraiser, enemy, or Picket may carry the local voice.

### 11.2 Event coverage

Author commentary candidates for:

- arrival and orientation;
- first encounter with each major ecology role;
- discovery of the primary zone verb;
- unusual but legible system combinations;
- one recurring failure with escalating callbacks;
- a promoted enemy;
- a rare reward;
- settlement return;
- boss start, outcome, and aftermath;
- one delayed cross-zone callback.

Coverage is not a requirement that every event speaks. All lines obey the global scheduler, silence budget, cooldowns, combat safety, and player settings.

## 12. Zone mastery ledger

Mastery is a broad checklist, not a timed grade. Categories may include:

- route and landmark discoveries;
- ecology facts and interventions;
- settlement projects and relationship states;
- lair moods experienced;
- boss and successor outcomes;
- enemy families and mutations understood;
- target sources discovered;
- contracts and world events;
- secrets and collections;
- zone-specific build experiments.

Mastery cannot require death, damage taken, high Spotlight, speed runs, a restricted difficulty, disabled accessibility tools, avoidance of fast travel, real-world dates, or destructive state choices. Optional challenge feats may grant cosmetics or alternate currencies but are not counted toward ordinary zone completion.

Ledger milestones reveal target information, unlock Hearthfold anchors, add World Temper choices, and provide cosmetics or choice rewards. They do not multiply baseline power without a cap.

## 13. Production budget

Each zone pitch supplies minimum and stretch counts for:

- square meters of unique navigable layout;
- modular environment kits and hero landmarks;
- subregions, routes, interiors, and lairs;
- enemy families, elite mutations, bosses, and neutral actors;
- state-driven visual, audio, navigation, and encounter variants;
- items, affixes, laws, Caches, and source tables;
- dialogue scenes, commentary definitions, memories, and appraisals;
- contracts, events, secrets, and settlement states;
- animation, VFX, SFX, music, and localization words;
- peak active actors, memory, draw calls, navigation regions, and save footprint;
- test scenes, deterministic fixtures, and review time.

Stretch content stays outside milestone acceptance until the minimum set is complete and measured. Asset variants do not count as new gameplay unless they change a readable decision.

## 14. Accessibility and performance

Before production, document:

- traversal alternatives for precision, timing, motion sensitivity, and visibility;
- color-independent hazard and state cues;
- subtitle load and combat-readability conflicts;
- camera collision and field-of-view risks;
- remappable inputs and hold/toggle behavior for the primary verb;
- enemy, VFX, physics, navigation, and streaming budgets;
- low-spec substitution rules;
- checkpoint spacing and safe exit behavior.

Assist settings preserve baseline rewards, mastery, Recognition, Spotlight eligibility, and story access. If an authored Spotlight combination cannot be performed with an assist, an equivalent combination must exist or the opportunity is removed from scoring.

## 15. Validation gates

### Pitch gate

- identity, primary verb, return promise, and reward family are distinct;
- scope fits current production evidence;
- state changes preserve key content;
- the comedy triangle contains genuinely different voices.

### Graybox gate

- a new tester can orient using landmarks;
- traversal loops and shortcuts save meaningful time;
- the primary verb works in traversal and at least two encounters;
- retreat, Hearthfold entry, checkpoints, and accessible alternates work;
- streaming and actor budgets hold on target hardware.

### Systems gate

- state transitions are deterministic and survive save/load;
- navigation, spawns, vendors, sources, ambience, and dialogue update together;
- every build-defining reward remains targetable in all terminal states;
- Spotlight bonuses remain separate from baseline rewards;
- the lair's moods change at least two systems.

### Content gate

- sources, pity, duplicates, and reconstruction are complete;
- commentary passes repetition and interruption tests;
- each subregion has a memorable decision or interaction;
- boss aftermath produces visible return value;
- mastery excludes punishment requirements.

### Release gate

- no major route has an unrecoverable save or navigation trap;
- state migrations pass from every supported fixture;
- performance and memory hold during worst-case events;
- UI explains current state and target routes without an external guide;
- a post-resolution expedition remains rewarding and meaningfully different.

## 16. Gutterbloom mapping example

The first slice applies this template at reduced scale:

- **Primary verb:** redirect and exploit moving water.
- **Orientation:** Latchmarket, The Dry Boot, and the visible root bridge.
- **Subregions:** settlement edge, Floodgate Commons, Causeway or Culvert route, Root-Turn, and the Courtesy Drain approach.
- **Living lair:** The Courtesy Drain with four moods.
- **Boss:** the Rain Treasurer.
- **State dimensions:** water level, predator pressure, Tollmold spread, patrol control, settlement prosperity, and boss succession.
- **Reward identity:** Gutterbloom materials, water and root interactions, Rain Treasurer pool, and a first-clear Cache.
- **Return promise:** changed water routes, predator migration, new target sources, successor signals, and updated town response.

The full route, encounters, and acceptance criteria remain authoritative in `GUTTERBLOOM_VERTICAL_SLICE.md`. This example tests the template rather than replacing that specification.

## 17. Deferred decisions

- the ideal number of subregions after the first two production zones;
- how many ecology dimensions remain understandable without a War Room;
- whether one major lair per zone is sufficient at 1.0 scale;
- the right amount of post-boss route transformation;
- which authored states can be revisited through Echo Hunts or pocket routes;
- production ratios among unique geometry, modular kits, and state variants.
