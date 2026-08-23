# Milestone Roadmap

## How to use this roadmap

- Milestones are dependency ordered. Do not multiply content before its supporting systems and validation pass.
- A milestone is complete only when its acceptance criteria pass in a runnable build and the relevant documents are updated.
- Planning documents are not implementation progress. [IMPLEMENTATION_STATUS.md](IMPLEMENTATION_STATUS.md) is the evidence ledger; M00 and M01 are currently in progress and later milestones remain unstarted.
- Balance values and content counts may change through evidence, but the anti-frustration constitution in `PRODUCT_VISION.md` is a product contract.
- Each release gate records tested build ID, engine version, platform, hardware, automated results, playtest findings, known issues, save compatibility, and measured performance.
- Punishments listed as excluded in `DECISIONS.md` do not enter a milestone through balancing or polish. A voluntary challenge experiment requires a separate approved gate after M24.
- Each release gate reviews `RISK_REGISTER.md` and records changed evidence rather than silently lowering risk ratings.

## Release ladder

| Gate | Milestones | Player-visible outcome |
| --- | --- | --- |
| Foundation Gate | M00-M04 | A pinned, testable Godot project with a procedural first-person dungeon, four-person planning combat, and an early Herald, Picket, Spotlight, and callback risk spike. |
| Combat Gate | M05-M10 | One polished build can fight three enemy families, elites, and a boss. |
| Loot/Persistence Gate | M11-M17 | Drops, Caches, Archive, equipment, crafting, save/load, and recovery form a durable loop. |
| Vertical Slice | M18-M24 | A repeatable 20-to-30-minute expedition with settlement, bar, Hearthfold, commentary, living state, and boss aftermath. |
| Public Alpha | M25-M35 | Two content-rich zones, four Disciplines, full product systems, accessibility, and stress-tested persistence. |
| Early Access Candidate | M36-M40 | Six polished zones, long-tail progression, release operations, and enough breadth for sustained play. |
| 1.0 | M41-M46 | Eight zones, 12 Disciplines, complete offline game, content targets, compatibility, and release hardening. |
| Conditional Horizon | M47-M50 | Evidence-gated co-op, mod support, post-launch zones, and community systems. |

# Phase 0: Foundation

## M00 - Product lock and engine spike

**Depends on:** planning review.

Build a disposable technical spike in the current stable Godot 4 release. Test first-person dungeon movement, low-resolution pixel presentation, one stopped-time party combat, three enemy definitions, one environmental interaction, deterministic loot, and one atomic save. The approved replacement contract is in `PIVOT_FIRST_PERSON_CRAWLER.md`.

**Acceptance criteria**

- The user confirms first-person camera direction, stopped-time choice combat, shaded lo-fi pixel production, and solo-first implementation.
- Engine version and renderer are pinned and documented.
- The spike runs on the development Mac and one representative Windows target or a documented substitute.
- Dungeon movement, command planning, deterministic resolution, content loading, reward granting, and save writing work in an exported build.
- A written decision records observed risks instead of relying on general engine preference.
- `RISK_REGISTER.md` is updated with evidence from the spike and names any product promise threatened by the engine choice.

## M01 - Repository, project, and quality harness

**Depends on:** M00.

Create the real Godot project, Git repository, ignore rules, directory layout, command-line validation entry points, test harness, formatting conventions, and developer setup instructions.

**Acceptance criteria**

- A fresh clone can open and run with exact setup steps.
- One command runs content validation and automated tests headlessly.
- One command exports a local development build.
- Continuous integration runs validation, tests, and at least one export.
- The project has no unlicensed placeholder content committed without source and usage notes.

## M02 - Content registry, event stream, and humor risk spike

**Depends on:** M01.

Implement immutable content IDs, typed definitions, controlled tags, reference validation, localization keys, the runtime registry, and the central gameplay EventStream. Use the canonical schemas and candidate pipeline in `COMMENTARY_SPOTLIGHT_SPEC.md`. Use synthetic events to prototype Spotlight, Herald observations, Picket responses, one callback, and an enemy promotion before broad game systems exist.

**Acceptance criteria**

- Duplicate IDs, missing references, invalid tags, illegal numeric ranges, and orphaned localization keys fail validation.
- Definitions can be loaded in editor, headless test, and exported builds.
- Gameplay events carry typed payloads and can be recorded for debugging.
- Presentation can subscribe without deciding permanent rewards or progression.
- The risk spike includes at least 20 Herald observations, 12 Picket observations, six exchanges, six callback cases, six Accolades or Indignities, and one promoted-enemy sequence using temporary text presentation.
- A simulated 15-minute event stream produces a timing, repetition, topic-backoff, and interruption report.
- Spotlight rewards novelty but repeating one trigger cannot farm it or reduce baseline rewards.
- Hard filters reject ineligible commentary before scoring, and a fixed event sequence produces the same winning definition.
- The spike meets the commentary-definition count, performance, memory-retention, and selection tests in `COMMENTARY_SPOTLIGHT_SPEC.md`.

## M03 - Dungeon stepper, first-person camera, and input

