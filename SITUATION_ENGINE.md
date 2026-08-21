# Situation Engine Specification

## 1. Purpose

The Situation Engine creates bounded, authored problems from living-zone state, relationships, rumors, and player actions. It does not generate plots from unrestricted prose and does not flood the map with emergencies.

A situation should answer four questions:

1. Why can this happen here now?
2. Who or what cares?
3. How can the player discover and influence it?
4. What remains playable if the player declines or never discovers it?

The engine creates opportunities for stories. Authored definitions provide the participants, valid outcomes, facts, dialogue hooks, rewards, and safety boundaries.

## 2. Product invariants

- No situation uses a real-world deadline.
- An accepted objective does not expire.
- Ignoring an unaccepted situation never reduces baseline loot, experience, Recognition, or vendor quality.
- A named NPC cannot die or permanently disappear from an offscreen automatic outcome.
- No situation permanently removes the only route to a build-defining reward or essential service.
- A crisis can change the world without punishing the player for closing the game.
- Situation frequency does not depend on global player counts, weekends, holidays, update weeks, or Spotlight rank.
- Spotlight may offer a separate voluntary complication after a situation exists. It cannot decide whether ordinary content appears.
- Random romance, coercion, betrayal, torture, or irreversible death is not synthesized from generic relationship values.
- A candidate may fail to instantiate. Silence and stability are valid outputs.

## 3. Situation lifecycle

```text
latent
  -> discoverable
  -> known
  -> accepted
  -> resolving
  -> resolved

Any unaccepted stage may become:
  -> dormant
  -> transformed
  -> autonomously resolved with content-preserving outcome

Any failed accepted resolution may become:
  -> recovery_available
  -> alternate_resolution
  -> resolved_with_consequence
```

### Latent

The state supports the situation, but no player-facing clue has been placed.

### Discoverable

At least one authored discovery route is active. The player may still know nothing about it.

### Known

The ledger records the situation with an information-quality band. No obligation has been accepted.

### Accepted

The player deliberately accepts an objective or enters an explicitly previewed incident. It remains available until completed, abandoned through a confirmation, or transformed by a directly observed choice.

### Dormant

The situation leaves the active budget but retains its state. A later trigger can reactivate or transform it. Dormancy never deletes an accepted objective.

### Recovery available

A failed attempt generates a clear next route, changed encounter, negotiation, payment, investigation, or future opportunity. Recovery may differ, but a unique build reward remains obtainable.

## 4. Situation definition

```json
{
  "situation_id": "situation.gutterbloom.invalid_rain_order",
  "schema_version": 1,
  "category": "civic_incident",
  "base_priority": 42,
  "scope": "zone",
  "requires_all_facts": [
    "boss.rain_treasurer.active",
    "rumor.rain_order_invalid.discoverable"
  ],
  "requires_any_facts": [],
  "excludes_facts": ["situation.invalid_rain_order.resolved"],
  "participant_roles": ["continuity_defector", "market_representative"],
  "location_roles": ["semi_safe_bar", "water_archive"],
  "active_budget_cost": 1,
  "cooldown_zone_turns": 3,
  "discovery_routes": [],
  "stages": [],
  "outcomes": [],
  "default_autonomous_transition": "become_dormant",
  "content_preservation_contract": [],
  "reward_contract": [],
  "memory_writes": [],
  "commentary_hooks": [],
  "test_fixture_ids": []
}
```

Definitions use immutable IDs, localization keys, controlled fact tags, typed roles, and registered outcome operations. They cannot execute arbitrary script strings.

## 5. Situation categories

| Category | Typical pressure | Player verbs | Safe autonomous behavior |
| --- | --- | --- | --- |
| Civic incident | service, policy, leadership, route access | investigate, mediate, support, expose | changes rumor or NPC activity, not essential access |
| Ecology shift | population, resource, hazard, migration | study, redirect, cultivate, cull | moves a pressure band within preserved bounds |
| Opportunity | vendor, cache, research, route, visitor | pursue, trade, explore, invite | becomes dormant or moves to another source |
| Rivalry | factions, named enemies, craftspeople, gods | compete, mediate, collaborate, observe | advances relationship texture only |
| Mystery | contradictory facts, secrets, missing source | inspect, compare, follow, reconstruct | adds a clue or remains latent |
| Celebration | settlement recovery, boss outcome, collection | participate, perform, help, decline | changes ambience and rotates back later |
| Threat | patrol, hazard, successor, hostile faction | fight, evade, fortify, negotiate | changes a reversible pressure or route variant |
| Recruitment | faction, resident, companion, specialist | evaluate, help, invite, refuse | candidate remains elsewhere or returns later |
| Divine proposal | covenant philosophy and zone choice | accept, decline, mediate, contradict | defers without Recognition loss |
| Lair petition | Temperament, mood, prior clear | comply, reinterpret, refuse, exploit | mood changes within equal reward budget |
| Recovery | failed event, missed clue, changed state | retry differently, pay, investigate, wait | remains targetable until resolved |

