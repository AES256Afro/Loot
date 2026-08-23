# Risk Register

This register turns the most dangerous assumptions into measurable gates. Ratings are initial planning judgments and should change when prototypes provide evidence.

| ID | Risk | Likelihood | Impact | Early mitigation | Trigger for action |
| --- | --- | --- | --- | --- | --- |
| R01 | Scope expands into an unfinishable MMO-lite | High | Critical | Single-player local-first architecture; dependency gates; content counts are targets, not concurrent work | Any foundation work begins to require accounts, persistent servers, trading, or broad multiplayer |
| R02 | The game copies recognizable franchise expression | Medium | Critical | Original setting, cast, gods, classes, items, dialogue, lore, and terminology; formal review before public builds | A tester identifies a character, item, scene, phrase, or world rule primarily by another property's name |
| R03 | Commentary becomes repetitive or interrupts play | High | High | Early humor risk spike; topic backoff; silence budget; typed callbacks; independent settings | A 15-minute test repeats ordinary lines, covers a cue, or makes the player request global mute |
| R04 | Herald, Picket, gods, and lairs sound like one writer | Medium | High | Speaker-specific motives, syntax, targets, and knowledge; blind voice tests | Reviewers cannot identify the speaker after labels are hidden |
| R05 | Full voice production exceeds budget | High | High | Prove timing in text; voice authored setpieces; systemic breadth remains text-capable; establish budget at alpha | Line growth, localization, casting, revision, or patch-size estimates exceed approved capacity |
| R06 | Spotlight punishes relaxed grinding | Medium | Critical | Baseline rewards never decline; accessibility and time are excluded; publish exact bonus rules | Players feel forced into risky or varied play to obtain ordinary target drops or story progress |
| R07 | Spotlight is easily farmed by one exploit | High | Medium | Combination-based novelty; recent-history suppression; deterministic simulations; capped ranks | One repeated input or reload path reaches high Spotlight reliably |
| R08 | Death has too little consequence to support comedy | Medium | High | Unfinished Spotlight Remnants, explicit optional wagers, enemy promotion, faction/event outcomes, callback memory | Death feels like free teleportation or players ignore every recovery consequence |
| R09 | Death recovery becomes an annoying corpse run | Medium | High | Remnants never hold owned gear and auto-convert to consolation rewards | Players repeat empty travel or lose a build because of recovery failure |
| R10 | Near-unlimited inventory makes loot unreadable | High | High | Field workflow, virtualized Archive, saved searches, best-copy grouping, appraisals, Reclamation | Players spend more session time cleaning items than making builds or stop reading drops |
| R11 | Reclamation causes accidental loss | Medium | Critical | Previewed transactions; favorites, locks, loadouts, best copies, and curated rarities protected; recovery tests | A test can consume protected gear or interrupt a transaction into item loss |
| R12 | Abundant drops destroy economy meaning | High | High | Reclamation, crafting, offerings, settlement projects, transparent exchanges, target-specific currencies | Faucets grow inventory and balances faster than any desirable sink over long simulation |
| R13 | Generated loot becomes numerical sludge | High | High | Curated bases and laws; controlled affix vocabulary; legality and usefulness tests; source identity | Players evaluate rarity color or item level only, or generated laws cannot be explained in UI |
| R14 | Living zones erase content or become opaque | Medium | Critical | Compact state, deterministic transitions, replay fallbacks, return summaries, zone inspector | A state combination blocks a required boss, reward, route, or service without a recovery path |
| R15 | Living lair mood punishes a preferred style | Medium | High | Reward parity by mood; category changes only; compatibility playtests | Stealth, aggression, caution, or thoroughness consistently yields lower value |
| R16 | Picket becomes mandatory, annoying, or emotionally flat | Medium | High | Utility side-grades, limited damage, independent chatter, trust scenes, sincere moments | Players keep Picket only for power, mute all lines, or describe it as another announcer |
| R17 | Combat feel is weak beneath strong systems | Medium | Critical | Combat gate before broad content; test gym; observed play; input and modifier traces | Players enjoy item planning but not the 15-minute combat-only test |
| R18 | Visual effects and UI obscure combat | High | High | Presentation budget, reduced-intensity options, automated stress scenes, cue comprehension tests | Players cannot explain damage sources or boss tells are hidden by builds |
| R19 | Save size and inventory search fail at scale | Medium | Critical | Repository abstraction; 10,000 and 100,000 item stress profiles; atomic transactions; backend gate | Search, save, load, backup, or recovery misses the recorded budget |
| R20 | Persistent save migration corrupts long-term profiles | Medium | Critical | Versioned schema, fixtures, checksums, rotating backups, import-on-copy | Any supported-version fixture loses items, discoveries, Hearthfold state, or zone state |
| R21 | Zone production is too slow for planned breadth | High | High | Stylized art assumption; reusable kits; authored macro layout; content tools; measure Gutterbloom velocity | First production subregion exceeds the capacity implied by eight-zone scope |
| R22 | Zones are large but empty | Medium | High | Density and route-loop targets, no square-kilometer promise, repeated traversal playtests | Traversal between decisions routinely exceeds the intended five-to-eight-minute loop |
| R23 | God and faction choices permanently lock builds | Medium | High | Persistent Recognition, non-destructive Tension, free Hearthfold covenant swaps, successor states, alternate acquisition | A choice removes a unique build law or service with no preview and no recovery |
| R24 | Procedural text creates broken or embarrassing lines | High | High | Grammar-constrained fragments, language-specific templates, snapshots, no open runtime generation | A template produces wrong grammar, tone, facts, speaker knowledge, or unsafe joke targets |
| R25 | Engine or rendering limits appear after content investment | Medium | High | M00 export spike; named target hardware; streaming and inventory prototypes | Export, 3D performance, tooling, platform support, or save I/O fails the foundation gate |
| R26 | Co-op forces a rewrite or service burden | High | Critical | Post-1.0 disposable spike; host authority evaluation; offline remains complete | Any pre-alpha system takes on server authority solely for hypothetical co-op |
| R27 | Live-content expectations become unsustainable | High | High | No monthly-zone promise; zone mutations and permanent rewards; measured cadence after 1.0 | Roadmap or marketing commits to cadence before production velocity is known |
| R28 | Humor erases sincerity or exhausts the tone | Medium | High | Sincerity holds, quiet time, character stakes, protected scenes, fatigue tests | Major emotional moments are immediately undercut or players describe the game as trying too hard |
| R29 | Hearthfold growth becomes a daily chore or destroys cherished loot | Medium | Critical | No daily cap or real-world timer; all tiers reachable below Exotic; atomic protected Reclamation | A player feels required to log in, feed a high-rarity item, or loses protected gear during an upgrade |
| R30 | Divine Tension becomes punishment under another name | Medium | Critical | Tension only creates optional content; tests forbid changes to baseline rewards, statistics, vendors, travel, saves, and zone access | Disagreeing with a god makes ordinary play weaker or blocks an area or build |
| R31 | Commentary selection becomes too complex or service-dependent | Medium | High | M02 local synthetic spike; indexed hard filters; deterministic tests; 2 ms provisional budget; no server dependency | The slice needs a remote service or misses its measured scheduling budget |
| R32 | Procedural loot breadth overwhelms authored quality | High | High | Curated laws, named synergies, deterministic seed galleries, source simulation, human review | Item count grows while build identity, text quality, or target routes become harder to understand |
| R33 | Living-world simulation becomes an MMO architecture project | High | Critical | Four local layers; aggregate populations; dirty-fact indexes; slice budgets; no network service | A milestone begins tracking thousands of offscreen actors or deploying server infrastructure before measured need |
| R34 | Situations become noisy, urgent chores | High | High | Zero-selection allowed; active and presentation budgets; category saturation; no real-time expiration | Players return to a wall of emergencies or feel punished for ignoring unaccepted content |
| R35 | Emergent NPC behavior becomes incoherent or unsafe | Medium | Critical | Authored interaction roles; typed relationship deltas; no generic intimacy, betrayal, or death; dossier validation | A character acts against their charter or an algorithm creates an irreversible relationship event |
| R36 | Offscreen simulation removes valued content | Medium | Critical | Game freezes while closed; no offscreen named death; preservation validator; service and reward successors | Return, rest, or travel removes a character, service, route, or unique source without direct preview and recovery |
| R37 | Memory and rumor data grows without bound | Medium | High | Typed summaries, counters, event-distance retention, hop limits, repository benchmarks, migration fixtures | Save size, query time, or migrations exceed budget or an old rumor creates a false current fact |
| R38 | NPC cast scope overwhelms the vertical slice | High | High | Two production social NPCs, shared specialist, reused conditional nemesis kit, data-only fixtures, M27 expansion | Character models, scenes, or voice needs delay the core combat and loot proof |