**Depends on:** M01.

Implement deterministic cardinal movement, animated and instant step options, left and right turning, backward movement, room interaction, first-person field-of-view settings, motion reduction, input rebinding, controller glyph switching, and command-menu navigation.

**Acceptance criteria**

- The full six-room route is completable with controller only and keyboard/mouse only.
- Step animation, instant movement, field of view, turn animation, screen shake, and motion-reduction settings persist.
- Invalid moves provide readable feedback without changing position or consuming resources.
- Movement cannot enter a nonexistent connection, bypass an uncleared encounter, or desynchronize the saved room and facing.
- Input prompts update correctly after rebinding.

## M04 - Procedural Gutterbloom crawler graybox

**Depends on:** M02, M03.

Build the first deterministic procedural dungeon grammar: Intake, Fungus Nursery, Pressure Junction, Flooded Cistern, Promoted Office, and Hearthfold Anchor. Preserve authored encounter order while varying connected topology by seed.

**Acceptance criteria**

- Six unique connected rooms generate from a seed and reproduce identically for the same seed.
- Room roles, encounter sources, environmental interaction, and Hearthfold destination remain valid across generated topologies.
- Cardinal connections, room entry, encounter locks, and anchor transitions pass automated reference checks.
- The complete route is stable in an exported build and can start a new seed without restarting the application.
- The Pressure Junction demonstrates one optional environment-to-combat consequence without reducing baseline rewards if ignored.

## Gate A - Foundation review

Do not begin content multiplication until M00-M04 are complete. Record control feel, target hardware baseline, export size, frame-time capture, unresolved engine risks, and whether the Herald/Picket/Spotlight prototype creates a memorable 15-minute story without repetitive chatter.

# Phase 1: Combat proof

## M05 - Combat resources and damage pipeline

**Depends on:** M02, M03.

Expand the prototype resolver into the production round pipeline: visible intentions, action priority, targeting laws, Vitality, Guard, Focus, Strain, physical and energetic damage, status buildup, resistances, weak points, defeat events, and modifier traces.

**Acceptance criteria**

- Pipeline ordering is documented and covered by unit tests.
- Every damage result can explain base, additive, multiplicative, conversion, resistance, cap, and final values.
- Status thresholds and boss control resistance remain useful but cannot create permanent control loops.
- Trigger recursion and proc rates are bounded by tests.
- Planning never mutates authoritative combat state before commitment, and the same state plus commands produces the same result.
- Enemy intentions disclose targets and actionable outcomes unless a named, inspectable mechanic explicitly creates uncertainty.

## M06 - Starter party kits and command interface

**Depends on:** M05.

Turn the M00 party into production starter kits: Dena the Bulwark, Moss the Hexer, Vell the Scavenger, and Ilex the Warden. Each receives a basic action, two role powers, one setup or utility action, one defensive option, resource costs, equipment hooks, and clear command descriptions.

**Acceptance criteria**

- The starter party supports single-target pressure, area damage, defense, weakening, exposure, healing, and at least three cross-member combinations.
- Every command previews legal targets, resource cost, expected range, status effect, priority, and environmental interaction before commitment.
- Incapacitated members, target death, invalid commands, and mid-round retarget rules are explicit and tested.
- A combat laboratory reports damage, Guard, status, Focus, Strain, target changes, item triggers, and resolution order.
- Keyboard, mouse, and controller can plan, revise, inspect, and resolve a full party round without relying on timing or pointer precision.

## M07 - Three Gutterbloom enemy families

**Depends on:** M04-M06.

Expand Filing Larvae, Pipe Goblins, and Form Auditor constructs into three production enemy families with distinct intention patterns, preferred targets, defenses, vulnerabilities, formation interactions, and escalation behavior.

**Acceptance criteria**

- Each family is identifiable by silhouette, color language, and declared intention pattern before reading its codex entry.
- Mixed groups create new planning decisions without overwhelming the intention panel.
- Target distribution and action budgets prevent unavoidable focus fire before higher optional difficulty.
- Formation changes, reinforcement rules, reset, and retreat recovery are tested.
- Enemies expose exact resistances and break discoveries through the codex.

## M08 - Elite mutation framework

**Depends on:** M05, M07.

Implement Aftershock, Choirbound, Taxing, Mirrorborn, Unannounced, and Well-Fed mutations with compatibility tags and difficulty budgets.

**Acceptance criteria**

- Mutations apply through definitions rather than enemy-specific forks.
- Illegal family/mutation combinations fail content validation.
- Early difficulty uses at most one mutation per elite.
- Each mutation has an icon, introduction tell, codex rule, drop-budget effect, and automated behavior fixture.
- An ordinary enemy can be promoted after a qualifying defeat, gain one legal mutation and title, and enter a bonus reward pool without permanently stalking the player.

## M09 - Rain Treasurer boss

**Depends on:** M05-M08.

Build a multi-phase Gutterbloom boss using water-level control, fungal growth, Underworks bargains, formation changes, and route knowledge introduced in the zone.

**Acceptance criteria**