Romance and other intimate arcs may exist only as fully authored character content with specific participants and explicit player choice. They are not a generic situation category.

## 6. Active budgets

Provisional budgets:

| Scope | Active or known | Newly selected per strategic turn | Critical presentation cap |
| --- | ---: | ---: | ---: |
| Subregion | 2 | 1 | 1 |
| Zone | 6 | 0 to 2 | 1 |
| Cross-zone | 4 profile-wide | 0 to 1 | 1 profile-wide |
| Hearthfold | 3 | 0 to 1 | none during protected scenes |

Accepted situations do not consume the new-candidate quota, but do count toward UI presentation load. If the budget is full, candidates remain latent rather than replacing accepted content.

The engine must be willing to select zero situations. It does not target a fixed number per tick.

## 7. Candidate pipeline

```text
world or relationship facts become dirty
  -> retrieve definitions indexed by dirty facts
  -> hard-filter prerequisites and preservation contracts
  -> bind eligible participant and location roles
  -> reject duplicates, conflicts, and active-budget overflow
  -> calculate relevance score
  -> group by category and narrative load
  -> deterministic top-band selection
  -> instantiate stages, outcomes, clues, and audit fingerprint
  -> validate complete record
  -> journal and commit
```

Hard filters run before scoring. A situation on cooldown or missing a required participant cannot win because the remaining candidates are weak.

## 8. Hard eligibility filters

A candidate is rejected if:

- any required fact is absent or an excluded fact is present;
- a participant role has no eligible authored binding;
- the selected location is inaccessible in the proposed state;
- an active fingerprint represents the same definition, participants, and pressure;
- the definition or category has reached its active cap;
- its zone-turn cooldown is active;
- it conflicts with an accepted situation or sincerity hold;
- it would exceed current UI or critical-cue load;
- its autonomous path violates a content-preservation invariant;
- it requires a missing dialogue, encounter, reward, or recovery definition;
- it depends on wall-clock, online population, global build popularity, or private data;
- its only discovery route is unavailable;
- it would assign the same unique NPC to incompatible presence slots.

## 9. Relevance score

```text
score = base_priority
      + state_relevance
      + relationship_relevance
      + player_causality
      + unresolved_recovery_value
      + zone_identity_bonus
      + diversity_bonus
      + deterministic_variance
      - recent_category_saturation
      - participant_fatigue
      - presentation_load
```

Provisional ranges:

| Component | Range | Meaning |
| --- | ---: | --- |
| Base priority | 0 to 60 | authored importance |
| State relevance | 0 to 25 | number and specificity of meaningful dirty facts |
| Relationship relevance | 0 to 15 | authored relationship band supports the situation |
| Player causality | 0 to 20 | situation responds to a committed player action |
| Recovery value | 0 to 25 | restores a blocked or failed opportunity |
| Zone identity | 0 to 10 | demonstrates the zone's primary verb or ecology |
| Diversity | 0 to 12 | underused category, location, or participant |
| Deterministic variance | -3 to 3 | seed-derived tie texture, never dominant |
| Category saturation | 0 to 30 | recently repeated category |
| Participant fatigue | 0 to 25 | overused actor or faction |
| Presentation load | 0 to 30 | player already has several urgent known situations |

There are no viewership, Spotlight, difficulty, death-count, player-population, weekend, holiday, or post-update modifiers.

## 10. Deterministic selection

Candidates are sorted by score, authored priority, stable content ID, and bound participant IDs. The engine forms a top band within a configurable margin of the highest score, then uses a named deterministic random stream to select from that band.

The seed derives from:

- profile world seed;
- zone state revision;
- strategic turn sequence;
- candidate category;
- content revision.

Reloading the prior snapshot produces the same candidate and does not create duplicate rewards or clues.

## 11. Participant binding

Situation definitions request semantic roles, not hardcoded source names when reuse is intended.

Example roles:

- `market_representative`;
- `ecology_delegate`;
- `continuity_defector`;
- `bar_proprietor`;
- `anchor_specialist`;
- `rival_crafter`;
- `promoted_enemy`;
- `divine_envoy`.

An NPC definition declares roles it can play, exclusions, stage limits, relationship prerequisites, and required presence. Binding ranks eligible actors by specificity, unresolved goals, novelty, and authored preference. It cannot assign a character to a role that contradicts their voice charter or protected state.

