# Technical Design

## 1. Technical direction

Use Godot 4.7.2 stable, pinned in the repository, with typed GDScript and a data-driven content layer. The approved runtime direction combines a low-resolution top-down strategic world and settlement presentation with the proven first-person 3D dungeon viewport beneath a resolution-independent interface. Deterministic plan-and-resolve combat remains isolated from presentation and can be entered from kingdom sites, settlements, situations, or dungeons.

Why this direction:

- fast iteration for a solo or small-team first-person 3D and pixel-art prototype;
- open source and no per-install royalty dependency;
- strong scene, resource, input, animation, navigation, audio, and editor-tool workflows;
- GDScript keeps the initial build simple while typed boundaries and automated validation protect the larger content catalog;
- the game can remain offline-first without an account service.

The engine choice passed the initial import, content, test, save, and export harness. M00 remains open only for exported first-person crawler play review and the agreed cross-platform runtime gate.

## 2. Repository shape

Proposed structure:

```text
Loot/
  project.godot
  addons/
  assets/
    audio/
    fonts/
    materials/
    models/
    textures/
  content/
    affixes/
    caches/
    disciplines/
    enemies/
    factions/
    hearthfold/
    items/
    npcs/
    powers/
    rumors/
    settlements/
    situations/
    zones/
  docs/
  scenes/
    actors/
    combat/
    crawler/
    hearthfold/
    ui/
    world/
    zones/
  scripts/
    actors/
    combat/
    content/
    core/
    dungeon/
    inventory/
    loot/
    save/
    simulation/
    ui/
    visual/
    world/
  tests/
    content/
    integration/
    simulation/
    unit/
  tools/
```

The executable project exists. Planning files remain at the root for now so project navigation and existing links stay stable; a later documentation-only migration may move them under `docs/` atomically.

## 3. Runtime boundaries

### Presentation layer

Scenes, animation, particles, audio, cameras, UI, input prompts, and accessibility presentation consume game events. They do not decide loot, permanent progression, or zone-state outcomes.

### Gameplay domain

Typed gameplay objects define dungeon topology, party and enemy state, visible intentions, commands, targets, damage, statuses, resources, powers, equipment laws, interactions, objectives, and actor state. Combat rules duplicate planning inputs, resolve deterministic results, and emit a log that presentation can animate without changing outcomes.

### Simulation layer

The zone simulator advances persistent ecology, factions, resources, weather, prosperity, threats, named-entity activity states, relationships, rumors, situations, lairs, and successor states. It uses coarse state transitions for distant areas and never runs thousands of offscreen actors. Closing the game freezes authoritative simulation.

### Persistence layer

Save and inventory repositories own serialization, atomic writes, migrations, backups, item indexing, and recovery. Gameplay code requests transactions instead of writing arbitrary files.

### Content layer

Versioned definitions supply items, powers, enemies, drops, events, dialogue fragments, zone rules, room graphs, covenants, and recipes. Content references immutable string IDs, not scene paths scattered through code.

`CONTENT_PIPELINE.md` is authoritative for definition schemas, instance records, generation stages, reward ledgers, name and description composition, and content gates. `ZONE_DESIGN_TEMPLATE.md` is authoritative for the minimum authored structure and validation expected of a production zone.

## 4. Core services

Keep global services few and explicit:

- `ContentRegistry`: loads, validates, indexes, and version-checks content definitions.
- `RunSession`: owns the active character, expedition state, seed roots, and difficulty configuration.
- `SaveService`: snapshots state, writes atomically, rotates backups, imports, exports, and migrates.
- `InventoryRepository`: provides indexed item transactions without loading every item card into UI nodes.
- `ZoneStateService`: loads and advances compact persistent zone state.
- `WorldMemoryRepository`: stores and indexes typed relationship, knowledge, rumor, participation, promise, and significant-event records.
- `SituationDirector`: hard-filters, scores, instantiates, advances, and recovers authored situations within zone and presentation budgets.
- `HearthfoldCoordinator`: validates room graphs, Reclamation, residents, anchors, and upgrade transactions against the profile state.
- `CovenantService`: evaluates Recognition, Tension, offerings, proofs, and active covenant loadouts without reading wall-clock time.
- `EventStream`: typed gameplay events used by objectives, commentary, telemetry, and presentation.
- `SpotlightDirector`: scores novelty and risk, banks bonus milestones, and prevents repetitive trigger farming.
- `ComedyMemoryService`: stores compact typed callback records with salience, speaker access, expiration, and repeat limits.
- `CommentaryDirector`: prioritizes and schedules Herald lines under annoyance and safety budgets.
- `SceneRouter`: transitions between zone cells, interiors, settlements, and Hearthfold spaces.
- `SettingsService`: versioned input, display, audio, accessibility, and gameplay preferences.

