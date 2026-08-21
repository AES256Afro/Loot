# World Simulation and Memory Specification

## 1. Purpose

The Living Expanse should remember what happened, move important characters through believable routines, propagate incomplete information, and create visible consequences without pretending that every creature is a continuously simulated server actor.

This specification defines a local-first simulation and memory model for a single-player game. It translates the useful ideas from the supplied server tick and graph proposals into bounded Godot services, deterministic state transitions, typed records, and profile-owned indexes.

The core invariant is:

> Simulate decisions that can become player-facing. Aggregate everything else.

The foundation does not require Neo4j, PostgreSQL, Redis, S3, a player account, read replicas, cloud queues, or a server-authoritative world.

## 2. Authority and clocks

### 2.1 Authoritative sequence

Every permanent world mutation receives a monotonic `world_sequence`. Systems use this sequence for ordering, causality, cooldown distance, deterministic selection, and replay protection.

`world_sequence` is separate from presentation frames and physics ticks. A particle effect cannot advance it.

### 2.2 Game-time clocks

The simulation recognizes:

- `physics_tick`: fixed-step loaded combat;
- `local_game_time_ms`: loaded-zone activity time;
- `zone_turn`: a strategic step caused by play, travel, rest, or a meaningful event;
- `expedition_sequence`: ordered expedition events;
- `world_sequence`: permanent state revisions.

It does not use calendar date, weekday, holiday, time since application close, or server uptime for authoritative social, relationship, situation, reward, or zone transitions.

In-fiction time of day may change lighting, schedules, encounters, and dialogue when advanced through play or an explicit rest action. It is not synchronized to the player's clock.

### 2.3 Offline behavior

Closing the game freezes authoritative world and social state. On return, the game may rebuild indexes, expire presentation-only queues, restore renewable ambience to the saved state's known band, and summarize the last committed state. It may not:

- kill or move a named NPC;
- resolve or worsen a situation;
- decay a relationship;
- destroy an opportunity;
- alter a route or settlement;
- consume resources or offerings;
- advance a covenant or Hearthfold room;
- reduce a reward.

## 3. Simulation layers

### 3.1 Layer 0: loaded combat

**Cadence:** fixed physics step.

**Represents:** active actors, hit detection, navigation, status, projectiles, interactables, hazards, and encounter state.

**Persistence:** only durable results become typed events and transactions. Ordinary spawned actors are not individually saved.

### 3.2 Layer 1: loaded subregion director

**Cadence:** event-driven with a provisional 0.5-to-2-second evaluation interval.

**Represents:** spawn budgets, patrol roles, neutral actors, ambient groups, hazard states, local NPC presence, local situation presentation, and streaming handoff.

The director evaluates only dirty facts. It does not scan every definition or pair every actor with every other actor.

### 3.3 Layer 2: zone strategic state

**Cadence:** meaningful event, explicit rest, travel transition, or a provisional three-to-ten in-game-minute interval while loaded.

**Represents:** population pressure, resource pressure, route stability, faction posture, settlement prosperity, named-NPC activity state, rumor propagation, lair mood, boss succession, and active situations.

One zone turn is an abstract opportunity for bounded change, not an hour of wall-clock time.

### 3.4 Layer 3: unloaded zone advancement

**Cadence:** when travel, rest, an authored cross-zone event, or zone load explicitly requests advancement.

**Represents:** aggregate transitions only. It never spawns combat actors or resolves player-facing choices.

One request runs at most a fixed number of coarse steps. Excess fictional time is compressed into a stable band with a summary. A long rest cannot produce thousands of simulation loops.

## 4. Zone snapshot

```json
{
  "zone_id": "zone.gutterbloom",
  "schema_version": 2,
  "state_revision": 14,
  "world_sequence": 8825,
  "fictional_day_phase": "trade",
  "control_by_subregion": {},
  "settlement_prosperity": "strained",
  "population_pressure": {
    "enemy.knuckle_newt": 42,
    "ecology.tollmold": 61
  },
  "resource_pressure": {},
  "weather_state": "warm_drizzle",
  "threat_band": "watchful",
  "route_states": {},
  "active_situation_ids": [],
  "named_entity_states": {},
  "relationship_edge_ids": [],
  "rumor_ids": [],
  "boss_succession": {},
  "lair_states": {},
  "promoted_enemy_records": [],
  "discovered_anchors": [],
  "player_intervention_flags": [],
  "recent_transition_fingerprints": []
}
```

