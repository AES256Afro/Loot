# M00 Engine Spike Record

## Decision snapshot

| Field | Recorded value |
| --- | --- |
| Date | 2026-08-20 |
| Engine | Godot 4.7.2 stable, Steam build `ed1daf0bf` |
| Language | Typed GDScript |
| Renderer | GL Compatibility |
| Development machine | MacBook Pro Mac17,8, Apple M5 Pro, 48 GB memory |
| Camera assumption | Third-person over the shoulder |
| Production assumption | Stylized mid-detail 3D |
| Mode assumption | Offline single-player first; co-op remains evidence-gated |
| Tone assumption | Absurd and colorful presentation with room for sincere or darker stakes |

The camera, production style, mode priority, and tone are working assumptions taken from the planning direction. They still need the user's explicit feel review after playing the spike.

## What the spike contains

- third-person movement with mouse, keyboard, and controller bindings;
- camera orbit and spring-arm collision;
- sprint and jump;
- one short-range attack using a 3D physics-shape query;
- one chasing three-hit enemy;
- three validated JSON item definitions, including one Legendary;
- deterministic weighted reward selection;
- a local gameplay event stream;
- original Herald and Picket commentary;
- repeatable enemy restaffing without a timer or diminishing baseline reward;
- an atomic JSON save transaction with backup recovery;
- an actual Godot scene import and runtime smoke path.

The graybox uses only engine-created primitive meshes and authored colors. It is intentionally disposable presentation wrapped around reusable foundation code.

## Evidence recorded so far

| Check | Result | Evidence |
| --- | --- | --- |
| Engine pin | Passed | Steam executable reported Godot 4.7.2 stable, build `ed1daf0bf`. |
| Renderer pin | Passed | `project.godot` requests GL Compatibility for desktop and mobile renderer keys. |
| Project import | Passed | Godot editor completed first filesystem scan and registered scripts. |
| Content load | Passed | Headless validator loaded all three definitions. |
| Validation failure path | Passed | Test fixture with a duplicate immutable ID was rejected. |
| Determinism | Passed | Repeated seed and roll index produced the same reward ID. |
| Event stream | Passed | Publication, payload, and subscriber behavior passed. |
| Atomic persistence | Passed | Two commits, backup rotation, primary load, intentional primary corruption, and backup recovery passed. |
| Main-scene load | Passed | An eight-iteration headless runtime smoke completed without engine or script errors. |
| Automated suite | Passed | 20 assertions passed locally. |
| Exported encounter path | Passed mechanically | The macOS artifact reached victory, displayed a seeded Rare reward and reactive lines, autosaved two earned items across two defeats, and retained a valid backup. Feel remains pending user review. |
| macOS export | Passed | Ad-hoc signed 179 MB universal app contains arm64 and x86-64 executables; packaged headless load exited cleanly. |
| Windows cross-export | Passed | 98 MB x86-64 PE artifact created on the Mac. A native Windows run or agreed substitute remains open. |
| CI | Passed | Pull-request run `32442747080` validated content, ran the full harness, exported Linux x86-64, and uploaded the development artifact. |

## Observed engine risks

1. Godot may emit parse failures with process exit code zero in some custom-script paths. `tools/check.sh` now inspects output and fails on engine or script error markers.
2. Export templates are a version-matched dependency separate from the Steam editor installation. The official 4.7.2 template pack is now installed locally, and build readiness must continue checking that dependency explicitly.
3. GL Compatibility broadens hardware reach but provides fewer modern rendering features than Forward+. The visual direction should be evaluated inside this constraint before expensive effects production.
4. A spring-arm camera and primitive collision prove integration, not camera comfort. Tight spaces, stairs, slopes, moving geometry, aim assistance, and accessibility controls remain future tests.
5. Offline deterministic systems fit the current product contract. Co-op would introduce authority, synchronization, and persistence requirements that this spike deliberately does not solve.

## Current recommendation

Continue with Godot 4.7.2 and typed GDScript. Nothing in the implemented foundation currently threatens offline zones, deterministic loot, local commentary, or atomic profile persistence. Do not multiply content or commit to co-op until the player controller and combat pass an interactive feel review.

M00 remains in progress until the user direction and feel review plus a native Windows run or agreed substitute are complete.