Services expose narrow methods and signals. They must be replaceable in tests.

`HEARTHFOLD_UPGRADES.md` and `DIVINE_COVENANTS.md` define the saved state, transaction boundaries, progression invariants, and content rules those coordinators enforce.

`WORLD_SIMULATION_AND_MEMORY.md` and `SITUATION_ENGINE.md` define the simulation clocks, strategic tick, graph projection, situation lifecycle, persistence, performance, and safety boundaries for the new services.

## 5. Content definitions

Content should be authorable as Godot Resources during the slice, with a normalized export or catalog index generated by tooling. This includes items, powers, enemies, NPC dossiers, activity schedules, relationships, rumors, situations, rooms, covenants, and zone transitions. Each definition has:

- `content_id`: immutable namespaced ID such as `loot.weapon.raincheck`;
- `schema_version`;
- localization keys for name, short description, full description, and law text;
- tags from controlled vocabularies;
- compatibility and exclusion tags;
- asset references;
- numeric parameters with documented units and legal ranges;
- acquisition sources and rarity policy;
- optional deprecation or replacement metadata;
- test fixture references for rule-breaking content.

Definitions must never contain executable script strings. Custom laws reference registered, reviewed behavior components.

## 6. Item and modifier architecture

### Definitions versus instances

An `ItemDefinition` describes the base. An `ItemInstance` stores only identity and rolled state. UI resolves the instance through the registry. This prevents duplicating large descriptions and assets in saves.

### Law components

Item laws are composed from registered trigger, condition, effect, target, stacking, and limit components. Truly novel items may have a dedicated typed component, but still declare event subscriptions and interaction tags.

Example conceptual law:

```text
Trigger: PerfectDodge
Condition: IncomingObject has Projectile tag
Effect: CaptureProjectile(max_count=1)
FollowUp: FireCapturedProjectile(on=NextHeavyAttack, damage_scale=1.25)
Cooldown: 4 seconds
```

The final game needs a modifier trace panel showing how base value, additive modifiers, multiplicative modifiers, caps, conversions, and triggered laws produced an observed number.

### Interaction safety

- Each law declares whether it can trigger other laws.
- Recursive triggers carry a chain ID and maximum depth.
- Cooldowns use explicit game-time clocks.
- Damage conversion follows a single ordered pipeline.
- Proc coefficients prevent very rapid attacks from multiplying on-hit value without limit.
- Summons inherit only explicitly allowed modifiers.
- Unsupported combinations fail validation rather than silently doing nothing.

The complete item pipeline runs baseline generation before any labeled bonus lane. Spotlight, contracts, covenants, and living-zone events may generate additional rolls but cannot modify the baseline item seed or result. See `CONTENT_PIPELINE.md`.

## 7. Determinism and random streams

Permanent outcomes use seeded randomness. Visual particles, animation variation, and ambient sound use separate non-authoritative randomness.

Seed hierarchy:

```text
profile seed
  -> zone-state cycle seed
      -> event seed
          -> encounter seed
              -> enemy variation seed
              -> reward seed
                  -> rarity stream
                  -> base-family stream
                  -> affix stream
                  -> roll-value stream
```

Adding a particle or extra enemy bark must not change an already-determined reward. Debug builds record seed paths and reward decisions in a replayable ledger.

## 8. Combat execution

- Physics runs at a fixed project setting selected through profiling.
- Input is sampled into command objects so controller, keyboard, replays, and future networking use the same gameplay boundary.
- Hit detection reports attack ID, attacker, victim, hit shape, contact, tags, and timestamp to the damage pipeline.
- Damage resolution produces an immutable result containing mitigations, conversions, status buildup, stagger, procs, deaths, and emitted events.
- Animation controls presentation timing, while gameplay-critical active and recovery windows are data-defined and testable.
- Bosses use explicit state machines with interruptible phases and checkpoint snapshots.

