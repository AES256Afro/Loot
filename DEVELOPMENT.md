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

## Playable spike controls

| Action | Keyboard and mouse | Controller |
| --- | --- | --- |
| Move | WASD | Left stick |
| Camera | Mouse | Right stick |
| Sprint | Shift | Left-stick press |
| Jump | Space | A / Cross |
| Attack | Left click or F | Right shoulder |
| Save | F5 | Not bound in M00 |
| Load | F9 | Not bound in M00 |
| Restaff defeated enemy | R | Not bound in M00 |
| Release or capture mouse | Escape or click | Not applicable |

Defeat the Gutter Clerk with three attacks. A deterministic reward appears, the Herald and Picket react, and the profile autosaves through the atomic save path. Press R to repeat the encounter without a timer or reward penalty.

## Export templates and builds

Godot export templates matching 4.7.2 are required. They can be installed in the editor through `Editor > Manage Export Templates`, or placed in Godot's `4.7.2.stable` export-template directory.

Build commands:

```bash
tools/export.sh macos
tools/export.sh windows
tools/export.sh linux
tools/export.sh all
```

Generated builds go under `builds/` and are intentionally ignored by Git. Local macOS builds are unsigned development artifacts. Shipping distribution, signing, notarization, entitlements, and minimum-system targets are future release work.

## Project layout

```text
content/            Authored JSON definitions
scenes/             Godot scenes
scripts/actors/     Player and enemy behavior
scripts/content/    Definition loading and validation
scripts/core/       Cross-system event stream
scripts/game/       Spike composition and runtime flow
scripts/loot/       Deterministic reward resolution
scripts/save/       Transactional local persistence
tests/              Headless automated tests
tools/              Run, check, validation, and export commands
```

## Save behavior

The spike profile is stored in Godot's per-project user-data directory as `profiles/spike_save.json`. A write is first flushed and parsed as a temporary file. The prior primary is rotated to `.bak`, then the verified temporary file becomes the primary. Loading falls back to the backup if the primary is invalid.

The automated tests use a separate `test_artifacts/atomic_save_test.json` path and remove only those scoped test files.

## Content rule

Every production definition needs an immutable namespaced ID. The current validator rejects duplicate IDs, missing player-facing text, invalid rarity or slot values, non-positive drop weights, and missing or malformed tags. The three M00 rewards are proof data, not the promised final catalog.

## Continuous integration

`.github/workflows/ci.yml` pins Godot and its export templates to 4.7.2. It imports the project, validates content, runs tests, smoke-loads the main scene, exports a Linux development build, and uploads that build as an artifact.

The workflow is proven on GitHub. Pull-request run `32442747080` completed validation, all tests, the runtime smoke, Linux export, and artifact upload with Actions v7 on the hosted runner.