Bounded numeric dimensions use 0 to 100 only when intermediate values create distinct decisions. Otherwise, use named enums such as `strained`, `stable`, and `thriving`.

## 5. Strategic tick pipeline

```text
advance request
  -> validate cause and step budget
  -> load prior snapshot and deterministic seed root
  -> phase 1: apply committed gameplay events
  -> phase 2: advance renewable pressures
  -> phase 3: select named-NPC activity states
  -> phase 4: evaluate authored relationship and rumor transfers
  -> phase 5: advance accepted or autonomous situation stages
  -> phase 6: evaluate zone transitions and successor rules
  -> phase 7: request new situation candidates
  -> phase 8: validate content-preservation invariants
  -> phase 9: journal delta, commit atomically, emit summary events
```

No phase writes directly to presentation. It produces a delta proposal. The proposal is validated as a whole before commit.

### 5.1 Phase budgets

Provisional vertical-slice budgets on the named M01 development target:

| Phase | 99th-percentile budget | Slice scale |
| --- | ---: | --- |
| Event reduction | 0.25 ms | 500 queued typed events |
| Pressure advancement | 0.20 ms | 12 bounded dimensions |
| Named-NPC activity | 0.25 ms | 12 named entities |
| Relationships and rumors | 0.40 ms | 128 active typed edges |
| Situation advancement | 0.30 ms | 8 active or latent records |
| Zone transitions | 0.30 ms | 64 authored transition rules |
| Candidate request | 0.50 ms | 100 indexed situation definitions |
| Validation and delta assembly | 0.50 ms | one zone snapshot |
| **Total simulation work** | **2.70 ms** | excluding disk snapshot scheduling |

These are hypotheses until measured. Persistence may be scheduled after the in-memory journal commit, but permanent rewards and owned items retain their stricter transactional path.

## 6. Dirty-fact evaluation

The simulation maintains controlled fact keys such as:

- `zone.water_level.low`;
- `route.culvert.open`;
- `settlement.prosperity.strained`;
- `npc.dava.activity.bar_service`;
- `relationship.dava.claimant.trust.known`;
- `rumor.rain_order_invalid.discoverable`;
- `boss.rain_treasurer.defeated`.

Every committed event declares which facts it can dirty. Transition, schedule, situation, and rumor definitions index their required facts. A zone turn evaluates only definitions associated with dirty keys plus explicitly scheduled maintenance rules.

This prevents an expanding content catalog from becoming a whole-world scan.

## 7. Population and location abstraction

### 7.1 Ordinary populations

Ordinary creatures, workers, travelers, and patrols are aggregate bands plus spawn budgets. The snapshot may know that Knuckle Newt pressure is high and the Causeway patrol role is active. It does not track 843 individual newts offscreen.

### 7.2 Named entities

Named NPCs, promoted enemies, bosses, demigods, residents, and authored neutral actors receive compact records:

```json
{
  "entity_id": "npc.gutterbloom.dava_fen",
  "life_state": "active",
  "zone_id": "zone.gutterbloom",
  "presence_id": "place.dry_boot",
  "activity_state": "bar_service",
  "mood_band": "guarded_warmth",
  "active_goal_id": "goal.keep_bar_neutral",
  "relationship_revision": 8,
  "knowledge_revision": 5,
  "situation_ids": [],
  "story_flags": []
}
```

Named entities cannot die, permanently leave, or lose an essential service from an unloaded-zone tick. Such changes require an authored resolved situation, a directly observed combat result, or a previewed player choice. Every terminal state declares a successor or preserved alternate source for essential services and build rewards.

### 7.3 Presence slots

