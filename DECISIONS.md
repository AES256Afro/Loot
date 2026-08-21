# Decisions and Open Gates

## Decisions made for planning

| Topic | Current decision | Reason |
| --- | --- | --- |
| World structure | Persistent zones connected by anchors | Supports relaxed exploration and distinct ecology without timed floors. |
| Genre | Third-person 3D action RPG | Best fit for readable powers, gear, bosses, towns, and large zones. |
| Primary mode | Single-player offline first | Keeps the core game durable and prevents networking from blocking the slice. |
| Engine | Godot 4.7.2 stable with typed GDScript and GL Compatibility renderer | The local spike imports, validates content, passes deterministic and persistence tests, and loads its main scene. Export and interactive feel gates remain open. |
| Progression | Capped vertical ranks plus broad horizontal mastery | Supports long grinding without making old zones meaningless. |
| Inventory | Near-unlimited Archive plus a field workflow | Removes storage punishment while preserving readable moment-to-moment loot decisions. |
| Safe room | Persistent pocket interior reached through anchors | Makes the home follow the player without simulating a mobile building. |
| Stakes | Spotlight bonuses, promoted enemies, and Embarrassment Remnants | Gives humor consequence without timers, item loss, repair chores, or reduced baseline grinding rewards. |
| Spotlight rewards | Five positive-only expedition ranks with permanently banked threshold rewards | Ordinary play stays reward-complete and defeat risks only unfinished progress unless the player explicitly accepts a wager. |
| Companion | Picket, an original brass safety-inspector construct | Supplies utility, emotional continuity, and a countervoice to the Herald without copying an existing companion. |
| Humor | First-class mechanical and writing system | Callbacks, Accolades, Indignities, item appraisals, lair moods, and voice conflict are central to the requested experience. |
| Reward boxes | Earned Caches with visible pools and protection | Preserves exciting reveals without paid gambling or mystery keys. |
| Announcer | Authored, rule-driven Herald Engine | Reliable, localizable, testable, offline, and controllable by the player. |
| Commentary architecture | Local typed events, hard filters, deterministic scoring, and typed memories | Avoids runtime service dependencies and makes interruption, repetition, privacy, and callbacks testable. |
| Hearthfold progression | Expedition-driven Core ranks and horizontal room trees | Supports a massive long-term home without daily feeds, real-world construction time, room damage, or required high-rarity sacrifices. |
| Divine relationships | Persistent Recognition plus non-destructive Tension | Disagreement creates content and character without curses, decay, lost access, or vendor and loot penalties. |
| World simulation | Four local fidelity layers with aggregate populations and deterministic strategic turns | Produces living consequences without pretending 10,000 offscreen actors are continuously alive. |
| Offline world | Authoritative world, NPC, relationship, and situation state freezes while the game is closed | Removes login pressure and prevents the player returning to losses they could not observe or influence. |
| Memory Graph | Typed local records and bounded repository queries | Preserves relationship, rumor, causality, and callback power without requiring Neo4j or a network service. |
| Situation generation | Authored definitions, hard filters, deterministic relevance, active budgets, and recovery | Creates emergent combinations without free-form plots, expiring emergencies, or content lockout. |
| Named NPC simulation | Authored activity states, meaningful relationship edges, and protected successor contracts | Characters can move and change while services, rewards, and coherent characterization remain safe. |
| Monetization | Premium game, no paid randomized rewards | Matches the anti-frustration promise. |
| IP boundary | Original setting, names, characters, dialogue, items, and lore | Genre mechanics can inspire structure, but protected expression is not production content. |
| Co-op | Post-alpha feasibility gate | Avoids promising a second architecture before the solo game works. |

## Punishments excluded from the core game

The following supplied ideas are excluded from M00-M46 unless the user explicitly reopens them:

- Spotlight or ratings decay during ordinary play;
- reduced baseline loot, experience, Boss Seals, Recognition, story access, or vendor quality for low Spotlight;
- penalties for cautious play, retreating, fast travel, target farming, meta builds, repeated bosses, or taking time to explore;
- dropping an equipped item at the defeat location;
- gear durability, repair costs, or inactive broken equipment;
- inventory weight, movement penalties, or a hoarding tax;
- forced corpse runs;
- a requirement to die or take damage for session progress;
- real-world safe-room summon cooldowns;
- real-world daily, weekly, or seasonal progression loss;
- automatic consumption, sacrifice, deletion, or trophy retirement of owned items;
- daily offering, Reclamation, cultivation, relationship, or room-upgrade caps;
- real-world room construction, callback-retention, divine-hunger, or favor-decay clocks;
- Hearthfold invasions that damage, disable, or de-level rooms, anchors, residents, or stored items;
- required Exotic, Legendary, or Mythic sacrifice for ordinary room or divine progression;
- divine curses that delete items, disable zones, reduce base statistics, corrupt saves, or block ordinary travel;
- negative ratings or Spotlight points for fast travel, farming, build popularity, retreat, caution, or accessibility settings;
- zone mastery that requires death, damage taken, high Spotlight, speed, destructive choices, or avoiding fast travel;
- a remote commentary service, player-history server, account, Redis instance, or cloud model as a core solo dependency;
- authoritative world, NPC, relationship, rumor, or situation advancement while the game is closed;
- real-world NPC schedules, situation deadlines, weekend or holiday modifiers, post-update bonuses, or login-sensitive events;
- random offscreen named-NPC death, permanent departure, essential-service removal, or unique-reward loss;
- generic pairwise simulation that invents romance, coercion, irreversible betrayal, torture, or character death from numeric relationship values;
- dynamic vendor penalties based on Spotlight, recent death, build popularity, joke equipment, desperation, or real-world weekday;
- a required Neo4j, PostgreSQL, Redis, S3, cloud queue, read replica, or server-authoritative world for solo play;
- a 10,000-NPC target or millions of graph edges before local slice measurements justify that scale;
- situations that must generate a fixed count every tick or punish the player when ignored before acceptance;
- public death logs, clips, rankings, or social shame without a separate future privacy review and explicit opt-in.

Some pressure concepts may later be prototyped as clearly labeled, reversible challenge mutators. Such a prototype must use a disposable or isolated ruleset, preserve the ordinary save, keep unique rewards available elsewhere, and receive explicit approval after the vertical slice proves the relaxed loop.

## Assumptions to validate in the first prototype

1. Third-person over-the-shoulder combat is the desired camera rather than first-person.
2. The initial visual target should be stylized mid-detail 3D rather than photorealism or strict pixel art.
3. One character can unlock all Disciplines, with loadout commitment occurring per expedition.
4. The Hearthfold is entered through a short transition instead of existing as a physically seamless room behind every door.
5. Zones use authored macro layouts plus variable encounters and state, not fully procedural terrain.
6. Humor is entertaining when it reacts specifically, remembers selectively, changes real systems, and can be tuned rather than speaking continuously.
7. Players prefer a field overflow workflow to encumbrance or destructive item limits.
8. Targeted loot and bad-luck protection do not remove the thrill of rare drops.

## Decisions that should wait for evidence

- Exact visual art direction and character proportions.
- Whether combat uses stamina in addition to Drive and Strain.
- Exact number of active powers on controller.
- Class-swap restrictions outside safe areas.
- Voice production approach for the Herald Engine.
- Exact voice production split between the Herald, Picket, gods, lairs, bars, and text-only systemic reactions.
- Minimum PC specification and graphics tiers.
- Whether zone transitions can become seamless without harming content production.
- Whether optional hunger, survival, or extraction-style rules belong only in challenge mutators.
- Whether co-op is sustainable.
- Whether official mod tools are feasible before or after 1.0.

## Questions for the first user review

These do not block the planning foundation. They should be settled before visual production:

1. Should the default camera be third-person, first-person, or switchable?
2. Should the tone lean darker and more brutal, more absurd and colorful, or stay evenly split?
3. Is this intended primarily as a solo game, or is eventual co-op a must-have release requirement?
4. Do you prefer stylized 3D that a small team can produce at scale, or a more realistic look with fewer total assets?
5. Should gods be mostly optional build patrons, or central antagonists whose conflicts drive every zone?
