# Supplied Plan Synthesis

This document records how the nine supplied planning files were incorporated. It prevents good ideas from being lost and prevents incompatible scope or friction from quietly returning.

## Inputs merged

1. The original zone-based crawler wishlist and 18-month concept roadmap.
2. The critique that introduced stakes, economy drains, callback memory, scope correction, and an IP plan.
3. The response that strengthened death, overlapping sinks, procedural templates, and the need for a load-bearing companion.
4. The full `Dungeon Broadcast: Infinite` GDD, including nested gameplay loops, detailed ratings effects, living dungeon evolution, safe-room feeding, technical assumptions, social features, and a risk register.
5. The Sections I-VI technical deep-dive covering commentary events and selection, viewership math, a complete sample zone, safe-room trees, procedural item generation, and god relationship tables. A second pasted copy was substantively identical and omitted only two footer lines.
6. Section VIII Part A, proposing an hourly five-phase server simulation for schedules, NPC interactions, situation escalation, world state, persistence, and ghost echoes.
7. Part B, proposing a Neo4j property graph for NPCs, players, events, places, items, rumors, situations, factions, relationships, causality, and information flow.
8. Part C, proposing probability matrices, relationship analysis, situation instantiation, deadlines, branching outcomes, discovery routes, cooldowns, and deduplication.
9. Part D, providing detailed source NPC dossiers with presentation, backstory, schedules, secrets, relationships, quests, recurring-nemesis behavior, items, and death consequences.

## Adopted as core design

### Stakes without a global timer

The supplied critique correctly observes that humor needs consequence. The design now uses **Spotlight**, promoted enemies, Embarrassment Remnants, faction response, living-zone consequences, and remembered Indignities. These create risk and comic payoff without expelling the player from a zone or reducing baseline grind rewards.

### Hearthfold as a loot sink

The portable home now includes a voluntary Reclamation Core that digests selected items into room growth, materials, and collection progress. It displays unread low-rarity item appraisals before first digestion so joke items have a purpose beyond instant salvage.

### Callback memory and novelty budget

The commentary system now has typed Comedy Memories, line and topic cooldowns, priority channels, combat-safety rules, exponential topic backoff, a global silence budget, and persistent callbacks. Text fragments provide breadth; authored voiced scenes provide depth.

### A load-bearing companion

Picket, an original brass safety-inspector construct, becomes a mechanical scout, information source, comic countervoice, and emotional anchor. Picket bickers with the Herald but is not a copy of another franchise's animal companion.

### Living lair personalities

Important lairs gain authored Temperaments and mood states that change encounter and reward categories. Different play styles retain equivalent reward budgets.

### Scope correction

The roadmap proves its differentiators in a small vertical slice before promising broad zones or online systems. Single-player saves are local-first. Real-time co-op, auction houses, server persistence, and rapid live-content cadence remain conditional.

### Nested gameplay loops

The full GDD's 30-second, five-minute, session, and long-term loop framing is now part of `GAME_DESIGN.md`. Each scale must work without ratings decay, offline chores, or a requirement that every session contain a death.

### Original public identity

The public design keeps the structural desires but uses original characters, items, classes, gods, terminology, dialogue, lore, and zones. It does not use recognizable book names or named objects.

### Typed commentary pipeline

The deep-dive's strongest technical contribution is the separation among event capture, candidate discovery, eligibility, scoring, selection, playback, and callback storage. `COMMENTARY_SPOTLIGHT_SPEC.md` turns that into a local deterministic system with a canonical event envelope, hard cooldown and safety filters, speaker channels, typed Comedy Memories, grammar-constrained templates, interruption rules, and performance tests.

### Staged item generation

The item proposal's separation of bases, affixes, named combinations, sources, descriptions, and validation is now a versioned deterministic pipeline. `CONTENT_PIPELINE.md` adds controlled exclusivity groups, separate random streams, curated laws, a reward ledger, target protection, deterministic fallbacks, Monte Carlo reports, and a strict boundary between ordinary source rewards and bonus lanes.