Locations define role slots such as `barkeep`, `rumor_guest`, `anchorwright`, `patrol_contact`, and `ecology_delegate`. Schedule and situation systems assign eligible named NPCs to slots. Presentation spawns only the roles visible in the loaded cell.

## 8. NPC activity schedules

Schedules use activity states and game-phase predicates, not fixed real-world appointments.

```json
{
  "schedule_id": "schedule.gutterbloom.dava",
  "default_activity": "bar_service",
  "rules": [
    {
      "activity": "roof_supply_run",
      "requires_all": ["day_phase.trade", "route.roofline.safe"],
      "excludes": ["situation.dry_boot_incident.active"],
      "priority": 40
    },
    {
      "activity": "bar_service",
      "requires_all": ["place.dry_boot.available"],
      "priority": 30
    },
    {
      "activity": "shelter_management",
      "requires_any": ["weather.hard_rain", "situation.evacuation.accepted"],
      "priority": 90
    }
  ],
  "fallback_activity": "offscreen_rest"
}
```

Activity selection is deterministic by eligibility, priority, last-used suppression, and schedule-specific seed. When a route is blocked, the NPC selects an authored fallback. It does not attempt general pathfinding across an unloaded zone.

## 9. Local interaction model

Named NPC interactions occur only when an authored interaction definition finds compatible role slots, relationship bands, knowledge, goals, and current situations.

```text
co-presence changed
  -> find interaction definitions indexed by participant tags
  -> hard-filter prerequisites, cooldown distance, safety, and story state
  -> rank by urgency, specificity, novelty, and unresolved relevance
  -> select zero or one interaction for this location turn
  -> propose bounded relationship, rumor, situation, and activity deltas
  -> validate and commit
```

There is no general pairwise roll among every NPC in a location. Crowds use ambient group definitions. Important relationships receive authored interactions.

Random romance, coercion, betrayal, or death is not generated from raw affection or resentment scores. Intimate and irreversible story changes require authored content, participant-specific eligibility, content review, and player-facing context.

## 10. Relationship graph model

The **Memory Graph** is a conceptual query API over compact typed records. It is not an instruction to deploy a graph database.

### 10.1 Node types

- `Actor`: Claimant profile identity, named NPC, boss, demigod, god envoy, or promoted enemy;
- `Faction`: authored group and local chapter;
- `Place`: zone, subregion, settlement, bar, lair, room, or anchor;
- `EventSummary`: durable significant gameplay event;
- `Rumor`: authored proposition plus belief state;
- `Situation`: active or historical opportunity and outcome;
- `ItemOrigin`: only notable curated item history, not every inventory item;
- `Promise`: accepted authored commitment without real-world expiration.

### 10.2 Edge types

| Edge | From and to | Selected properties |
| --- | --- | --- |
| `RELATES_TO` | Actor to Actor | trust, regard, tension, fear, curiosity, state, revision |
| `KNOWS_ABOUT` | Actor to Actor, Place, ItemOrigin | topic ID, detail variant, confidence, source |
| `BELIEVES_RUMOR` | Actor to Rumor | confidence, share policy, learned sequence |
| `WITNESSED` | Actor to EventSummary | role, reliability, reaction tag |
| `CAUSED` | Actor to EventSummary | intent tag, directness |
| `AFFECTED_BY` | Actor, Faction, or Place to EventSummary | impact tag, severity band |
| `PARTICIPATES_IN` | Actor or Faction to Situation | role, awareness, stake band |
| `MEMBER_OF` | Actor to Faction | role, loyalty band, public status |
| `PRESENT_AT` | Actor to Place | activity, since sequence |
| `HOLDS_PROMISE` | Actor to Promise | role, status, accepted sequence |
| `ORIGINATES_FROM` | Rumor or ItemOrigin to EventSummary | confidence and revision |

The system creates only edges used by authored queries. It does not materialize every possible NPC pair.

### 10.3 Relationship dimensions

Named relationships may track 0-to-100 `trust`, `regard`, `tension`, `fear`, and `curiosity`. Definitions declare which dimensions they use. Unused dimensions are absent.

Every delta has:

- a typed cause;
- a declared clamp;
- a source world sequence;
- a UI visibility policy;
- a callback eligibility policy.