- The arena checkpoint is under 20 seconds from a discovered anchor.
- First-kill reward, repeat pool, Boss Seal, and state-change event are defined.
- Intros and phase cinematics can be skipped after first viewing.
- All lethal actions declare redundant visual, textual, and audio warnings before the plan is committed.
- At least three viable party loadouts defeat it in playtest without relying on a bug, one mandatory party composition, or one mandatory item.

## M10 - Combat feel and accessibility pass

**Depends on:** M06-M09.

Tune command flow, target selection, round pacing, camera response, sprite animation, sound, effects, damage presentation, intention telegraphs, flash reduction, motion reduction, hold/toggle behavior, and difficulty assists.

**Acceptance criteria**

- Playtesters can explain why they took damage, why a target changed, and which action created a status in most observed failures.
- Reduced motion, instant steps and turns, reduced flashes, scalable HUD, remappable inputs, subtitle controls, and planning assists work in the exported build.
- Effects do not obscure boss tells at default or reduced settings.
- The standard stress encounter meets the provisional frame-time budget on named hardware.

## Gate B - Combat review

The game must be enjoyable for 15 minutes with placeholder rewards before building the full loot loop. Record unedited play sessions and concrete findings about navigation feel, planning clarity, round pacing, repetition, and party decisions.

# Phase 2: Loot and persistence

## M11 - Deterministic loot generator

**Depends on:** M02, M05.

Implement the definition schemas and deterministic stage order in `CONTENT_PIPELINE.md`: bases, rarity budgets, materials, exclusivity groups, roll values, named synergies, curated laws, compatibility, separate seeded streams, reward ledger, layered item text, and drop presentation events.

**Acceptance criteria**

- A recorded seed reproduces the exact item.
- A 100,000-roll laboratory reports family, rarity, affix, and value distributions.
- No roll contains duplicate exclusive affixes, illegal slot affixes, unsupported damage conversions, or missing descriptions.
- Visual randomness does not change reward output.
- Functional summaries and exact laws remain clear when flavor appraisals are hidden or expanded.
- Spotlight enabled or disabled produces byte-for-byte identical baseline items for the same source, seed, and ledger state.
- Every invalid generation path produces a deterministic legal fallback and an actionable authoring report.

## M12 - Equipment, loadouts, and comparison

**Depends on:** M06, M11.

Implement equipment slots, derived stats, weapon-family techniques, item cards, comparison, favorites, locks, and two named loadouts.

**Acceptance criteria**

- Equipping an item updates combat through the modifier pipeline with a visible trace.
- Comparisons show exact deltas, conditions, law text, conflicts, and source.
- Loadout items cannot be accidentally salvaged.
- Switching loadouts handles incompatible weapons, powers, and missing items with an actionable explanation.

## M13 - Inventory repository and overflow

**Depends on:** M11, M12.

Implement materials, currencies, equipment instances, field collection, persistent overflow, repository transactions, journal recovery, pagination, and test data generation.

**Acceptance criteria**

- No reward path destroys an item when field presentation is full.
- Interrupted grant, salvage, equip, and move transactions recover without duplication or loss.
- Common materials aggregate instead of creating thousands of individual records.
- Generated inventories of 10,000 and 100,000 items can be opened for stress testing.

## M14 - Archive Vault interface

**Depends on:** M13.

Build virtualized collection UI with search, filters, sorting, tags, saved searches, duplicate grouping, collection history, auto-salvage preview, and undo ledger.

**Acceptance criteria**

- All required actions are available with controller only.
- Common searches meet the performance budget at 100,000 items or trigger the backend scale decision.
- Auto-salvage never touches favorites, locked items, loadout items, highest discovered copy, or excluded rarities unless the preview explicitly says so.
- A user can find an item by a phrase from its power description, source zone, or custom tag.
- The collection retains the first appraisal for a discovered base after every physical copy is reclaimed.

## M15 - Caches, attunement, and bad-luck protection

**Depends on:** M11-M14.

Implement Field, Contract, and Boss Caches, previewed reward rules, skip/replay presentation, family/tag attunement, Boss Seals, duplicate Echo Shards, and a deterministic pity counter.

**Acceptance criteria**

- Every Cache reveals eligible categories and guarantees before opening.
- No Cache uses a paid key or real-money route.
- Simulation proves the stated maximum path to a targeted boss unique.
- Duplicate conversion and pity survive save/load and cannot be reset through reload abuse.
- Reveal presentation can be shortened to under one second after player input.

## M16 - Reclamation, forge, and economy

**Depends on:** M12-M15.

Implement Marks, Salvage, Essences, Echo Shards, Boss Seals, vendors, salvage, and the protected Hearthfold Reclamation flow in `HEARTHFOLD_UPGRADES.md`, plus room-growth inputs, quality upgrades, one affix tune, recipes, and transaction previews.

**Acceptance criteria**

