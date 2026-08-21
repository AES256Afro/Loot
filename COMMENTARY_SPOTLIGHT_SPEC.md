# Commentary and Spotlight Technical Specification

## 1. Purpose

This specification converts the Herald, Picket, callback, and Spotlight concepts into implementable local-first rules. It replaces the supplied deep dive's server services, punitive ratings decay, negative scoring, global-player comparisons, and real-time retention with deterministic game events, hard safety filters, typed memories, positive-only Spotlight scoring, and explicit test contracts.

The core invariant is:

> Commentary may observe ordinary play. Spotlight may reward unusual play. Neither may make ordinary play worse.

## 2. System boundaries

The commentary system may:

- read typed gameplay events;
- query compact game-defined Comedy Memories;
- enqueue authored lines or grammar-constrained templates;
- update line play counts and topic saturation;
- create new Comedy Memories declared by the selected line;
- request presentation through subtitles, recorded audio, UI, environmental text, or a protected setpiece;
- request a nonauthoritative cosmetic flourish.

It may not:

- decide loot, damage, AI behavior, objective completion, divine Recognition, or permanent progression;
- inspect microphone audio, free-form chat, files, contacts, account history, or external activity;
- call a remote language model;
- execute arbitrary content strings as code;
- fabricate game facts that are absent from the event or an eligible memory;
- speak over a higher-priority combat, accessibility, or navigation cue.

The Spotlight system may award separate bonus ledgers and optional incidents. It may not modify baseline drop tables, vendor prices, ordinary Recognition, experience, target protection, or story access.

## 3. Canonical gameplay event

Every noteworthy system emits a compact immutable event. Events use monotonic game sequence and game time, not wall-clock timestamps.

```json
{
  "event_sequence": 1842,
  "event_type": "combat.enemy_defeated",
  "game_time_ms": 921553,
  "session_nonce": 4,
  "causation_id": "attack.riftblade.seam_rake.441",
  "chain_id": "combat_chain.88",
  "source_actor_id": "player.local",
  "target_actor_ids": ["enemy.knuckle_newt.17"],
  "zone_id": "zone.gutterbloom",
  "subregion_id": "gutterbloom.floodgate_commons",
  "tags": [
    "damage.edge",
    "enemy.family.knuckle_newt",
    "kill.environment_assisted",
    "power.seam_rake",
    "spotlight.eligible"
  ],
  "metrics": {
    "player_vitality_fraction": 0.31,
    "targets_in_chain": 2,
    "environment_damage_fraction": 0.44,
    "repeat_count_recent": 0
  },
  "content_revision": 12
}
```

### Required event rules

- `event_sequence` increases exactly once per authoritative event.
- Tags are sorted and deduplicated before publication.
- Metrics use documented names, units, and legal ranges.
- Content IDs are immutable and namespaced.
- `chain_id` prevents the same underlying action from being scored several times through derived events.
- Events contain no localized prose.
- Events needed for save recovery or deterministic rewards are journaled before presentation.
- High-frequency events may be aggregated before commentary evaluation, but raw combat rules still receive them normally.

## 4. Initial event registry

| Event family | Example events | Commentary use | Spotlight use |
| --- | --- | --- | --- |
| Combat | hit, perfect dodge, Guard break, status threshold, enemy defeat | unusual tactics, warnings, streaks | selected authored combinations only |
| Defeat | player defeated, remnant created, remnant recovered | Indignity, callback, promotion | partial unbanked progress only |
| Loot | item granted, first base, legendary, duplicate, reconstructed | appraisal, rare announcement, item history | rare-discovery and unusual-law events |
| Build | equipment changed, loadout activated, power combo discovered | specific observations | first successful build-law combinations |
| World | zone entered, route changed, ecology threshold, successor created | announcements and callbacks | meaningful discovery and state intervention |
| Lair | entered, mood changed, Memory Rank increased, cleared | temperament voice | deliberate mood manipulation and complication |
| Boss | discovered, phase changed, defeated, Echo Hunt complete | critical and setpiece channels | clear, comeback, optional complication |
| Hearthfold | room upgraded, Reclamation completed, visitor arrived | home reactions | first major room discoveries only |
| Social | bar incident, rumor verified, faction state changed | local comedy and callbacks | authored public incidents only |
| Divine | contact, offer, covenant, intervention, tension challenge | god and Herald conflict | voluntary divine complications |
| Picket | warning issued, followed, ignored, protocol changed, Trust changed | companion memory and duets | rare exact events only |
| Settings | humor preset changed, voice muted | no reaction | never scored |

