# Implementation Status

This file is the evidence ledger for runnable work. The roadmap remains the scope and dependency plan; this file records what actually exists.

## Current build state

| Milestone | State | Implemented | Remaining gate |
| --- | --- | --- | --- |
| M00 Product lock and engine spike | In progress | Approved first-person pixel-crawler direction; deterministic six-room critical path; cardinal exploration; four-member stopped-time planning; visible intentions; three enemy definitions and sprites; optional pressure-line interaction; deterministic rewards; commentary; no-loss defeat recovery; Hearthfold return; repeat seeds; atomic save/load; verified macOS export | User feel review and native Windows run or agreed substitute |
| M01 Repository, project, and quality harness | Acceptance passed; dependency held | Git repository, project layout, ignore and formatting rules, helper commands, item and enemy validators, 49-assertion test runner, runtime smoke, three export presets, macOS/Windows/Linux artifact paths, fresh-clone proof, passing current CI, setup docs, and asset-source docs | M00 dependency gate only |
| M02 Content registry, event stream, and humor risk spike | In progress | Immutable item and enemy IDs, validated JSON definitions, central event stream, Herald and Picket M00 lines, promoted Form Auditor presentation, and gameplay event seams | Full schemas and references, localization, required commentary counts, callback memory, Spotlight, performance and repetition simulations |

## Most recent local evidence

- Date: 2026-08-23
- Engine: Godot 4.7.2 stable Steam build `ed1daf0bf`
- Content validation: passed, three item definitions and three enemy definitions
- Automated tests: passed, 49 assertions covering content, deterministic loot, dungeon topology and navigation, stopped-time combat, environmental damage, victory/defeat, procedural pixel sprites, events, and atomic save recovery
- Runtime smoke: passed, main scene loaded headlessly for eight iterations
- macOS export: passed, 179 MB ad-hoc signed universal app; strict deep signature verification passed
- Exported crawler: full six-room route completed interactively; all three combats, visible intentions, pressure-line setup and consumption, three rewards, promoted enemy, Hearthfold summary/heal, retained Archive, new seed, manual save, and profile restore worked
- Visual inspection: default and expanded window layouts inspected; first-pass panel overlap, emissive clipping, and map crowding were fixed and reverified
- Windows cross-export: passed, 98 MB x86-64 PE artifact; native runtime not yet verified
- Fresh-clone proof: passed from local commit `6daf98f`; import, validation, 20 tests, and runtime smoke all passed without the original `.godot` cache
- GitHub CI: passed in first-person crawler pull-request run `32656147916`; validation, 49 assertions, runtime smoke, Linux export, and artifact upload completed successfully
- Interactive feel: mechanically played through and visually inspected by Codex; player judgment on navigation cadence, planning depth, readability, and humor remains open

## Definition of progress

A file existing is not proof that gameplay works. Status moves only when the relevant command, exported artifact, measured result, or user playtest has been recorded here or in the milestone's evidence document.