### Reusable zone authoring structure

The sample-zone document demonstrated a useful checklist covering identity, subregions, ecology, hazards, boss, lairs, secrets, mastery, and content budgets. Its named setting and specific expression were not imported. `ZONE_DESIGN_TEMPLATE.md` generalizes the structure for original zones and adds safety, state preservation, target-source continuity, accessibility, performance, post-boss return value, and production gates.

### Upgrade and relationship tables

Dependency trees, room tiers, synergies, offerings, divine philosophies, and relationship thresholds are useful planning devices. They now appear in `HEARTHFOLD_UPGRADES.md` and `DIVINE_COVENANTS.md` with protected transactions, expedition-driven growth, horizontal utility, persistent Recognition, and non-destructive Tension.

### Layered living-world simulation

The five-phase tick usefully separates schedule, interaction, situation, world, and persistence concerns. `WORLD_SIMULATION_AND_MEMORY.md` translates it into local combat, loaded-subregion, zone-strategic, and unloaded-zone layers. Dirty-fact indexes, aggregate populations, named-entity records, deterministic delta proposals, content-preservation validation, and atomic commits replace an hourly whole-server scan.

### Relationship and rumor graph

The graph proposal identifies valuable questions: who knows a fact, how a rumor traveled, which relationships matter, what depends on a character, and which callback memories are eligible. The integrated Memory Graph is a typed repository API over local save records. It materializes only useful edges, uses authored rumor variants, and can move to bundled SQLite only if scale tests justify it.

### Authored situation combinations

The candidate, filter, score, instantiate, deduplicate, discover, and outcome stages are preserved in `SITUATION_ENGINE.md`. Real-time deadlines and random punishment are replaced by in-game stages, accepted-objective permanence, active budgets, deterministic selection, content-preserving autonomous transitions, and explicit recovery paths.

### Dossier-driven cast production

The dossier depth is adopted as an authoring standard, not as production characters. `NPC_DOSSIERS.md` requires motives, presentation, knowledge, relationships, activity states, services, arcs, humor, sincerity, mortality policy, successors, budgets, and tests. It then defines an original eight-member Gutterbloom ensemble tied to the existing ecology, factions, routes, Picket, and Rain Treasurer.

## Adopted with changes