## 9. Living-zone simulation

Do not persist every spawned actor. Persist zone aggregates and important named entities.

Example zone snapshot:

```text
zone_id
state_revision
last_simulated_game_time
control_by_subregion
settlement_prosperity
population_pressure_by_family
resource_pressure_by_type
weather_state
threat_level
route_states
active_event_records
named_entity_records
boss_succession_record
lair_temperament_records
promoted_enemy_records
discovered_anchors
player_intervention_flags
```

Simulation uses bounded ticks:

- nearby combat: real time;
- loaded subregion director: every few seconds;
- zone strategic state: every several in-game minutes or on meaningful events;
- unloaded zones: coarse advancement only when travel, explicit rest, or an authored cross-zone event advances game time;
- offline return: rebuild indexes and summarize the last committed state without authoritative world advancement.

All transitions are deterministic from prior state, elapsed game time, inputs, and the relevant seed. Critical content has fallback states so a bad simulation result cannot erase access.

The strategic tick is an atomic proposal pipeline:

```text
committed events
  -> renewable pressures
  -> named-NPC activities
  -> authored relationship and rumor transfers
  -> situation advancement
  -> zone transitions and successors
  -> new situation candidates
  -> content-preservation validation
  -> journal and commit
```

Definitions index by dirty fact so a turn evaluates relevant rules instead of scanning the whole catalog. Named NPCs use presence slots and compact activity records while unloaded. Ordinary populations remain aggregate pressures and spawn budgets.

The conceptual Memory Graph is implemented through bounded typed records and repository queries, not arbitrary Cypher or a network graph service. The slice uses in-memory indexes over profile data. A bundled local database is considered only after the M34 benchmark proves it necessary. Full rules and provisional budgets are in `WORLD_SIMULATION_AND_MEMORY.md`.

Situations are authored definitions selected by hard eligibility, bounded relevance scoring, deterministic top-band variety, and active presentation budgets. The engine may select zero. Accepted objectives never expire autonomously, and unloaded ticks cannot kill named NPCs. See `SITUATION_ENGINE.md`.

## 10. Zone layout and streaming

The first slice uses one manageable scene with streamed subregions or visibility ranges, not seamless technology built for eight zones.

Long-term zones are divided into:

- persistent macro state;
- streamed exterior cells;
- separately loaded interiors and lairs;
- stable anchor transition points;
- encounter volumes that request spawns from the zone director;
- navigation regions linked at validated portals;
- hierarchical level-of-detail and occlusion groups.

World coordinates, physics layers, collision masks, navigation ownership, and interaction groups are documented before multiple zones are built.

Every production zone must pass the pitch, graybox, systems, content, accessibility, performance, and release gates in `ZONE_DESIGN_TEMPLATE.md`. These gates replace arbitrary square-kilometer targets with measured route density, state preservation, reward identity, return value, and hardware budgets.

## 11. Inventory persistence

The inventory interface must scale before the inventory count does.

### Slice backend

Use chunked, versioned profile files behind `InventoryRepository`. Common materials store aggregate counts. Equipment stores compact item instances. UI requests pages and indexes rather than instantiating the complete collection.

### Scale gate

Before public alpha, benchmark 100,000 equipment instances. If chunked files cannot meet search, transaction, backup, and corruption-recovery budgets, move the repository implementation to a bundled local database while preserving the interface.

### Transactions

Equip, salvage, craft, reroll, favorite, move, Cache open, reward grant, and loadout update are transactions. A transaction validates inputs, writes a journal record, updates in-memory indexes, schedules a snapshot, and can be recovered after interruption.

The overflow manifest is persistent. No reward path may discard an item because a UI container is full.

## 12. Save format and recovery

Each profile contains:

- a small manifest and version;
- character and build state;
- active expedition, Spotlight banks, and Embarrassment Remnants;
- divine Recognition, Tension, proofs, active covenant, and pending opportunities;
- named-entity activities, relationships, knowledge edges, rumors, promises, situations, and significant EventSummaries;
- inventory chunks and indexes;
- Hearthfold state;
- zone snapshots;
- discovery, codex, reputation, covenant, objective, Picket Trust, Accolade, and Indignity state;
- typed Comedy Memories and their expiration metadata;
- settings references;
- recent transaction journal;
- checksums and migration history.