## Top five prototype killers

M00-M24 should treat these as release blockers:

1. Combat is not enjoyable before loot escalation.
2. Humor repeats, interrupts, or lacks consequence.
3. Spotlight coerces players away from the relaxed grind.
4. Loot cannot be understood or managed at the promised scale.
5. Saves can lose equipment, Hearthfold progress, or living-zone state.

## M00 evidence update, 2026-08-20

- R19 and R20: the first transactional save harness passed two commits, backup rotation, primary verification, intentional primary corruption, and backup recovery. This is foundation evidence only; large inventories, migrations, interruption tests, and long-lived profiles remain open.
- R25: Godot 4.7.2 stable imported the project, validated three JSON definitions, ran 20 assertions, and loaded the main scene in a bounded headless smoke on the development Mac. A signed universal macOS app exported and loaded; a Windows x86-64 PE artifact cross-exported. Native Windows execution and interactive performance remain open, so likelihood and impact are unchanged.
- R03 and R04: the spike establishes separate Herald and Picket presentation colors and two voice samples. It does not yet approach the repetition, interruption, blind-speaker, or 15-minute simulation gates.
- R17: movement, camera, attack query, and enemy seams now exist. No automated result can close combat-feel risk; an observed interactive playtest is still required.
- Newly observed tooling issue under R25: Godot can emit a parse error with exit code zero for a custom headless script. The check command now fails on engine and script error markers as well as nonzero exit status.