| Supplied idea | Integrated version | Reason for change |
| --- | --- | --- |
| Viewership decays during safe grinding and multiplies loot quality | Spotlight adds bonus rewards for novelty and risk but never reduces baseline loot | The player asked for an enjoyable grind without pressure. Safe farming must remain valid. |
| A cumulative audience score reaching millions | Five readable expedition Spotlight ranks plus banked bonuses and persistent Renown | Smaller state is easier to explain, balance, save, and protect from exploits. |
| Death causes durability loss or a best-item corpse run | Completed Spotlight rewards remain banked; unfinished progress may form an optional Embarrassment Remnant and the killer may be promoted | Losing access to a build item or banked reward conflicts with the anti-frustration contract. |
| Safe room eats loot | Player-confirmed Reclamation Core with protections, preview, item text, and reconstructable uniques | Keeps the economy sink while preventing secret or accidental loss. |
| Thousands of narrator lines | Authored complete lines plus grammar-constrained fragments, callback memory, and measured voice scope | Mathematical combinations do not guarantee comedy, and full voice has high production cost. |
| Dungeons evolve over real-world days | Lair and zone states advance through active play, travel, explicit rest, and authored events; closing the game freezes authoritative state | No real-world schedule should pressure the player or erase an opportunity. |
| Massive server-side inventory | Local-first repository benchmarked at 100,000 item instances, optional cloud later | Offline continuity and manageable operating cost are core product values. |
| Async social ghosts and public shame | Local replay echoes first; privacy-reviewed optional sharing later | Preserves the joke and future social possibility without making online service foundational. |
| Many overlapping currency sinks | Small currency vocabulary plus Reclamation, crafting, offerings, settlement projects, and transparent exchanges | Fifteen currencies and opaque gambling create administration rather than depth. |
| Huge procedural zones with a fixed square-kilometer minimum | Authored macro layouts with systemic state and bounded procedural encounters | Quality, traversal density, and production capacity matter more than land area. |
| Unreal Engine, a custom ECS, PostgreSQL, Redis, PlayFab or AWS, and server validation | Current stable Godot 4 is the planning recommendation, but M00 must prove it; local repositories and typed events come before infrastructure | The actual project is empty, team size is unknown, and an offline single-player slice should not inherit speculative service cost. |
| Inventory movement-speed tax and 200-to-2,000 carried slots | Generous Field Kit, automatic materials, Field Sweep, persistent overflow, and a near-unlimited virtualized Archive | Hoarding and collection are promised pleasures, not hidden encumbrance systems. |
| Safe room summons on a 30-minute cooldown | Out-of-combat entry with encounter checkpoints and explicit exit rules | A real-time home cooldown conflicts with the anti-timer goal. |
| Viewership discounts vendor prices and accelerates god favor | Spotlight produces separate bonus rolls, incidents, and spectacle rewards | Efficient shopping and ordinary covenant progress should not require performing for the system. |
| Commentary scoring reduces a cooling-down line's weight | Cooldown, caps, safety, settings, and sincerity are hard filters before scoring | An ineligible line should never win merely because the remaining pool is weak. |
| Remote commentary brain with service database and player IDs | Local Godot `EventStream`, `CommentaryDirector`, typed definition registry, and profile memory | Offline solo play does not need operational cost, identity collection, or network failure modes. |
| Callback retention measured in real-world days | Event-distance, salience, repeat caps, and authored permanence policies | The game remembers play, not how long the user stayed away. |
| Positive and negative entertainment scores for builds, travel, farming, and caution | Positive-only Spotlight points for authored novelty, explicit risk, and execution | No scoring system should judge build popularity or punish the relaxed grind. |
| Spotlight or viewership changes ordinary loot weights | Baseline item generation completes first; Spotlight adds a labeled bonus lane | The same source, seed, and reward-ledger state must create the same ordinary item at every Spotlight rank. |
| Safe-room feeding has daily caps, real-world build time, and required top-rarity offerings | Any-rarity Reclamation with no daily cap; all normal tiers achievable with Worn through Rare plus play-earned components | Home growth should consume chosen surplus, not time or cherished items. |
| Safe-room invasions damage and de-level rooms | Optional isolated defense simulations restore the exact prior home state after failure | A refuge cannot be trustworthy if an opt-in activity can erase it. |
| Favor spans negative to positive values and decays each day | Persistent Recognition from 0 to 100 plus non-destructive Tension | Disagreement creates content without turning absence or experimentation into lost progress. |
| Divine curses delete items, reduce statistics, or disable a zone | Optional amends, rivalry, mediation, contradiction routes, and covenant sidegrades | Gods can be dangerous and funny without damaging the profile or baseline game. |
| A complete supplied sample zone becomes production content | Its checklist becomes an original zone template; its named content is not imported | Structure is reusable. Protected or overly specific expression is not. |
| Zone mastery includes ratings, speed, death, or punitive feats | Broad exploration, ecology, relationship, lair, source, event, and collection ledger | Ordinary mastery must remain compatible with the anti-frustration constitution. |
| Hourly server tick processes more than 10,000 NPCs | Four local simulation layers, aggregate populations, named-entity records, dirty-fact evaluation, and measured slice budgets | The solo game needs visible consequences, not speculative MMO infrastructure. |
| Every co-located NPC pair may interact probabilistically | Authored interaction definitions evaluate only compatible important roles and relationships | Generic pairwise rolls create noise, incoherent characterization, and quadratic scale. |
| Fixed daily schedules | In-game activity states driven by day phase, zone facts, accepted situations, and authored fallback | Characters should move believably without requiring a calendar appointment. |
| Neo4j graph with 100,000 nodes, 2 million edges, replicas, and S3 archive | Typed local relationship, knowledge, rumor, situation, event, and presence records behind a repository API | Query power is useful; mandatory network infrastructure is not. |
| Relationship and event history pruned after real-world 30- or 90-day windows | Event-distance, significance, story state, typed summaries, and bounded counters | Returning players should not lose character memory because time passed outside the game. |
| Rumors degrade through free-text rewriting | Authored accurate, partial, and distorted variants with provenance and hop limits | Preserves uncertainty without fabricating accusations, objectives, or broken prose. |
| Three to five situations selected every tick | Zero to two candidates within zone and presentation budgets; zero is valid | Stability and silence are healthier than mandatory drama production. |
| Situations expire in 24 to 72 real hours | Accepted objectives never expire; unaccepted situations use bounded in-game stages and safe dormancy or transformation | The player should not schedule life around a game emergency. |
| Ignored crises can kill named NPCs or crash reputation offscreen | Autonomous outcomes may move pressures, clues, activity, or opportunity state but preserve named characters and essential content | Consequences should follow observed play, not absence. |
| Viewership, active players, death totals, weekends, holidays, and update weeks alter situation probabilities | Local authored zone facts, relationship relevance, player causality, recovery value, and diversity scoring | Solo world state should respond to the profile, not nonexistent population metrics or a clock. |
| Vendors charge more after death, for low viewership, or for joke builds | Transparent authored prices, faction services, relationship access, and previewed market state | Dynamic exploitation punishes experimentation and failure. |
| Recurring nemesis evolution requires repeated player deaths or exact fight counts | Due Notice evolves through varied encounters, escapes, evidence, negotiation, and state changes | A relationship-bearing rival should not require deliberate failure or grinding an exact count. |
| Supplied dossier cast becomes production content | Dossier structure becomes a standard; Gutterbloom receives eight new original characters | Preserve depth while maintaining a distinct public identity. |