Writes go to a new temporary file, flush, validate, then replace the prior snapshot. Maintain at least three rotating automatic backups plus manual named exports. Import operates on a copy, validates it, and never destroys the current profile on failure.

Every release that changes persisted data adds a migration fixture from the oldest supported version. Saves from a newer unsupported build are opened read-only or refused with a clear message, never guessed into corruption.

## 13. Commentary architecture

Commentary definitions include:

- event query and optional accumulated counters;
- required and forbidden tags;
- channel and priority;
- combat-safety class;
- per-line, per-topic, and global cooldowns;
- maximum lifetime repeats;
- tone and player teasing threshold;
- voice asset, subtitle key, and estimated duration;
- follow-up group and interruption policy;
- streamer-safe and reduced-intensity alternatives.
- optional Comedy Memory queries and memory updates;
- eligible interaction partners such as Picket, a lair, a god, or a bar NPC;
- sincerity holds that suppress routine jokes around protected scenes.

The scheduler maintains separate queues for Critical, Announcement, Commentary, and Ambient lines. It drops stale observations, defers unsafe jokes during intense combat, enforces global silence windows, backs off repeated topics exponentially, and prevents a rare reward announcement from being displaced by ambient chatter.

The EventStream can also drive text-only procedural announcement templates from grammar-constrained curated fragments. Fragments declare speaker, grammar, tags, tone, intensity, safety, and compatible neighbors. Templates must pass grammar snapshots and realistic event-storm reviews. Voice is limited to authored recordings or approved local synthesis; the core game does not require remote generation.

Comedy Memories store game-defined facts only, such as a promoted enemy, ignored Picket warning, unusual item use, divine refusal, fall location, or resolved Indignity. They never inspect microphone input, arbitrary chat, local files, contacts, or external behavior.

The commentary runtime is local and deterministic at a fixed event sequence. Hard eligibility filters run before ranking, so cooldown does not merely lower a line's score. Spotlight writes only to its bonus ledger and cannot touch baseline loot, vendors, covenant progress, or ordinary experience. `COMMENTARY_SPOTLIGHT_SPEC.md` defines the canonical event schema, ranking formula, channel matrix, memory retention, rank banking, and performance tests.

## 14. Artificial intelligence

"AI" has three different meanings and must stay separated:

1. **Enemy behavior:** behavior trees or hierarchical state machines with authored roles, perception, navigation, and group signals.
2. **World intelligence fiction:** Herald Engine and other machine characters, implemented through authored rules and dialogue.
3. **Development assistance or optional generation:** never required at runtime and never allowed to mutate saves, rewards, or live balance without reviewed data.

Enemy behavior uses role slots to avoid every actor attacking simultaneously. Navigation failure has timeouts and recovery. Important state changes emit debug traces visible in an in-game inspector.

## 15. UI architecture

- Controller focus and mouse interaction are first-class, not separate late passes.
- Inventory grids are virtualized.
- Item cards share one formatting service across ground labels, comparison, Archive, crafting, and reward reveals.
- Every icon has a text equivalent.
- Long descriptions use expandable sections: summary, law, exact numbers, interactions, source, history.
- HUD scale, subtitle size, contrast, screen shake, flashes, damage numbers, aim help, hold/toggle behavior, and commentary intensity are settings from the slice.
- The combat HUD has a defined information budget and cannot display every proc simultaneously.

## 16. Development tools

Required editor and debug tools grow with the content system:

- content validator and duplicate-ID scanner;
- loot laboratory that rolls at least 100,000 rewards and reports distributions;
- item inspector and modifier trace;
- combat dummy with DPS, burst, status, stagger, and proc summaries;
- zone-state inspector with time advance and event injection;
- commentary event console, cooldown viewer, and transcript export;
- save viewer, migration runner, corruption simulator, and inventory stress generator;
- Hearthfold prerequisite graph, Reclamation transaction simulator, and room-state viewer;
- covenant relationship inspector with action injection, offering preview, and forbidden-effect audit;
- strategic-turn stepper, dirty-fact viewer, named-NPC presence map, relationship and rumor provenance inspector;
- situation candidate, score, binding, stage, fingerprint, discovery, preservation, and recovery inspector;
- spawn palette for enemies, elites, bosses, caches, and environmental states;
- automated screenshot scenes for UI regression checks;
- performance capture route through the vertical-slice zone.