## First-person crawler pivot evidence, 2026-08-23

- R17: the exported macOS build completed a six-room expedition with three stopped-time combats, visible intentions, four party command sets, an environmental combination, a promoted encounter, rewards, and Hearthfold return. This proves the loop is operable, not that it is fun or deep enough. User play review and the 15-minute combat gate remain open.
- R18: visual inspection at default and expanded window sizes caught overlapping `PanelContainer` content, an overcrowded dungeon map, and clipped emissive colors. The layouts and lighting were corrected and reverified. More enemy groups, effects, accessibility scaling, and target hardware remain open.
- R25: Godot 4.7.2 imported and smoke-loaded the replacement first-person main scene, validated three items plus three enemies, passed 49 assertions, exported a 179 MB ad-hoc signed universal macOS app, and passed strict deep signature verification. Native Windows execution and measured frame time remain open.
- R03 and R04: M00 now demonstrates distinct Herald and Picket reactions across exploration, maintenance, combat, victory, defeat recovery, reward, and Hearthfold events. It does not yet satisfy the repetition, callback, blind-speaker, or interruption budgets.
- Newly observed process risk under R25: macOS may reuse an already-running build with the same bundle identifier after a new export. Export verification must close the prior process before relaunching or it can accidentally inspect stale gameplay.

## Review cadence

- Review the register at every release gate.
- Add evidence links, build IDs, owners, and due milestones when implementation begins.
- Close a risk only with measured evidence or an explicit scope removal.
- Do not lower likelihood merely because a milestone is late.
- If a mitigation adds more maintenance than the original risk, revisit the product promise instead of hiding the cost.