- Every spend previews inputs, outputs, locked properties, uncertainty, and undo policy.
- The first slice has useful currency sinks without durability destruction or inventory rent.
- Crafting strengthens exploration rewards rather than replacing undiscovered boss loot.
- Economy tests detect negative costs, overflow, duplication loops, and impossible recipes.
- Reclamation protects favorites, locks, loadouts, best copies, and curated rarities by default; it displays a new low-rarity appraisal before first digestion.
- No item sink activates automatically because field or Archive storage filled.
- Every normal Hearthfold tier is economically reachable without reclaiming Exotic, Legendary, or Mythic items.
- Interrupted Reclamation commits all removals and RU awards once or rolls back all of them.

## M17 - Profile saves, migration, backup, and recovery

**Depends on:** M02, M12-M16.

Implement atomic profiles, autosave scheduling, manual saves or named exports, checksums, three rotating backups, schema migration fixtures, import validation, and corruption recovery UI.

**Acceptance criteria**

- Killing a process during each tested transaction preserves either the prior or completed state, never a half-applied state.
- A deliberately corrupted current snapshot recovers from backup with an honest summary.
- Import failure leaves the active profile untouched.
- Old-version fixtures migrate deterministically.
- Save and load meet provisional budgets at stress sizes.

## Gate C - Loot and persistence review

Run a two-hour repeated combat and loot session. Verify no item loss, reproducible rewards, useful comparisons, manageable cleanup, stable saves, and a clear target-farming path. Do not proceed if collecting gear feels like administrative work.

# Phase 3: Complete vertical slice

## M18 - Living Gutterbloom state and Spotlight

**Depends on:** M04, M07-M09, M17.

Implement water level, route state, Filing Larva pressure, Tollmold spread, Form Auditor patrol control, resource abundance, settlement prosperity, threat, weather, boss succession, and the five Spotlight ranks, banked bonuses, and optional broadcast complications in `COMMENTARY_SPOTLIGHT_SPEC.md`. Use the layered tick, dirty-fact indexes, named-entity records, local Memory Graph, and atomic deltas in `WORLD_SIMULATION_AND_MEMORY.md`.

**Acceptance criteria**

- State changes from player events and coarse time advancement.
- At least one route, resource, patrol, and encounter changes visibly after boss victory.
- Critical content remains replayable through an Echo Hunt or successor path.
- Closing the game freezes authoritative world, situation, NPC, and relationship state. Return processing only rebuilds indexes and summarizes the last committed state.
- A fixed snapshot, event batch, content revision, and seed reproduce the same strategic delta.
- No strategic tick can kill or permanently remove a named NPC, essential service, critical route, or sole build-reward source offscreen.
- Spotlight rises through authored novelty and risk combinations, never through idle time or a repeated single trigger.
- Low Spotlight does not reduce published baseline drops, experience, Boss Seals, contracts, or story progress.
- Accessibility, difficulty-assist, and commentary settings have no Spotlight penalty.
- Defeat preserves every completed banked rank. Only unfinished active progress can form an optional Embarrassment Remnant.
- Ignoring a Remnant converts it into consolation or Cache progress instead of creating permanent loss.

## M19 - Latchmarket and The Dry Boot

**Depends on:** M04, M16, M18.

Build one safe town edge and one semi-safe bar with vendor, forge contact, rumors grounded in live zone state, contracts, preparation food, one optional brawl, one faction incident, and anchor access. Implement Dava Fen and Scrip Nine as the first production social characters, Quoin Rusk as the anchor specialist, and one limited Registrar Loam role using `NPC_DOSSIERS.md`.

**Acceptance criteria**

- The HUD and map state exact safety rules.
- A player cannot be surprise-killed while managing inventory or dialogue.
- Rumors correspond to actual available events or explicitly state uncertainty.
- The ledger distinguishes confirmed facts, credible reports, rumors, and contradicted claims.
- Named NPC schedules use in-game activity states and preserve service access while a character is elsewhere.
- The bar brawl is optional, clearly signaled, recoverable, and does not destroy owned items.
- Core interactions are concise on repeated visits.

## M20 - Hearthfold Refuge, Forge, and Picket

**Depends on:** M14, M16-M19.

Build the vertical-slice scope from `HEARTHFOLD_UPGRADES.md`: persistent Refuge and Forge rooms, entry and exit rules, healing, basic Archive access, practice target, crafting, Reclamation, trophies, cosmetics, one meaningful permanent room upgrade, and Picket's field/Hearthfold loop.

**Acceptance criteria**

- The same Hearthfold state is reachable from all slice anchors.
- Entry cannot bypass active boss phases or scripted danger without a defined checkpoint.
- Exit location and destination costs are always previewed.
- Room changes, trophies, staff state, and upgrades survive save/load.
- Travel transitions hide loading without pretending the room physically follows in open space.
- Picket can mark a hazard, retrieve one nearby drop, equip two Inspection Protocols, remember a warning outcome, and be independently muted without suppressing visual hazard information.
- The first upgrade has no daily cap, real-world build time, required high-rarity sacrifice, or passive-stat prerequisite.

## M21 - Humor, callbacks, and announcements

**Depends on:** M02, M05, M11, M18-M20.