`combat.hit` is too frequent to produce ordinary lines directly. The commentary evaluator consumes summaries such as `combat.sequence_resolved` unless a rare exact rule requires the individual hit.

## 5. Commentary definition schema

```json
{
  "line_id": "herald.gutterbloom.newt_promoted.01",
  "schema_version": 1,
  "speaker_id": "speaker.herald",
  "delivery": "voiced_or_text",
  "channel": "announcement",
  "localization_key": "commentary.herald.gutterbloom.newt_promoted.01",
  "audio_resource_id": null,
  "base_priority": 72,
  "tone_tags": ["ceremonial", "dry", "promotion"],
  "requires_all_tags": ["enemy.promoted", "enemy.family.knuckle_newt"],
  "requires_any_tags": [],
  "excludes_tags": ["scene.sincere", "combat.critical_cue_active"],
  "required_memory_query": null,
  "allowed_safety_states": ["safe", "semi_safe", "contested", "hostile"],
  "minimum_quiet_ms": 12000,
  "line_cooldown_game_ms": 3600000,
  "topic_id": "topic.enemy_promotion",
  "topic_cooldown_game_ms": 300000,
  "max_plays_per_session": 1,
  "max_plays_per_profile": 3,
  "callback_consume_policy": "none",
  "creates_memory_type": "enemy.promotion_announced",
  "interrupt_policy": "ambient_only",
  "sincerity_policy": "defer",
  "template_id": null
}
```

### Definition invariants

- Critical facts use complete authored lines, not procedural templates.
- A line with an audio resource also has subtitle text.
- A topic ID is mandatory for all noncritical lines.
- `max_plays_per_profile` may be unlimited only for safely repeatable system facts.
- A line cannot create a memory from facts it did not receive.
- Delivery duration and subtitle reading time are validated against the quiet budget.
- Profile caps and cooldowns are hard filters. They are not small score penalties.

## 6. Candidate selection pipeline

### Stage A: event eligibility

Discard events whose registry entry does not allow commentary or whose aggregate has already been consumed by the current evaluator pass.

### Stage B: hard filters

Reject a candidate when any of the following is true:

- a required tag is absent;
- none of the required-any tags are present;
- an excluded tag is present;
- the line, topic, or speaker cooldown is active;
- session or profile play cap is reached;
- the required Comedy Memory is absent, ineligible, expired, protected, or already consumed;
- the current safety state is not allowed;
- a sincerity hold forbids the tone;
- the interrupt policy cannot displace the active channel;
- the speaker is muted and the line lacks a required nonvoice presentation fallback;
- localization, audio, or template validation failed at load time.

### Stage C: score candidates

```text
score = base_priority
      + specificity_bonus
      + event_novelty_bonus
      + callback_salience_bonus
      + first_occurrence_bonus
      + story_relevance_bonus
      - topic_saturation_penalty
      - speaker_saturation_penalty
      - interruption_cost
```

Initial ranges:

- `base_priority`: 0 to 100;
- specificity: 0 to 20, based on matched meaningful tags rather than event tag count;
- event novelty: 0 to 15 from the event registry;
- callback salience: 0 to 15;
- first occurrence: 0 or 8;
- story relevance: 0 to 10;
- topic saturation: 0 to 40;
- speaker saturation: 0 to 25;
- interruption cost: 0 to 100.

Scores below the channel threshold are discarded. Silence is a valid and often preferred result.