## 17. Testing strategy

### Unit and property tests

- damage pipeline ordering and caps;
- status buildup and boss control rules;
- cooldown, Strain, debt, summon, and trigger-chain rules;
- item generation legality and deterministic reproduction;
- reward distributions, pity, duplicate conversion, and target attunement;
- inventory transactions, overflow, auto-salvage preview, and rollback;
- Hearthfold prerequisite acyclicity, Reclamation protections, RU costs, and transaction rollback;
- Recognition persistence, Tension effect restrictions, covenant swap, and offering protections;
- strategic-turn determinism, named-NPC scheduling, relationship deltas, rumor propagation, and content-preservation invariants;
- situation eligibility, active budgets, deterministic selection, stage recovery, and offscreen mortality prohibition;
- zone transition invariants;
- commentary priority, cooldown, and annoyance budgets;
- Spotlight novelty scoring, milestone banking, and anti-farming rules;
- Comedy Memory salience, callback eligibility, expiration, and repeat limits;
- Picket warning priority, chatter controls, and Herald exchange interruption;
- save serialization, checksums, migration, backup, and recovery.

### Integration tests

- start profile to first anchor;
- kill enemy to item grant to equip to save/load;
- Cache award to reveal to Archive;
- death to checkpoint recovery;
- boss victory to zone-state change and return visit;
- Hearthfold upgrade to room availability across zones;
- Reclamation preview to protected-item validation to room growth to save/load;
- defeat to preserved banked Spotlight to active-progress Remnant to promoted-enemy resolution;
- divine action to Recognition or Tension change to covenant swap to save/load;
- committed event to strategic turn to relationship or rumor change to situation discovery to save/load;
- recorded Comedy Memory to delayed callback to expiration;
- controller-only navigation through all required slice UI;
- import an old fixture and continue play.

### Playtest gates

Automated tests cannot prove combat feel, encounter clarity, humor, build comprehension, or fatigue. Each release gate includes observed play sessions with written findings and retest of changes.

## 18. Initial quality budgets

Exact target hardware is selected during M01, but these budgets guide architecture:

- steady 60 frames per second at 1080p on the defined minimum PC in ordinary slice combat;
- 99th-percentile frame time below 33.3 ms during the standard stress encounter;
- no unbounded allocation growth after 30 minutes of repeated combat and zone travel;
- ordinary autosave below 250 ms on the minimum storage target, performed without a visible multi-frame freeze;
- full profile snapshot below 2 seconds at the 100,000-item stress target;
- common Archive searches below 100 ms at 100,000 item instances;
- initial profile load below 5 seconds at the stress target;
- a vertical-slice strategic turn below 3 ms at the 99th percentile for the declared slice scale, excluding scheduled disk snapshot work;
- common bounded relationship, rumor, presence, and situation queries below 50 ms at the M34 stress target;
- return processing rebuilds indexes and summarizes committed state without authoritative offline advancement;
- zero missing content references, illegal affix combinations, duplicate IDs, or orphaned localization keys in release builds;
- deterministic reward and zone-state fixtures reproduce exactly within a pinned release.

Budgets are not passes until measured on named hardware and recorded in a release report.

## 19. Networking gate

Single-player systems should avoid choices that make future co-op impossible, but no live networking architecture is required for the first alpha.

After the solo alpha, a bounded spike should test:

- host-authoritative two-player combat;
- deterministic reward grants per player;
- join/leave at anchors;
- Hearthfold ownership and guest permissions;
- zone-state ownership and conflict handling;
- latency at expected enemy density;
- save recovery after host interruption.

Co-op advances only if it preserves offline play, does not require rewriting every item law, and can be maintained by the available team.

## 20. Security and privacy

- Offline play needs no account and sends no gameplay data by default.
- Debug logs redact filesystem user names and platform identifiers from shareable exports.
- Imported saves and future mods are treated as untrusted data with schema, size, and path validation.
- No remote content is executed as code.
- Optional telemetry, crash reporting, cloud saves, community sharing, and online challenge boards each require explicit product and privacy review before implementation.