Implement event queries, priority queues, hard eligibility filters, scoring, cooldowns, novelty budget, typed Comedy Memories, callback chains, sincerity holds, combat-safety policy, Herald/Picket exchanges, subtitles, transcript, frequency controls, teasing controls, streamer-safe variants, mute, and the vertical-slice content targets in `HUMOR_AND_VOICE.md` and `COMMENTARY_SPOTLIGHT_SPEC.md`.

**Acceptance criteria**

- Critical warnings outrank jokes and rare-drop announcements outrank ambient chatter.
- No ordinary line repeats more often than its declared limit.
- Stale observations are dropped.
- Commentary frequency, voice, subtitles, teasing, and streamer-safe settings persist independently.
- A 30-minute automated event storm produces a readable scheduler report with no starvation or overlap bugs.
- Playtests find that silence remains common enough for announcements to feel special.
- At least one remembered failure produces a contextually correct callback after a substantial delay and then respects its repeat limit.
- Picket and Herald lines remain distinguishable with speaker labels hidden.
- The Courtesy Drain expresses four moods through more than spoken lines, and every mood preserves equivalent reward value.

## M22 - Contracts, events, and zone ledger

**Depends on:** M18, M19, M21.

Implement objective definitions, the candidate pipeline and lifecycle in `SITUATION_ENGINE.md`, four authored situations, six repeatable contracts, two small zone threads, discoveries, ecology entries, rewards, recovery objectives, 24 Accolades or Indignities, promoted-enemy incidents, and mastery tracking.

**Acceptance criteria**

- Objectives derive progress from typed events and survive save/load.
- No required objective expires with real time.
- Accepted objectives do not advance or expire while the game is closed.
- Candidate selection hard-filters prerequisites, duplicates, participant conflicts, active budgets, content preservation, and presentation load before scoring.
- The engine may select zero situations and reproduces the same selection from a fixed snapshot and seed.
- Failed events offer a recovery path or documented next opportunity.
- Target rewards and zone-state consequences are previewed.
- The ledger points toward unfinished categories without turning exploration into a mandatory checklist.
- Accolades and Indignities arise from exact game events, never inaccessible player data, and their mechanical rewards cannot be farmed by reloading.

## M23 - Boss aftermath and return loop

**Depends on:** M09, M15, M18, M22.

Connect the Rain Treasurer victory to water-level change, route opening, predator migration, successor setup, first-kill Cache, Boss Seals, Spotlight bank, Herald/Picket response, town reaction, Hearthfold trophy, and a new target-farm option.

**Acceptance criteria**

- All consequences occur once where appropriate and remain consistent after save/load.
- The original boss remains replayable.
- The changed route provides a materially different five-to-eight-minute farming loop.
- A player who skips dialogue can still understand the state change through map, visuals, ledger, and announcement history.

## M24 - Vertical Slice release gate

**Depends on:** M00-M23.

Replace critical placeholders, tune a representative 20-to-30-minute expedition, add 12 curated legendary items, finish onboarding, test clean profiles and upgrades, profile stress scenes, and produce signed internal builds.

**Acceptance criteria**

- New players can reach, understand, and defeat the boss without developer intervention at the intended difficulty.
- The slice includes the exact feature checklist in `README.md`.
- Spotlight, an Embarrassment Remnant, one enemy promotion, Picket, one delayed callback, one Reclamation upgrade, and four Courtesy Drain moods work end to end.
- Automated validation, unit tests, integration tests, export smoke tests, and save recovery tests pass.
- Controller-only and keyboard/mouse-only runs pass.
- No known issue can lose or silently alter owned equipment.
- Performance is measured against named hardware; failures remain failures even if other gates pass.
- At least five observed playtests produce written findings, changes, and retest results.
- A build, version notes, save compatibility statement, and known-issues list are archived.

# Phase 4: Public alpha

## M25 - Full build framework and four Disciplines

**Depends on:** M24.

Complete Origin selection, Character Rank, Discipline Rank, Familiarity, loadout respec, one Advanced Path framework, and four production Disciplines: Riftblade, Cinderwright, Grave Gardener, and Storm Courier.

**Acceptance criteria**

- Each Discipline has a distinct resource or signature mechanic, eight usable powers, two viable build families, and complete controller mapping.
- Catch-up progression works when changing to a lower-rank Discipline.
- A profile can unlock and swap all four without restarting.
- Cross-discipline item laws declare valid interactions.

## M26 - Production content tools

**Depends on:** M11, M18, M21, M22, M25.

Finish the loot laboratory, content validator UI, spawn palette, combat trace, zone-state inspector, strategic-turn stepper, dirty-fact viewer, NPC presence map, relationship and rumor provenance inspector, situation candidate and recovery inspector, Spotlight inspector, Comedy Memory viewer, commentary console, save viewer, screenshot scenes, and authoring reports.

**Acceptance criteria**

- A designer can add a legal ordinary item, unique law, enemy variant, Cache, contract, and commentary line without changing central registries by hand.
- Batch validation reports exact files and actionable errors.
- Distribution reports are deterministic and comparable between builds.
- Debug tools are excluded or access-controlled in release exports.
- Situation reports expose every hard-filter rejection, score component, participant binding, fingerprint, and preservation check.