### Stage D: choose within the top band

For Critical lines, select the highest score and stable ID tiebreak. For other channels:

1. find the maximum score;
2. keep candidates within eight points of the maximum;
3. apply a small deterministic weight from score and unused lifetime count;
4. select using the commentary random stream seeded by profile, event sequence, and topic cycle;
5. record the decision before playback.

This prevents the same highest-scoring line from playing every time while keeping selection reproducible for tests.

### Stage E: enqueue or discard

An observation has a maximum useful age. If it cannot play before that age, discard it. A joke about a perfect dodge does not wait until the next town.

## 7. Channel and interruption matrix

| Channel | Examples | May interrupt | May be interrupted by |
| --- | --- | --- | --- |
| Critical | boss phase, evacuation, accessibility cue | every commentary channel | another Critical line with greater urgency |
| System | save recovery, inventory overflow, objective rule | Commentary, Ambient | Critical |
| Announcement | legendary, promotion, zone change, divine arrival | Commentary, Ambient | Critical, urgent System |
| Dialogue | Picket, NPC, god, lair exchange | Ambient | Critical, urgent System; otherwise pauses and resumes only if still relevant |
| Commentary | Herald observation, Indignity callback | Ambient | every higher channel |
| Ambient | broadcasts, environmental text, bar texture | nothing | every other channel |

The same critical fact cannot be voiced simultaneously by the Herald, Picket, UI, and tutorial. The cue coordinator selects one lead presentation and supporting noncompeting indicators.

## 8. Comedy Memory schema

```json
{
  "memory_id": "memory.000184",
  "memory_type": "picket.warning_ignored",
  "created_game_time_ms": 702112,
  "created_event_sequence": 1411,
  "salience": 68,
  "source_content_ids": [
    "picket.warning.root_bridge",
    "hazard.gutterbloom.root_bridge"
  ],
  "fact_fields": {
    "warning_id": "picket.warning.root_bridge",
    "outcome": "player_fell",
    "repeat_count": 1
  },
  "eligible_speakers": ["speaker.picket", "speaker.herald"],
  "eligible_tones": ["dry", "concerned", "callback"],
  "earliest_callback_event_distance": 10,
  "expire_after_event_distance": 5000,
  "maximum_uses": 2,
  "uses": 0,
  "protected_sincere": false,
  "gameplay_effect_allowed": false
}
```

### Retention rules

- Event distance and salience control ordinary retention, not real-world days.
- Repeated similar memories merge into a summary with count and most recent context.
- Important firsts, promoted enemies, major zone changes, covenant decisions, and player-pinned memories may persist across the profile.
- Sincere memories declare which tones and speakers may reference them.
- A callback use reduces salience unless the line deliberately advances the memory.
- Memory compaction runs during save maintenance and is deterministic.
- The profile exposes a history page where major persistent memories can be viewed and selected harmless memories can be hidden from future comedy.

## 9. Template grammar

Procedural fallback uses authored clause slots with semantic and grammar metadata.

```json
{
  "template_id": "herald.defeat.environment.01",
  "speaker_id": "speaker.herald",
  "event_type": "player.defeated",
  "pattern_key": "template.herald.defeat.environment.01",
  "required_slots": ["subject", "incident", "judgment"],
  "optional_slots": ["method", "callback"],
  "tone_tags": ["dry", "ceremonial"],
  "minimum_priority": 34,
  "maximum_lifetime_uses": 5
}
```

Fragments declare:

- grammatical number, gender behavior where relevant, case, and tense;
- whether they form a complete clause;
- required and forbidden event tags;
- speaker knowledge and tone;
- safe joke targets;
- neighboring slot compatibility;
- localization-specific ordering;
- lifetime and topic caps.

The system does not insert a player name, enemy, item, place, or callback unless that value is available as a localization-safe content reference. It never splices arbitrary user text.

## 10. Multi-speaker exchanges

An exchange is an authored state machine, not two independent lines that happen to collide.

