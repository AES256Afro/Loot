# Development Setup

## Pinned toolchain

- Engine: Godot 4.7.2 stable
- Scripting: typed GDScript
- Renderer: GL Compatibility
- Primary development platform: macOS
- Initial export targets: macOS, Windows x86-64, and Linux x86-64

The helper detects `godot`, `godot4`, a `GODOT_BIN` override, or the default Steam installation at:

`~/Library/Application Support/Steam/steamapps/common/Godot Engine/Godot.app/Contents/MacOS/Godot`

No shell-path change is required for the Steam installation.

## First run

From the project root:

```bash
tools/check.sh
tools/run.sh
```

`tools/check.sh` performs four gates:

1. Imports the project and parses scripts and scenes in the editor runtime.
2. Validates authored content definitions.
3. Runs the headless automated test suite.
4. Loads the real main scene for a bounded eight-iteration headless runtime smoke test.

The wrapper also scans output because Godot can emit a script parse error while returning exit code zero. An engine or script error fails the command.

## Playable crawler controls

| Action | Keyboard | Controller |
| --- | --- | --- |
| Step forward | W or Up | D-pad Up |
| Step backward | S or Down | D-pad Down |
| Turn left or right | A/D or Left/Right | D-pad Left/Right |
| Interact | E, Space, or Enter | A / Cross |
| Choose Strike, Power, Guard, or Expose | 1, 2, 3, or 4; buttons also work | Focused command buttons |
| Change combat target | A/D or Left/Right; enemy buttons also work | Focused enemy buttons |
| Resolve a complete plan | Enter, Space, or Resolve button | Focused Resolve button |
| Reset the current plan | Backspace, Delete, or Reset Plan button | Focused Reset Plan button |
| Save | F5 | Not bound in M00 |
| Load | F9 | Not bound in M00 |

Follow the map through six connected rooms. Combat freezes while commands are chosen for each living party member. Inspect enemy intentions, file one command per member, then resolve the exchange. The Pressure Junction interaction is optional; if primed, Vell's next Power damages every living enemy. Each cleared encounter grants a deterministic reward. The Hearthfold Anchor heals the party and can start another procedural expedition without a timer, gear loss, or reward penalty.

## Export templates and builds

Godot export templates matching 4.7.2 are required. They can be installed in the editor through `Editor > Manage Export Templates`, or placed in Godot's `4.7.2.stable` export-template directory.

Build commands:

```bash
tools/export.sh macos
tools/export.sh windows
tools/export.sh linux
tools/export.sh all
```

Generated builds go under `builds/` and are intentionally ignored by Git. Local macOS builds use Godot's built-in ad-hoc signing so they can run during development. Developer ID distribution signing, notarization, shipping entitlements, and minimum-system targets are future release work.

## Project layout

```text
content/            Authored JSON definitions
scenes/             Godot scenes
scripts/combat/     Deterministic stopped-time combat rules
scripts/content/    Definition loading and validation
scripts/core/       Cross-system event stream
scripts/dungeon/    Seeded dungeon topology and navigation
scripts/game/       Crawler composition and runtime flow
scripts/loot/       Deterministic reward resolution
scripts/save/       Transactional local persistence
scripts/ui/         Crawler HUD and command presentation
scripts/visual/     Procedural low-resolution sprite generation
tests/              Headless automated tests
tools/              Run, check, validation, and export commands
```

## Save behavior

The crawler profile is stored in Godot's per-project user-data directory as `profiles/spike_save.json`; the historical filename is retained so old spike inventory can be imported. A write is first flushed and parsed as a temporary file. The prior primary is rotated to `.bak`, then the verified temporary file becomes the primary. Loading falls back to the backup if the primary is invalid.

The automated tests use a separate `test_artifacts/atomic_save_test.json` path and remove only those scoped test files.

## Content rule

Every production definition needs an immutable namespaced ID. The current validator rejects duplicate item or enemy IDs, missing player-facing text, invalid rarity or slot values, non-positive drop weights, invalid enemy combat values, and missing or malformed tags. The three M00 rewards and three M00 enemy definitions are proof data, not the promised final catalogs.

## Continuous integration

`.github/workflows/ci.yml` pins Godot and its export templates to 4.7.2. It imports the project, validates content, runs tests, smoke-loads the main scene, exports a Linux development build, and uploads that build as an artifact.

The workflow is proven on GitHub. First-person crawler pull-request run `32656147916` completed validation, 49 assertions, the runtime smoke, Linux export, and artifact upload with Actions v7 on the hosted runner.
