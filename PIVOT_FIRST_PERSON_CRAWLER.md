# First-Person Pixel Crawler Pivot

## Approval

Approved by the user on 2026-08-23.

`LOOT: The Living Expanse` is now a first-person, party-based dungeon crawler with shaded lo-fi pixel presentation, procedural zone dungeons, and stopped-time plan-and-resolve combat. The earlier third-person action spike remains useful historical engine evidence but is no longer the product direction.

## Product contract

- Explore in first person through deterministic procedural dungeons.
- Use a four-member combat party, with Picket as a non-slot support companion.
- Stop time completely while the player chooses commands and targets.
- Show enemy intentions before resolution.
- Resolve the chosen party and enemy actions in a short, readable exchange.
- Return to stopped time for the next decision with no planning timer.
- Render true 3D dungeon geometry at a deliberately low internal resolution with crisp nearest-neighbor scaling, shaded palettes, dithered atmosphere, and pixel-styled enemies.
- Preserve persistent zones, target farming, near-unlimited storage, Hearthfold progression, gods, factions, living dungeons, commentary, earned Caches, and the anti-frustration constitution.
- Preserve full baseline rewards for repeated grinding.
- Never punish time spent reading, planning, comparing items, pausing, or using accessibility features.

## M00 replacement slice

The first playable crawler slice must contain:

1. A deterministic six-room Gutterbloom dungeon.
2. First-person step movement and cardinal turning.
3. Shaded low-resolution 3D presentation with procedural pixel enemy art.
4. Four party members with distinct roles and powers.
5. Three enemy types across multiple encounters.
6. Fully stopped planning with actions, targets, visible intentions, and explicit resolution.
7. One optional environmental interaction that changes a later combat without reducing rewards if ignored.
8. Deterministic post-combat loot reveal and persistent inventory.
9. At least one Herald and Picket exchange tied to the player's actions.
10. A Hearthfold anchor that heals, saves, and ends the expedition without a timer.
11. Repeatable new expeditions with retained loot and no diminishing baseline rewards.
12. Atomic save/load, automated deterministic tests, a macOS export, and CI validation.

## Reused foundation

- Godot 4.7.2 and the GL Compatibility renderer
- content registry and immutable IDs
- deterministic reward resolver
- gameplay event stream
- atomic save service and backup recovery
- headless validation and tests
- export presets and GitHub Actions
- original Herald, Picket, Gutterbloom, Hearthfold, loot, and anti-punishment design

## Replaced foundation

- third-person over-the-shoulder camera
- free-running CharacterBody controller
- reflex attack timing and action hit queries
- continuous enemy chase behavior
- stylized mid-detail 3D production target

The historical scene remains at `scenes/spike/main.tscn` until the crawler slice passes export and playtest gates.

## Combat cadence

1. **Observe:** enemies appear in the current dungeon room and announce their intentions.
2. **Plan:** choose one command and target for every living party member. Time is stopped indefinitely.
3. **Preview:** inspect projected targets, damage ranges, defenses, statuses, and environmental opportunities.
4. **Resolve:** commit the plan and watch a short deterministic exchange.
5. **React:** review the log, updated health, new intentions, commentary, and available choices.
6. **Collect:** victory grants its full baseline reward automatically and reveals the item before exploration resumes.

## Visual target

- 400 by 225 internal world viewport at a 1600 by 900 reference window
- nearest-neighbor scaling and no smoothing on the dungeon viewport
- true 3D modular rooms and corridors
- procedural pixel textures or sprites for enemies and markers
- zone palette lighting rather than realistic material complexity
- high-resolution interface text where required for accessibility
- readable silhouettes and restrained effects during resolution

## First Gutterbloom run

| Room | Function |
| --- | --- |
| Intake | Entry, movement instructions, and first Herald/Picket exchange |
| Fungus Nursery | Filing Larvae encounter |
| Pressure Junction | Optional valve interaction that primes a later area attack |
| Flooded Cistern | Pipe Goblin and Filing Larva encounter |
| Promoted Office | Form Auditor, Pipe Goblin, and Filing Larva encounter |
| Hearthfold Anchor | Healing, run summary, atomic save, and repeat expedition choice |

The topology changes with the expedition seed while the room grammar preserves a coherent authored progression.