```text
Exchange offer
  -> verify both speakers available
  -> reserve dialogue channel
  -> play setup
  -> recheck combat and relevance
      -> play response
      -> defer response briefly
      -> cancel exchange
  -> apply one exchange cooldown
```

If interrupted after the setup, the response plays only if its context remains true and the delay stays within its declared limit. A canceled exchange does not count as fully played for lifetime caps, but it does receive a short retry cooldown.

Picket hazard warnings are not banter and do not consume the companion comedy budget.

## 11. Spotlight state

Spotlight is stored per active expedition:

```json
{
  "score": 46,
  "rank": "featured",
  "banked_rank_floor": 40,
  "active_progress": 6,
  "scored_event_families": {
    "environment_combo": 2,
    "secret_discovery": 1,
    "elite_mutation": 1
  },
  "recent_signature_hashes": [
    "environment_combo:water_jet:knuckle_newt",
    "status_chain:brittle:impact_break"
  ],
  "accepted_complications": [],
  "reward_ledger": [
    "spotlight.reward.noticed.01",
    "spotlight.reward.featured.01"
  ]
}
```

### Five ranks

| Rank | Score | Meaning | Separate bonus, never baseline modification |
| --- | ---: | --- | --- |
| Warm-Up | 0-19 | ordinary expedition play | none; all published ordinary rewards remain active |
| Noticed | 20-39 | the Herald starts following the run | choice of bonus materials or Cache progress |
| Featured | 40-59 | the expedition receives a segment | one extra end-of-expedition item-category roll |
| Headline | 60-79 | unusual incidents become more likely | Herald Cache plus one optional complication offer |
| Impossible to Ignore | 80-100 | peak voluntary spectacle | cosmetic broadcast token and one additional bonus choice |

Rank rewards are banked when the threshold is crossed. They cannot be lost through ordinary death, travel, save/load, or leaving the game. Score above the last completed threshold is active progress toward the next rank.

## 12. Positive-only Spotlight scoring

```text
awarded_points = base_points
               * novelty_factor
               * explicit_risk_factor
               * execution_factor
```

- `novelty_factor`: 1.0 for the first recent signature, 0.4 for the second, 0.1 for the third, then 0.0 until the history window moves. It is never negative.
- `explicit_risk_factor`: 1.0 to 1.5 only for a complication the player explicitly accepted or a naturally dangerous state. It never reads difficulty assists or accessibility settings.
- `execution_factor`: 1.0 to 1.25 for an authored skill condition such as a correct counter or deliberate environment chain. It does not compare the player against a global population.
- final points are rounded down and limited by the event-family expedition cap.

### Initial event matrix

| Event | Base points | Family cap | Notes |
| --- | ---: | ---: | --- |
| Discover a meaningful secret | 4 | 16 | each secret once per profile state |
| Trigger a new environmental combat interaction | 3 | 15 | signature includes environment and target family |
| Complete a three-system law or status chain | 3 | 15 | validated authored combinations only |
| Exploit a newly learned enemy break condition | 2 | 12 | first recent uses only |
| Defeat an elite mutation for the first time this expedition | 4 | 16 | mutation-family signature |
| Resolve a promoted enemy incident | 7 | 14 | once per incident |
| Deliberately change a lair mood and clear its response | 5 | 15 | once per mood cycle |
| Complete an optional broadcast complication | 8 | 24 | previewed and accepted |
| Recover an Embarrassment Remnant through a changed tactic | 4 | 8 | recovery method must differ from defeat signature |
| Defeat a boss | 10 | 20 | each distinct boss or Echo contract once per expedition |
| Complete a comeback after repeated attempts | 5 | 10 | never reduces the normal boss award |
| Earn a nonrepeatable Accolade | 5 | 20 | only Accolades tagged Spotlight-eligible |
| Cause a meaningful zone-state transition | 6 | 18 | once per state revision |

Normal kills, item pickups, time played, distance traveled, menus, damage taken, and deaths do not generate points by themselves.

