# Implementation Status

This file is the evidence ledger for runnable work. The roadmap remains the scope and dependency plan; this file records what actually exists.

## Current build state

| Milestone | State | Implemented | Remaining gate |
| --- | --- | --- | --- |
| M00 Product lock and engine spike | In progress | Approved first-person pixel-crawler direction; deterministic six-room critical path; cardinal exploration; four-member stopped-time planning; visible intentions; three enemy definitions and sprites; optional pressure-line interaction; deterministic rewards; commentary; no-loss defeat recovery; Hearthfold return; repeat seeds; atomic save/load; verified macOS export | User feel review and native Windows run or agreed substitute |
| M01 Repository, project, and quality harness | Acceptance passed; dependency held | Git repository, project layout, ignore and formatting rules, helper commands, item and enemy validators, 65-assertion test runner, runtime smoke, three export presets, macOS/Windows/Linux artifact paths, fresh-clone proof, passing current CI, setup docs, and asset-source docs | M00 dependency gate only |
| M02 Content registry, event stream, and humor risk spike | In progress | Immutable item and enemy IDs, validated JSON definitions, central event stream, Herald and Picket M00 lines, promoted Form Auditor presentation, and gameplay event seams | Full schemas and references, localization, required commentary counts, callback memory, Spotlight, performance and repetition simulations |
| M04A Loot changes the party demo | Acceptance passed | 32 original equipment definitions; four slots per member and two Shared Relics; uncapped Archive, favorites, comparison, and two persistent loadouts; 18 active deterministic equipment laws; Taunt; typed magnitude-aware hit presentation; electrical paper-doll reaction; 120-plus conditional combat lines and exchanges; monster speech; generated portrait, enemy, equipment-icon, and dungeon-material art; rebuilt promo-oriented HUD; complete exported route | Human feel review can tune presentation, balance, and writing, but does not block the implemented milestone |

## Most recent local evidence

- Date: 2026-08-23
- Engine: Godot 4.7.2 stable Steam build `ed1daf0bf`
- Content validation: passed, 35 item definitions and three enemy definitions
- Automated tests: passed, 65 assertions covering content, deterministic loot, dungeon topology and navigation, stopped-time combat, Taunt targeting, typed hit records, two behavior-changing loadouts, named equipment activations, dialogue selection, visual assets, events, and atomic save recovery
- Runtime smoke: passed, main scene loaded headlessly for eight iterations
- macOS export: passed, 186 MB ad-hoc signed universal app; strict deep signature verification passed
- Exported crawler: full six-room route completed interactively; all three combats, visible intentions, tiny guarded hit reaction, conditional party exchange, named item activations, pressure-line setup and consumption, promoted enemy, rewards, Hearthfold summary/heal, uncapped Archive, favoriting, Loadout B application, new seed retention, manual save, and profile restore worked
- Native save evidence: six rooms discovered, three combat rooms cleared, 41 Archive entries retained at the Hearthfold, zero defeat item loss, and zero planning deadlines violated; a new expedition retained Build B and the favorite and then raised the Archive to 42 entries
- Visual inspection: the rebuilt combat HUD and Archive were inspected in the exported macOS app at full screen; the final evidence captures are `art/screenshots/m04a_combat_demo.jpeg` and `art/screenshots/m04a_archive_demo.jpeg`
- Hit and dialogue inspection: a fully guarded scratch produced a restrained portrait response and Moss's tiny-hit line; the subsequent Moss and Dena exchange reacted to the ineffective attack; damage-type presentation and electrical dialogue selection are separately covered by deterministic tests
- Windows cross-export: passed, 106 MB x86-64 PE artifact; native Windows runtime remains unverified
- Fresh-checkout proof: passed from the committed M04A tree; import, validation, all 65 assertions, and runtime smoke passed without the original `.godot` cache
- GitHub CI: passed on M04A pull-request run `32659691807` and post-merge `main` run `32659740611`; validation, all 65 assertions, runtime smoke, Linux export, and artifact upload completed successfully
- Interactive feel: mechanically played through and visually inspected by Codex; player judgment on hit weight, navigation cadence, planning depth, readability, and humor remains open for tuning

## Definition of progress

A file existing is not proof that gameplay works. Status moves only when the relevant command, exported artifact, measured result, or user playtest has been recorded here or in the milestone's evidence document.