## Deliberately not carried forward

- copyrighted protagonist, companion, item, class, god, or setting names;
- a companion designed as a direct species or personality substitute for an existing character;
- random deletion or consumption of owned items;
- durability repair chores;
- paid keys or real-money randomized rewards;
- mandatory keys for earned Caches;
- daily quests, real-world progression windows, expiring seasonal rewards, or content vaulting;
- server-only saves or account requirements for solo play;
- real-time co-op and player trading in the foundation scope;
- auction-house balance as a dependency for ordinary loot;
- an arbitrary requirement for thousands of live entities or a specific architecture before profiling;
- a new full zone every month;
- guaranteed voiceover for procedural permutations;
- exact schedule estimates before team size, art direction, staffing, and prototype velocity are known;
- item-count marketing that treats random numeric combinations as authored content.
- rating loss for fast travel, cautious retreats, meta builds, accessibility options, or repeated target farming;
- movement penalties for using the promised large inventory;
- a requirement that every session contain an interesting death;
- an isometric camera toggle before a second camera, encounter, UI, and control model has a justified audience;
- forced online leaderboards, public death clips, guest books, mail, guilds, or social voting;
- automatic divine consumption of owned items;
- permanent build penalties for refusing to entertain the Herald;
- passive gains that create login obligations or punish time away;
- negative Spotlight or relationship scoring for build popularity, farming, caution, retreat, or fast travel;
- daily offering, room-feeding, favor, divine-hunger, or construction cycles;
- mandatory Legendary or Mythic offerings for safe-room or covenant progression;
- Hearthfold invasion damage, room de-leveling, resident loss, or stored-item loss;
- divine curses that delete items, reduce ordinary statistics or rewards, disable zones, or corrupt saves;
- mastery requirements based on death, damage taken, Spotlight, speed, disabled assists, or avoiding travel systems;
- real-world callback expiration as a gameplay mechanic;
- remote commentary generation, Redis, a player-history server, or account identity in the solo foundation;
- the technical deep-dive's named sample-zone content, specific bosses, items, jokes, and setting expression;
- the supplied server-tick code and its syntax, branching, duplicate-condition, and undeclared-context defects;
- server-authoritative player and NPC synchronization for the solo foundation;
- player IDs, global active-player metrics, global kill or death totals, and shared-server viewership inputs;
- operating-system weekday, holiday, anniversary, update-week, daily visit, or weekly visit triggers;
- real-time situation expiration and notifications that imply the player must log in;
- automatic offscreen named-character death, kidnapping, relationship collapse, reputation crash, or essential-service loss;
- generic random romance, affairs, betrayals, torture, or irreversible character outcomes;
- punitive vendor pricing based on fame, death, build choice, desperation, or day of week;
- mandatory graph-server deployment, zone sharding, cloud archive, read replicas, or 10,000-edge-per-second targets;
- free-form rumor mutation and automated factual invention;
- the supplied NPC names, species, backstories, relationships, dialogue, quests, items, death scenes, and named settings;