Relationships do not decay with wall-clock time. Ordinary repeated gifts or dialogue choices stop adding progress after authored caps but do not subtract it.

## 11. Memory records

An `EventSummary` stores the minimum facts needed for future systems:

```json
{
  "summary_id": "memory.gutterbloom.picket_warning.04",
  "event_type": "picket.warning_resolved",
  "world_sequence": 8812,
  "zone_id": "zone.gutterbloom",
  "participant_ids": ["companion.picket", "claimant.local"],
  "fact_tags": ["warning.ignored", "hazard.pressure_jet", "outcome.survived"],
  "significance": 0.58,
  "truth_state": "observed",
  "retention_policy": "until_callback_resolved",
  "repeat_budget": 1
}
```

Retention uses event distance, salience, story state, and explicit permanence. It never uses 30-day or 90-day real-world pruning.

Low-significance events can be summarized into counters such as `barrels_broken: 37`. High-significance events retain a typed summary. Full combat logs use separate bounded diagnostic storage and are not social memory.

### 11.1 EventSummary versus Comedy Memory

An `EventSummary` is a world fact used by relationships, rumors, situations, item origins, and consequence queries. A `ComedyMemory` is a speaker-accessible callback record with salience, expiration, repeat limits, and humor safety metadata.

A selected commentary definition may create a Comedy Memory that references an existing EventSummary. The two repositories share IDs and fact tags but do not copy complete records. Deleting an expired Comedy Memory does not erase the underlying world fact, and compressing a low-value EventSummary does not fabricate a callback.

## 12. Rumor model

A rumor is an authored proposition with truth and presentation separated:

```json
{
  "rumor_id": "rumor.gutterbloom.rain_order_invalid",
  "proposition_id": "fact.rain_treasurer.emergency_order_invalid",
  "truth_state": "true",
  "origin_event_id": "event.archive_order_discovered",
  "variants": {
    "accurate": "...",
    "partial": "...",
    "distorted": "..."
  },
  "allowed_distortions": ["missing_actor", "wrong_location"],
  "maximum_hops": 4,
  "share_tags": ["water_office", "dry_boot"],
  "discovery_routes": ["direct_document", "npc_report", "bar_rumor"]
}
```

Propagation rules:

1. Eligible co-present actors must share a topic and satisfy an authored share policy.
2. A deterministic roll may transfer the rumor once per relationship revision.
3. Confidence can stay stable or move to an authored lower band.
4. Distortion selects an authored variant or removes a noncritical detail tag.
5. Propagation stops at the maximum hop count.
6. A rumor never invents a quest target, accusation, or reward outside its authored variants.

The player's ledger distinguishes **confirmed fact**, **credible report**, **rumor**, and **contradicted claim**. Rumors can mislead gently, but target-farm sources, transaction costs, safety rules, and accessibility information never rely on uncertain text.

## 13. Query API

Required read-only queries include:

- `knowledge_for(actor_id, subject_id)`;
- `relationship_between(actor_a, actor_b)`;
- `rumor_holders(rumor_id, minimum_confidence)`;
- `rumor_provenance(rumor_id)`;
- `participants_for(situation_id)`;
- `situations_affecting(subject_id)`;
- `consequence_dependencies(subject_id)`;
- `eligible_callback_memories(query)`;
- `presence_for(place_id)`;
- `service_successors(actor_id)`;
- `known_path_to_fact(actor_id, proposition_id, max_hops)`.

Queries return bounded typed results. Gameplay code does not submit arbitrary graph query strings.

## 14. Persistence implementation gate

### Slice implementation

Use versioned Godot Resources or normalized JSON definitions plus compact save records and in-memory indexes:

- edge IDs by source actor;
- edge IDs by target subject;
- rumor holders by rumor ID;
- situations by participant;
- memories by fact tag and speaker access;
- schedule rules by dirty fact;
- transition rules by dirty fact.

### Scale gate

Before public alpha, benchmark the production target with at least:

- 1,000 named entity records across all test zones;
- 25,000 active typed edges;
- 10,000 durable event summaries;
- 2,000 rumors and historical situations;
- worst-case War Room and callback queries.