## 13. Death and Embarrassment Remnants

By default, crossing a rank threshold banks that rank's reward. On defeat:

1. completed rank rewards remain banked;
2. active progress above the last threshold becomes an Embarrassment Remnant;
3. the remnant spawns at a safe reachable location near the defeat, never inside an active boss arena;
4. recovering it restores all active progress;
5. ignoring it converts half of the progress into bonus Cache progress at the next anchor;
6. no equipment, baseline currency, target-farm protection, experience, or permanent progression is involved.

An explicit `Do It Live` complication may risk one completed rank reward in return for a clearly previewed extra boss choice. It is never preselected and is not part of normal death.

## 14. Anti-exploit rules

- Causally linked events share one `chain_id` and one scoring budget.
- Reloading reproduces prior grants and cannot grant them twice.
- Self-created harmless damage does not qualify for near-danger conditions.
- Repeated spawned targets with no reward budget cannot generate Spotlight.
- A build is never labeled meta, boring, joke, bad, or suboptimal from global-player statistics.
- Removing armor or lowering damage has no generic multiplier.
- Event-family caps are data-defined and logged.
- A debug inspector explains every awarded or rejected point event.
- The scoring system has no negative point path.

## 15. Persistence and migrations

Save:

- current Spotlight state and reward ledger;
- scored signature summaries needed to prevent reload farming;
- line, topic, and speaker play histories;
- persistent Comedy Memories;
- active exchanges and whether they may resume;
- commentary settings and transcript references;
- content revision used to select each persistent callback.

On content removal, a migration converts missing line IDs into tombstones that preserve caps without breaking the profile. Missing optional audio falls back to subtitle text. Missing callback content expires safely without fabricating a replacement.

## 16. Performance budgets

For the vertical slice on the minimum development target:

- event publication adds less than 0.1 ms to the emitting gameplay system;
- candidate indexing avoids scanning the whole line catalog;
- an ordinary commentary evaluation completes below 2 ms at the 99th percentile with 1,000 loaded definitions;
- a synthetic storm of 10,000 events completes without unbounded queue or memory growth;
- the queue contains at most one active and four pending noncritical observations;
- transcript history is paged and capped separately from persistent Comedy Memories;
- selection remains deterministic in headless tests.

These are provisional budgets and become claims only after measurement on named hardware.

## 17. Required automated tests

### Event and content validation

- missing required tags;
- duplicate event sequences;
- unknown metric name or illegal range;
- duplicate line IDs;
- invalid speaker, topic, localization, audio, or memory reference;
- critical line using a procedural template;
- line with impossible safety or interruption policy;
- grammar fragment without a valid localization path.

### Selection

- active cooldown rejects rather than merely penalizes;
- session and profile caps reject;
- specificity compares meaningful matched requirements;
- callbacks require an eligible memory;
- Critical beats every lower channel;
- top-band selection is deterministic across repeated test runs;
- silence occurs when no line clears threshold;
- stale observations disappear rather than playing late.

### Memory

- similar memories merge deterministically;
- event-distance expiration works across save/load;
- protected sincere memory rejects hostile tones;
- callback use changes salience and respects maximum uses;
- hidden player memories remain unavailable to comedy queries.

### Spotlight

- every score path is nonnegative;
- repeated signatures decay to zero and never below;
- accessibility and commentary settings cannot change points;
- baseline reward fixtures are identical at every Spotlight rank;
- rank rewards bank once;
- death moves only active progress into a remnant;
- ignored remnant converts exactly once;
- reload cannot duplicate a complication or rank reward;
- `Do It Live` is never active without explicit input.

### Integration

- promoted enemy event to announcement to memory to delayed bar callback;
- Picket warning to ignored outcome to protected delayed response;
- boss phase Critical cue suppresses an eligible joke;
- legendary reward Announcement defers an ambient lair line;
- sincere zone victory holds ordinary comedy until released;
- commentary-muted play preserves visual warnings and all Spotlight rewards.