Critical character arcs use explicit participant IDs instead of generic binding.

## 12. Situation record

```json
{
  "record_id": "situation_record.01J...",
  "definition_id": "situation.gutterbloom.invalid_rain_order",
  "content_revision": 4,
  "state": "discoverable",
  "stage_id": "stage.documents_misfiled",
  "created_world_sequence": 8830,
  "last_changed_world_sequence": 8830,
  "zone_turns_in_stage": 0,
  "participant_bindings": {
    "continuity_defector": "npc.gutterbloom.scrip_nine",
    "market_representative": "npc.gutterbloom.dava_fen"
  },
  "location_bindings": {
    "meeting": "place.dry_boot"
  },
  "discovered_fact_ids": [],
  "accepted_objective_ids": [],
  "available_outcome_ids": [],
  "reward_ledger_ids": [],
  "fingerprint": "...",
  "seed": 184221
}
```

The record stores IDs and resolved facts, not mutable prose.

## 13. Discovery routes

Each situation declares at least two discovery routes where production scope allows:

| Route | Information quality | Typical requirement |
| --- | --- | --- |
| Direct witness | confirmed or strong | enter active location |
| Named NPC report | confidence depends on knowledge edge | trust, shared goal, or direct question |
| Bar rumor | rumor or credible report | visit semi-safe social space |
| Environmental clue | partial | inspect place, trail, object, or ecology state |
| Document or item origin | confirmed or partial | find and inspect authored object |
| Picket analysis | exact mechanical fact | carry relevant protocol or scan clue |
| War Room forecast | state probability, not private secret | build room and earn zone knowledge |
| Herald announcement | public event only | announcement channel eligibility |
| Divine proposal | philosophically biased | discovered god and authored event |

The ledger labels information as confirmed, credible, rumor, disputed, or unknown. It never presents a probabilistic accusation as certain.

## 14. Stage advancement

Stages advance through:

- a committed player action;
- an accepted objective result;
- a specific zone-state transition;
- an authored relationship threshold;
- an explicit rest or travel advancement;
- a bounded number of zone turns while the situation remains unaccepted.

An unaccepted situation may autonomously:

- reveal an additional clue;
- move to a different valid location;
- change participant activity states;
- enter dormancy;
- transform into another authored situation;
- resolve into a content-preserving ambient state.

It cannot autonomously kill a named NPC, remove a unique reward, destroy a settlement, close every route, reduce player-owned progress, or punish offline absence.

Accepted objectives stop autonomous stage progression unless their definition explicitly contains a directly observed, player-triggered sequence.

## 15. Outcome contracts

Each outcome declares:

- exact requirements;
- known consequences shown before commitment;
- uncertain consequences labeled as such;
- relationship and state deltas;
- encounter or dialogue scene;
- reward lane and duplicate behavior;
- memories and rumors created;
- preserved routes, services, and sources;
- recovery path after failure;
- successor actors or services after irreversible change;
- commentary and settlement response hooks.

Unknown consequences are authored mysteries, not hidden punishment math. Transaction costs and item loss are always exact.

## 16. Failure and recovery

Failure may produce:

- a changed encounter;
- a named enemy promotion;
- a faction or NPC disagreement;
- a replacement contact;
- a different investigation route;
- an alternate payment or service;
- a later recovery situation;
- a living-zone state that changes convenience but preserves access;
- a Comedy Memory and bar callback;
- smaller bonus rewards while keeping published baseline rewards.

Failure cannot remove owned gear, banked Spotlight, Recognition, Hearthfold rooms, discovered anchors, essential services, or the only source of a curated law.

## 17. Situation matrix authoring

Rather than one global matrix, each zone provides a small authored modifier table aligned with its identity.

Example Gutterbloom state modifiers:

| State fact | Civic | Ecology | Opportunity | Rivalry | Mystery | Celebration | Threat | Recovery |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Water high | +8 | +10 | +2 | +2 | +5 | -4 | +8 | +4 |
| Water lowered | +3 | +8 | +10 | +4 | +4 | +8 | +3 | +6 |
| Tollmold pressure high | +6 | +12 | +4 | +5 | +3 | -2 | +7 | +5 |
| Latchmarket strained | +10 | +3 | +6 | +8 | +3 | -5 | +6 | +8 |
| Boss successor forming | +4 | +5 | +3 | +10 | +8 | 0 | +10 | +5 |

These values add to relevance and remain secondary to hard eligibility. A recently used category receives its separate category-saturation penalty. They do not multiply into runaway probabilities.

## 18. Gutterbloom initial situation set