## M27 - Gutterbloom production expansion

**Depends on:** M25, M26.

Expand the slice into a full first zone with three subregions, two lairs, three bosses or named champions, the eight-character ensemble in `NPC_DOSSIERS.md`, four factions or social groups, 20 situations or events, secrets, routes, resources, and a complete reward pool. The production design must complete and pass `ZONE_DESIGN_TEMPLATE.md`.

**Acceptance criteria**

- First-time play provides at least 8 hours without padding through duplicate objectives.
- The zone supports at least six repeatable target-farm routes with different desired rewards.
- Ecology and faction changes create meaningful visual and mechanical variation.
- Critical routes, spawn budgets, navigation, and reward sources pass automated audits.
- Every terminal state preserves alternate access to build-defining rewards, essential services, and ordinary mastery completion.
- NPC relationships, activities, rumors, and situation outcomes produce visible post-boss changes without random offscreen mortality.

## M28 - Brass Orchard second zone

**Depends on:** M18-M27.

Build Pip Foundry, mechanical orchard ecology, harvest pressure, construct enemies, caretaker and feral boss succession, new traversal, new materials, and one Hearthfold visitor chain. Its pitch, graybox, systems, content, accessibility, performance, and release gates follow `ZONE_DESIGN_TEMPLATE.md`.

**Acceptance criteria**

- The zone does not merely reskin Gutterbloom encounters or events.
- At least one system from Gutterbloom behaves differently under construct ecology.
- Zone travel, Archive, Hearthfold, commentary, build progression, and saves work across both zones.
- Old-zone target farming remains valuable after entering the new zone.

## M29 - Factions, reputation, and settlement state

**Depends on:** M19, M22, M27, M28.

Implement reputation ledgers, typed NPC relationship and knowledge edges, services, conflicting local goals, previewed consequences, settlement prosperity, specialist visitors, and reversible or recoverable state outcomes.

**Acceptance criteria**

- Faction choices change services, patrols, events, or prices rather than only dialogue.
- No single decision permanently erases a unique build reward.
- The UI distinguishes reputation, control, prosperity, and immediate hostility.
- Opposing groups can survive and reorganize through successor states.
- Random pairwise simulation cannot create romance, irreversible betrayal, named-NPC death, or a lost essential service.

## M30 - Gods, covenants, and demigods

**Depends on:** M25, M29.

Implement the first six patrons from `DIVINE_COVENANTS.md`: Ilex, Morrow-in-Arrears, Saint Nobody, the Orchard Crown, Lady Lastlight, and the Small Door. Add two local demigods, Recognition, non-destructive Tension, major and minor covenant slots, offerings, divine proofs, shrines, conflicts, relic pursuits, and item interactions.

**Acceptance criteria**

- Covenants create meaningful build tradeoffs and can be changed in the Hearthfold without debt, lost Recognition, real-world cooldown, or permanent lock.
- Divine Tension cannot steal equipment, corrupt saves, reduce baseline rewards, disable zones, damage the Hearthfold, or permanently brick progression.
- Every relationship threshold is reachable without offering Exotic, Legendary, or Mythic items.
- Each god has one Major Covenant, one Minor Favor, one noncombat interaction, a Tension route, and a protected relic pursuit.
- Demigod defeat, negotiation, and succession affect zone state.

## M31 - Hearthfold expansion

**Depends on:** M20, M25, M29, M30.

Build the Household expansion in `HEARTHFOLD_UPGRADES.md`: Archive, Training Hall, Conservatory, Guest Wing, staff, visitors, loadout testing, attunement upgrades, expedition-driven cultivation, trophies, customization, room synergies, and an optional defense simulation.

**Acceptance criteria**

- Each room adds a functional capability and at least one horizontal upgrade choice.
- Defense is explicitly opted into and cannot destroy rooms or stored items.
- Visitors respond to actual faction, ecology, boss, and covenant states.
- Layout and cosmetics can be rearranged without cost or lost objects.
- Offline time cannot wither cultivation, remove visitors, reduce output, or create a login obligation.
- Functional room nodes add information, preparation, testing, targeting, or relationships rather than hidden global damage multipliers.

## M32 - World Temper and long-tail loop

**Depends on:** M25, M27-M31.

Implement optional difficulty tiers, mutator budgets, higher elite combinations, Echo Hunts, targeted currencies, prestige cosmetics, capped Renown, and old-zone return incentives.

**Acceptance criteria**

- Difficulty increases tactics, density, mutations, hazards, and boss mechanics rather than only health.
- Ordinary story and zone access do not require extreme Temper.
- Rewards improve without making all lower-Temper equipment trash.
- No standard progression depends on a completion timer.

## M33 - UI, audio, onboarding, and accessibility alpha pass

**Depends on:** M25-M32.

Unify HUD, map, codex, Archive, item comparison, objectives, settings, audio mix, onboarding, subtitles, color-independent signaling, scalable text, input alternatives, and reduced-intensity modes.

**Acceptance criteria**

