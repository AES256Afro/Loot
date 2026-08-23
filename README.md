# LOOT: The Living Expanse

`LOOT: The Living Expanse` is the working title for an original first-person pixel dungeon crawler about exploring enormous living dungeon-zones, commanding a bizarre party through stopped-time choice combat, collecting an absurd amount of gear, and upgrading a pocket refuge that follows the player across the world.

The intended feeling is a collision of:

- a readable first-person party crawler with fully stopped plan-and-resolve combat;
- broad, identity-rich zones with cities, towns, faction hubs, bars, ecology, and repeatable local problems;
- a reactive announcer and entertainment system that notices surprising player behavior;
- combinatorial loot backed by a large library of curated legendary items and powers;
- persistent, grind-friendly progression without timers, expiring floors, forced seasons, item loss, or tiny storage limits;
- living dungeons that change ownership, population, hazards, resources, and encounters as play continues.

The project can use high-level genre inspiration, but it will not copy protected names, characters, prose, lore, dialogue, signature items, or setting-specific content from another franchise. Its world, terminology, classes, powers, zones, gods, announcers, and items are original.

## Current status

The approved first-person shaded pixel crawler is now the runnable main scene. The replacement M00 build contains a deterministic six-room Gutterbloom expedition, cardinal first-person exploration, a four-person party, three enemy types, stopped-time command planning, visible enemy intentions, an optional environmental setup, deterministic rewards, Herald and Picket commentary, a Hearthfold endpoint, repeatable seeds, and atomic local saving. The implementation is covered by 49 automated assertions; user feel review remains a human gate. The pivot contract is defined in [PIVOT_FIRST_PERSON_CRAWLER.md](PIVOT_FIRST_PERSON_CRAWLER.md).

## Product assumptions

- Platform: PC first, controller and mouse/keyboard from the first playable slice.
- Camera: first-person cardinal dungeon exploration with adjustable field of view, turn presentation, and motion-reduction options.
- Combat: a four-member party chooses commands and targets while time is fully stopped, then resolves a short simultaneous exchange.
- Art: shaded lo-fi pixel presentation built from a low-resolution 3D dungeon viewport and pixel-styled creatures.
- Mode: single-player first. Two-to-four-player co-op is a gated post-alpha investigation, not a launch promise.
- Engine: Godot 4.7.2 stable, pinned with the GL Compatibility renderer and typed GDScript.
- Business model: premium game. Reward caches are earned in play and have visible reward rules. No real-money randomized loot boxes.
- Persistence: local profiles first, export/import and rotating backups, with optional cloud support later.

## The first playable target

The current M00 playable is a compact expedition in **The Gutterbloom**, a fungal sewer-wildland growing beneath a broken trade city. It includes:

- a seed-reproducible six-room critical path from Underworks Intake to a Hearthfold Anchor;
- step movement, left and right turning, backward movement, keyboard controls, and controller exploration controls;
- Dena the Bulwark, Moss the Hexer, Vell the Scavenger, and Ilex the Warden, each with Strike, Power, Guard, and Expose choices;
- fully stopped planning with visible enemy targets and intentions, followed by a short deterministic resolution;
- Filing Larvae, Pipe Goblins, and a promoted Form Auditor encounter;
- an optional Pressure Junction setup that strengthens Vell's later Power without penalizing players who ignore it;
- earned deterministic rewards that enter a persistent, effectively unbounded prototype Archive;
- **Picket** and the **Herald Engine** reacting to rooms, maintenance choices, enemies, victory, defeat, and loot;
- no combat timer, no gear loss, no reward reduction for repetition, full-party recovery on defeat, and full healing at the Hearthfold;
- autosave, manual save/load, backup recovery, and new procedural expeditions that retain every reward.

The broader 20-to-30-minute Gutterbloom vertical slice remains the next production target. It adds the settlement edge, semi-safe bar, richer procedural rooms, equipment and Archive interfaces, Spotlight and callback depth, Hearthfold upgrades, living-zone change, elite mutations, and the Rain Treasurer boss after the crawler combat foundation passes play review.

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
- [PIVOT_FIRST_PERSON_CRAWLER.md](PIVOT_FIRST_PERSON_CRAWLER.md): approved camera, combat, visual direction, reusable systems, and replacement M00 slice.

## Build philosophy

1. Prove movement, combat, loot, commentary, saving, and the Hearthfold in one small zone.
2. Make every content type data-driven and validated before multiplying it.
3. Build one excellent representative of each system before promising hundreds.
4. Expand breadth only after frame-time, save-time, content-validation, and player-comprehension budgets pass.
5. Finish milestones with tests and a runnable build. A planning checkbox never counts as implemented gameplay.