1. **The Invalid Rain Order:** Scrip Nine and Dava disagree over whether a surviving administrative fragment can change the Treasurer's mandate.
2. **Tollmold Right of Way:** Registrar Loam requests recognition of a fungal crossing that conflicts with a roof-market route.
3. **A Dry Boot for the Road:** the bar has one genuinely dry boot and several groups claim it as a civic symbol, practical tool, or appetizer.
4. **Anchor Under Warranty:** Quoin Rusk discovers that a Hearthfold anchor repair used a material that technically belongs to the Courtesy Drain.
5. **Courier Below the Roofline:** Skip Nall finds a low-water delivery path and needs evidence that it will remain navigable.
6. **The Root That Filed Back:** Mara Venn's experimental bridge begins producing its own maintenance notices.
7. **Three Cups, Four Owners:** Three-Cups receives a Cache whose origin ledger names mutually incompatible prior owners.
8. **Due Notice:** the recurring Sump Knight begins questioning whether a valid warning requires an available recipient.
9. **After the Treasurer:** the Cooperative, Tollmold Registry, and former clerks propose different uses for the lowered water.
10. **The Drink Named After You:** a promoted-enemy incident becomes bar gossip and a small recovery or celebration thread.

The vertical slice implements four. The remaining six belong to Gutterbloom production expansion.

## 19. Commentary integration

The Situation Engine emits typed lifecycle events. It does not enqueue dialogue directly.

Examples:

- `situation.became_discoverable`;
- `situation.discovered`;
- `situation.accepted`;
- `situation.stage_changed`;
- `situation.failed_with_recovery`;
- `situation.resolved`;
- `situation.transformed`;
- `rumor.situation_variant_shared`.

The Commentary Director applies its own hard filters, settings, silence budget, and sincerity holds. A critical situation warning uses the Critical channel only when the player is already in direct danger. Latent offscreen events do not interrupt combat.

## 20. Debugging and authoring tools

- candidate list with every eligibility rejection reason;
- score breakdown and deterministic seed;
- participant and location binding inspector;
- active budget and presentation-load view;
- fingerprint and duplicate report;
- stage graph viewer;
- consequence and preservation contract audit;
- discovery-route simulator;
- fixed-seed batch generation report;
- long-run category, actor, and location saturation report;
- recovery-path reachability checker;
- situation-to-commentary event injector.

## 21. Automated tests

### Definition validation

- unknown facts, roles, locations, stages, outcomes, rewards, or memories fail;
- every definition has a discovery route, autonomous behavior, and terminal state;
- accepted states cannot have an unobserved expiration transition;
- every failure state reaches recovery or a preserved alternate source;
- irreversible NPC changes declare service and reward successors;
- intimate or irreversible generic categories fail validation;
- circular stage graphs without a bounded repeat count fail.

### Candidate selection

- hard-filtered definitions never appear in the scored set;
- active caps and category cooldowns hold;
- the same snapshot and seed choose the same candidate;
- zero candidates is permitted;
- one actor cannot bind to incompatible simultaneous roles;
- no real-world or online-population input enters scoring;
- Spotlight rank does not alter ordinary candidate eligibility or score.

### Outcome safety

- ignored unaccepted situations cannot kill named NPCs or remove essential content;
- accepted objectives survive arbitrary save, close, and reload intervals;
- every published target reward remains reachable after every terminal outcome;
- failure does not remove owned items or permanent progression;
- reward grants and state mutations are idempotent;
- rumor and commentary output matches the committed outcome.

### Long-run simulation

- category and participant fatigue prevent monotonous repetition;
- active and historical record counts remain bounded;
- no location accumulates incompatible situations;
- recovery situations receive priority without starving ordinary opportunities;
- 10,000 fixed-seed zone turns produce no offscreen named-NPC death or content lockout.

## 22. Milestone scope

### Vertical slice

- four situation definitions;
- two categories plus one recovery variant;
- four discovery methods;
- eight named-participant role bindings;
- exact score and rejection inspector;
- one failed event recovery;
- one post-boss transformed situation;
- save/load and deterministic replay.

### Public alpha

- at least 20 situations across Gutterbloom and Brass Orchard;
- eight categories;
- relationship and rumor discovery;
- War Room forecast integration;
- cross-zone visitor and consequence candidates;
- saturation and long-run simulations;
- complete accessibility and notification settings.

## 23. Deferred decisions

- exact active budgets after slice playtests;
- whether dormant known situations remain on the main ledger or an archive tab;
- how much uncertainty outcome previews should expose;
- whether cross-zone situations can bind more than three named actors;
- whether a future co-op mode shares or duplicates situation state;
- final public-alpha count after measured authoring velocity.