- A new player can create a profile, learn the loop, change a build, target an item, upgrade the Hearthfold, and understand a zone change without outside instructions.
- All critical information has non-color and non-audio representation.
- Controller focus order is tested across every required screen.
- Commentary, combat, dialogue, music, and ambience remain intelligible under the mix matrix.

## M34 - Persistence and performance scale gate

**Depends on:** M26-M33.

Stress 100,000 items, maximum strategic-turn batches, 1,000 named-entity records, 25,000 typed relationship and memory edges, 10,000 EventSummaries, dense combat, repeated zone travel, long sessions, backup recovery, migrations, content reloads, and minimum-hardware graphics tiers.

**Acceptance criteria**

- Quality budgets in `TECHNICAL_DESIGN.md` pass on named hardware or are explicitly revised with user-visible tradeoffs.
- No memory growth trend remains after repeated load/unload and combat cycles.
- Inventory backend decision is settled through measurements.
- World-memory repository queries and situation generation meet their budgets or trigger the bundled local-database gate without adding a network service.
- Save fixtures from every supported version migrate and continue playing.
- A failed performance budget is reported as failed even when functional tests pass.

## M35 - Public Alpha release gate

**Depends on:** M25-M34.

Freeze alpha scope, repair release-blocking defects, run security/privacy review, package builds, document saves and controls, create feedback capture, and complete final playtest matrix.

**Acceptance criteria**

- Two zones, four Disciplines, Hearthfold progression, factions, gods, commentary, loot, living state, and long-tail loop are playable end to end.
- Automated, compatibility, accessibility, recovery, performance, and playtest gates have archived evidence.
- Telemetry is absent or explicitly opt-in with documented fields.
- Known issues contain honest impact and workarounds.
- Public feedback can be tied to build version and save version without collecting unnecessary personal data.

# Phase 5: Early Access candidate

## M36 - Four-zone world expansion

**Depends on:** M35.

Add Glass Tidelands and Choir of Ash with original traversal, ecology, factions, settlements, bosses, state transitions, and reward identities.

**Acceptance criteria**

- Four zones each provide a distinct play pattern, not just biome art.
- Cross-zone contracts and Hearthfold visitors work without forcing constant travel.
- Content metrics show viable reward sources across all weapon families in scope.

## M37 - Six-zone breadth and eight Disciplines

**Depends on:** M36.

Add Clockfen, Skygrave Reach, Chorus Binder, Beast Broker, Lantern Savant, and Debt Saint. Expand weapon families, powers, enemy families, and legendaries toward Early Access targets.

**Acceptance criteria**

- Eight Disciplines each have at least two viable production builds.
- Six zones remain useful at endgame through distinct target rewards and state events.
- Cross-system combinatorial tests cover Discipline, law, status, summon, and mutator interactions.

## M38 - War Room, routing, and world continuity

**Depends on:** M31, M32, M37.

Add the Hearthfold War Room, zone forecasts, contract planning, anchor routing, threat maps, zone-state summaries, and cross-zone consequences.

**Acceptance criteria**

- Players can understand what changed while away and why.
- Forecasts expose uncertainty rather than pretending to exact knowledge.
- Fast travel costs and restrictions respect the anti-frustration constitution.
- No cross-zone state can invalidate another zone's critical progression.

## M39 - Release operations and compatibility

**Depends on:** M34-M38.

Automate signed builds, versioning, release notes, save compatibility declarations, crash-log export, dependency inventory, license reports, build retention, rollback instructions, and update testing.

**Acceptance criteria**

- Upgrade from the public alpha build preserves profiles through the full release matrix.
- The prior stable build can be restored with documented steps.
- Shareable logs redact local user paths and platform identifiers.
- Third-party licenses and asset provenance are complete.

## M40 - Early Access candidate gate

**Depends on:** M35-M39.

Run a content-complete candidate cycle for six zones and eight Disciplines, prioritize retention of the anti-frustration promise, and establish evidence-based post-launch scope.

**Acceptance criteria**

- A fresh profile, returning profile, large inventory profile, and migrated alpha profile complete the release smoke route.
- At least 40 hours of varied progression exist without requiring completionist repetition.
- Players can name target rewards and make build choices without external spreadsheets.
- Performance, compatibility, save safety, accessibility, and offline behavior meet published expectations.

# Phase 6: 1.0

## M41 - Twelve-Discipline completion

**Depends on:** M40.

Add Scrap Oracle, Veil Strider, Feastkeeper, and Threshold Warden; complete 24 Advanced Paths, cross-discipline tags, training, catch-up progression, and balance matrices.

**Acceptance criteria**

- Every Discipline has a distinct signature, at least two Advanced Paths, and viable ordinary and high-Temper builds.
- Swapping and respec rules remain generous and clear.
- All active-power layouts work on controller without mandatory input chords that fail accessibility review.

## M42 - Eight-zone and content-target completion

**Depends on:** M40, M41.

Add the Pale Rail and Sunken Parliament. Reach or deliberately revise the 1.0 counts for settlements, named NPCs, authored situations, weapons, affixes, powers, uniques, enemies, bosses, events, Caches, gods, and Hearthfold rooms.

