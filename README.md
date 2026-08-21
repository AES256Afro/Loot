# LOOT: The Living Expanse

`LOOT: The Living Expanse` is the working title for an original 3D action RPG about exploring enormous living dungeon-zones, chasing ridiculous builds, collecting an absurd amount of gear, and upgrading a pocket refuge that follows the player across the world.

The intended feeling is a collision of:

- a readable third-person action RPG;
- broad, identity-rich zones with cities, towns, faction hubs, bars, ecology, and repeatable local problems;
- a reactive announcer and entertainment system that notices surprising player behavior;
- combinatorial loot backed by a large library of curated legendary items and powers;
- persistent, grind-friendly progression without timers, expiring floors, forced seasons, item loss, or tiny storage limits;
- living dungeons that change ownership, population, hazards, resources, and encounters as play continues.

The project can use high-level genre inspiration, but it will not copy protected names, characters, prose, lore, dialogue, signature items, or setting-specific content from another franchise. Its world, terminology, classes, powers, zones, gods, announcers, and items are original.

## Current status

A runnable M00 foundation now exists in Godot 4.7.2. It includes a third-person graybox encounter, one enemy, one attack, deterministic loot, original reactive commentary, atomic local saving, content validation, automated tests, runtime smoke checks, exported macOS, Windows, and Linux development artifacts, and passing CI. M00 remains in progress until user feel and direction review plus a native Windows run or agreed substitute. M01 acceptance evidence is complete but remains dependency-held by M00. See [IMPLEMENTATION_STATUS.md](IMPLEMENTATION_STATUS.md) for the exact boundary.

## Product assumptions

- Platform: PC first, controller and mouse/keyboard from the first playable slice.
- Camera: third-person over-the-shoulder, with field-of-view and camera-distance options.
- Mode: single-player first. Two-to-four-player co-op is a gated post-alpha investigation, not a launch promise.
- Engine: Godot 4.7.2 stable, pinned with the GL Compatibility renderer and typed GDScript.
- Business model: premium game. Reward caches are earned in play and have visible reward rules. No real-money randomized loot boxes.
- Persistence: local profiles first, export/import and rotating backups, with optional cloud support later.

## The first playable target

The first vertical slice is a 20-to-30-minute repeatable expedition in **The Gutterbloom**, a fungal sewer-wildland growing beneath a broken trade city. It must include:

- movement, camera, dodge, light/heavy attacks, one active power, and one utility action;
- a compact town edge, a semi-safe bar, a dangerous open route, a cave-dungeon, and a boss arena;
- three normal enemy families, one elite mutation system, and one boss;
- procedural drops, equipment comparison, a searchable persistent vault, and 12 curated legendary items;
- the portable **Hearthfold** refuge with storage, healing, crafting, and one permanent upgrade;
- Spotlight bonuses that reward risky or unusual play without reducing baseline grinding rewards;
- **Picket**, an original brass surveyor companion with hazard marking, loot retrieval, memory, and Herald banter;
- reactive humor and announcements with Accolades, Indignities, one promoted enemy, one delayed callback, priorities, cooldowns, subtitles, history, and independent controls;
- **The Courtesy Drain**, a living lair whose mood changes encounters and reward categories without lowering total value;
- a protected Reclamation Core that turns selected unwanted loot into Hearthfold growth;
- a living-zone state that changes at least one route, resource, faction patrol, and encounter after the boss is defeated;
- save/load, death recovery, key rebinding, controller support, basic accessibility settings, and automated data/save tests.

## Documents

- [PRODUCT_VISION.md](PRODUCT_VISION.md): audience, pillars, anti-frustration rules, core loop, and scope boundaries.
- [GAME_DESIGN.md](GAME_DESIGN.md): combat, progression, inventory, safe rooms, settlements, factions, gods, AI, and living-zone systems.
- [CONTENT_CATALOG.md](CONTENT_CATALOG.md): initial zone, class, power, loot, legendary, cache, enemy, god, and mutation catalogs.
- [HUMOR_AND_VOICE.md](HUMOR_AND_VOICE.md): Spotlight stakes, Herald and Picket voices, callbacks, achievements, lair personalities, item humor, and repetition budgets.
- [COMMENTARY_SPOTLIGHT_SPEC.md](COMMENTARY_SPOTLIGHT_SPEC.md): canonical events, commentary selection, Comedy Memory, positive-only Spotlight math, anti-exploit rules, and tests.
- [CONTENT_PIPELINE.md](CONTENT_PIPELINE.md): deterministic item generation, definition schemas, target farming, pity, descriptions, and content quality gates.
- [HEARTHFOLD_UPGRADES.md](HEARTHFOLD_UPGRADES.md): protected Reclamation, Core ranks, eight room trees, synergies, and validation rules.
- [DIVINE_COVENANTS.md](DIVINE_COVENANTS.md): Recognition, non-destructive Tension, offerings, loadout rules, and the first six covenant designs.
- [ZONE_DESIGN_TEMPLATE.md](ZONE_DESIGN_TEMPLATE.md): reusable ecology, routes, settlements, living lairs, mastery, state-transition, and production gates.
- [WORLD_SIMULATION_AND_MEMORY.md](WORLD_SIMULATION_AND_MEMORY.md): local layered simulation, named-entity state, schedules, relationships, rumors, memory queries, and persistence gates.
- [SITUATION_ENGINE.md](SITUATION_ENGINE.md): deterministic authored opportunities, discovery, participant binding, outcome safety, recovery, and event budgets.
- [NPC_DOSSIERS.md](NPC_DOSSIERS.md): character production standard and the first eight-member original Gutterbloom ensemble.
- [GUTTERBLOOM_VERTICAL_SLICE.md](GUTTERBLOOM_VERTICAL_SLICE.md): exact route, encounters, Picket introduction, living lair, boss, loot pool, state change, and success metrics for the first playable build.
- [TECHNICAL_DESIGN.md](TECHNICAL_DESIGN.md): proposed Godot architecture, data model, persistence, deterministic systems, tools, and quality budgets.
- [MILESTONES.md](MILESTONES.md): dependency-ordered delivery plan with acceptance criteria and release gates.
- [RISK_REGISTER.md](RISK_REGISTER.md): scope, humor, loot, save, performance, IP, production, and co-op risks with triggers.
- [DECISIONS.md](DECISIONS.md): decisions already made, assumptions to validate, and questions that should be answered by playtests.
- [SOURCE_SYNTHESIS.md](SOURCE_SYNTHESIS.md): what was adopted, modified, or rejected from the nine supplied planning files.
- [IMPLEMENTATION_STATUS.md](IMPLEMENTATION_STATUS.md): current runnable milestone evidence and remaining gates.
- [ENGINE_SPIKE.md](ENGINE_SPIKE.md): the M00 engine decision, observed risks, checks, and open review items.
- [DEVELOPMENT.md](DEVELOPMENT.md): exact local setup, controls, tests, exports, saves, and project layout.
- [ASSET_SOURCES.md](ASSET_SOURCES.md): current asset provenance and the production asset rule.

## Build philosophy

1. Prove movement, combat, loot, commentary, saving, and the Hearthfold in one small zone.
2. Make every content type data-driven and validated before multiplying it.
3. Build one excellent representative of each system before promising hundreds.
4. Expand breadth only after frame-time, save-time, content-validation, and player-comprehension budgets pass.
5. Finish milestones with tests and a runnable build. A planning checkbox never counts as implemented gameplay.