If profile files and in-memory indexes miss load, save, query, or migration budgets, move the same repository interface to a bundled local database. SQLite is the first candidate. Neo4j or a networked service requires a later measured need and explicit architecture decision.

## 15. Transaction and recovery rules

- A strategic tick reads one immutable prior snapshot.
- Every phase writes to an isolated delta proposal.
- Content-preservation and schema validation run before commit.
- The journal records seed, prior revision, new revision, causes, and fingerprint.
- Replaying a committed fingerprint is idempotent.
- A failed write preserves the prior snapshot.
- Save migration maintains node and edge IDs or supplies explicit replacements.
- Missing optional content creates tombstones and safe fallbacks.
- Debug tools can inspect and replay a delta without changing the active profile.

## 16. Content-preservation invariants

A proposed tick fails validation if it would:

- remove the only acquisition path for a discovered build-defining item;
- remove every essential settlement service;
- strand the Claimant behind a closed route;
- kill or permanently remove a named NPC offscreen;
- expire an accepted objective;
- worsen state due only to offline time;
- alter Spotlight or divine Recognition from wall-clock information;
- create more active situations than the zone budget;
- activate an unresolved content reference;
- exceed population, actor, relationship, or memory caps.

The validator reports the definition, prior state, proposed state, and failed invariant.

## 17. Debug tools

Required tools:

- zone-turn stepper with pause, single phase, and rewind-on-copy;
- dirty-fact viewer;
- named-NPC activity and presence map;
- relationship edge inspector with reason history;
- rumor provenance and distortion viewer;
- memory retention and callback eligibility viewer;
- situation participant and dependency viewer;
- state-delta diff and fingerprint report;
- fixed-seed batch simulator;
- offscreen-death and content-lockout audit.

## 18. Automated tests

### Determinism

- the same snapshot, event batch, content revision, and seed produce the same delta;
- changing presentation, subtitles, frame rate, or commentary frequency does not change simulation;
- replaying an already committed event batch produces no additional mutation;
- rule evaluation order does not depend on hash-map iteration.

### Scheduling and presence

- blocked activities choose declared fallbacks;
- no schedule reads the operating-system clock;
- an unloaded NPC never invokes navigation or combat simulation;
- presence slots never spawn duplicate unique NPCs;
- a missing activity definition falls back safely.

### Relationships and memory

- every delta is clamped, typed, logged, and attributable;
- rumor distortion uses only authored variants;
- maximum rumor hops terminate propagation;
- retention respects event distance and story state;
- commentary queries cannot access private or arbitrary external data;
- random romance, death, or betrayal cannot emerge from generic pairwise scoring.

### Persistence and scale

- interrupted commits preserve either the prior or complete new state;
- old fixtures migrate without orphaned important edges;
- benchmark queries meet the M34 budgets;
- memory and active-situation counts remain bounded during long simulation;
- every terminal named-NPC state retains required service and reward successors.

## 19. Vertical-slice scope

Gutterbloom implements:

- one zone snapshot with six strategic dimensions;
- eight named NPC records plus Picket and the Rain Treasurer;
- four presence locations;
- no more than 128 active relationship, knowledge, rumor, and participation edges;
- four authored rumors with accurate, partial, and distorted variants;
- six schedule definitions using in-game phases and state predicates;
- four situation records plus recovery states;
- one post-boss zone-turn transition;
- one delayed NPC callback sourced from an EventSummary;
- save, reload, migration fixture, and fixed-seed replay tests.

The slice does not simulate thousands of NPCs, deploy a graph database, advance the world while closed, generate free-form rumors, or permit offscreen named-NPC death.

## 20. Deferred decisions

- final strategic tick frequency while a zone is loaded;
- whether fictional day phases are global or zone-specific;
- maximum named entities and active edges per production zone;
- which low-significance memories become counters versus tombstones;
- whether the War Room needs multi-hop graph visualization;
- whether a bundled SQLite repository is justified before public alpha;
- whether future co-op requires any authoritative world-state service.