**Acceptance criteria**

- Counts are reported with definitions that exclude trivial palette swaps and numeric duplicates.
- Every curated item and power has a targetable source and test coverage appropriate to its rule.
- Every zone has a distinct ecology, settlement function, traversal hook, boss succession, and return loop.
- Missing target counts require a quality rationale, not silent scope disappearance.

## M43 - Endgame and completion systems

**Depends on:** M32, M38, M41, M42.

Complete zone ledgers, World Temper, Echo Hunts, divine relic pursuits, successor bosses, collections, Hearthfold displays, seeded optional challenges, cosmetics, and capped infinite tracks.

**Acceptance criteria**

- Endgame has at least five independent pursuits and no single mandatory corridor.
- Infinite tracks do not grant uncapped combat power.
- Weekly or rotating opportunities never delete unique rewards or ordinary progression.
- Old zones contain desired endgame sources beyond generalized currency.

## M44 - Narrative, localization, and content safety

**Depends on:** M42, M43.

Finalize authored zone threads, settlement dialogue, Herald library, covenant writing, codex, credits, localization pipeline, streamer-safe variants, content warnings, and original-IP review.

**Acceptance criteria**

- Core text uses localization keys and layout survives text expansion.
- Commentary settings cover frequency, voice, subtitles, profanity, teasing, and streamer-safe content.
- A final review removes recognizable copied names, phrases, characters, item descriptions, and setting-specific lore.
- Credits and licenses identify all contributors, assets, tools, and voice sources.

## M45 - Final compatibility, performance, and recovery campaign

**Depends on:** M41-M44.

Run long-duration stability, minimum/recommended PC tiers, graphics presets, input devices, display modes, storage interruption, migration, backup recovery, offline mode, and clean-install tests.

**Acceptance criteria**

- Published minimum specification is supported by measured scenarios.
- Save recovery and upgrade paths pass from every supported public version.
- A 100-hour accelerated simulation does not produce invalid zone state or economy overflow.
- No release blocker remains in crash, corruption, progression, accessibility, security, or performance categories.

## M46 - 1.0 release gate

**Depends on:** M00-M45.

Lock content, branch policy, builds, release notes, support documentation, rollback plan, and archived evidence.

**Acceptance criteria**

- The complete offline game runs without an account or network connection.
- Eight zones, 12 Disciplines, 24 Advanced Paths, full Hearthfold, living state, targetable loot, commentary, gods, settlements, and endgame meet their acceptance criteria.
- The shipped build and symbols are archived and reproducible from the tagged source.
- Save compatibility and known issues are public and exact.
- No planning claim is used as evidence for an untested runtime behavior.

# Phase 7: Conditional horizon

## M47 - Two-player co-op feasibility spike

**Depends on:** stable M46 branch and explicit product approval.

Build a disposable host-authoritative spike for two players in one encounter and one Hearthfold visit. Test join/leave, rewards, latency, host interruption, item laws, zone ownership, and offline profile boundaries.

**Advance only if**

- Solo offline play remains fully supported.
- Save ownership and rewards cannot duplicate or disappear under tested interruption.
- The architecture does not require rewriting most powers and item laws.
- Measured development and server costs fit the available team and budget.

## M48 - Co-op production track

**Depends on:** M47 passing and separate approved roadmap.

This milestone is intentionally undefined until the spike supplies evidence. It must specify maximum party size, authority, matchmaking, privacy, moderation, compatibility, pause behavior, zone state, Hearthfold guests, and ongoing service cost before implementation.

## M49 - Mod and custom-content feasibility

**Depends on:** stable content schemas and explicit approval.

Investigate data-only mods, sandboxing, save namespaces, load order, compatibility, content validation, and an in-game disclosure model. Imported content is untrusted and may not execute arbitrary code by default.

## M50 - Post-1.0 zone cadence

**Depends on:** M46 evidence and sustainable production capacity.

Candidate zones include Candlewild, Bone-Rain Steppe, Salt Mirror Basin, the Velvet Maw, Last Festival District, the Starved Library, Red Weather March, and the White Furnace. Each new zone must add a meaningful ecology or systemic rule, not only content volume.

**Acceptance criteria for each zone release**

- It passes content, save, performance, accessibility, and original-IP gates.
- Its unique rewards remain permanently targetable after launch promotions end.
- It does not invalidate prior zones or require a new character.
- Release notes state exactly what is new, changed, fixed, measured, and still unverified.

# Immediate build backlog after plan approval

The first implementation work should remain narrow:

1. Confirm the five questions in `DECISIONS.md`.
2. Run M00 as a disposable Godot spike.
3. Pin the engine version and record the engine decision.
4. Create M01's repository and headless quality harness.
5. Build M03 movement in a tiny test gym.
6. Load one Bulwark weapon, one Hexer power, one Filing Larva, and one reward definition through M02.
7. Export the first runnable build before expanding the Gutterbloom graybox.

The target is not to build all 51 milestones at once. The target is to make M00-M04 honest, playable, testable, and easy to extend, then move through each gate without sacrificing the massive long-term ambition.