These exclusions are now explicit current product decisions, not merely suggestions. They may be reconsidered only as voluntary challenge mutators after the vertical slice, with separate approval and no effect on ordinary saves or unique reward access.

## New design work added during synthesis

- Spotlight rules that preserve baseline farming;
- Embarrassment Remnants and enemy promotion instead of gear loss;
- Picket's utility protocols, trust, and protected sincere scenes;
- Accolades and Indignities as systemic achievements;
- four original lair-personality seeds;
- item-description layers and 24 low-rarity appraisal examples;
- 16 announcement tone examples;
- explicit Comedy Memory privacy and expiration rules;
- humor-density presets and independent voice controls;
- a Reclamation Core flow with loss protections;
- production counts for the risk spike, vertical slice, and public alpha;
- humor-specific writing, repetition, comprehension, and interruption playtest gates.
- nested 30-second, five-minute, session, and long-term loop definitions;
- a Field Sweep collection rule without encumbrance;
- lair Memory Rank that evolves through completed play rather than calendar time;
- a canonical commentary event schema and hard-filter selection pipeline;
- a deterministic five-rank Spotlight ledger with banked threshold rewards;
- event-distance Comedy Memory retention and explicit privacy boundaries;
- a staged item generator with isolated baseline and bonus lanes;
- named synergy, affix exclusivity, fallback, pity, and content-quality contracts;
- six original divine covenant designs using Recognition and non-destructive Tension;
- Hearthfold Core ranks, eight five-tier room trees, and cross-room synergies;
- a reusable living-zone authoring template with ecology, safety, state, reward, mastery, accessibility, and production gates;
- a four-layer local simulation with deterministic atomic strategic turns;
- dirty-fact indexes, aggregate populations, named-entity state, activity schedules, and presence slots;
- a typed local Memory Graph for relationships, knowledge, rumors, events, situations, promises, and item origins;
- authored rumor variants, confidence bands, provenance, hop limits, and player-facing fact labels;
- an authored Situation Engine with hard filters, bounded scoring, active budgets, discovery, dormancy, transformation, and recovery;
- an NPC dossier standard with mortality, service-successor, humor, sincerity, and production requirements;
- eight original Gutterbloom cast members and ten initial situation seeds;

## Planning consequence

The project should de-risk Humor and Spotlight during the foundation phase, then prove world memory and situations inside the same bounded vertical slice. The full production library still arrives later. M18 through M24 must demonstrate that the Herald, Picket, named NPCs, rumors, callbacks, Spotlight, one strategic state transition, four situations, and an enemy promotion create a memorable session without repetition, coercion, offscreen punishment, or infrastructure the solo game does not need.
