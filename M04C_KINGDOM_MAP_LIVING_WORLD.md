# M04C Kingdom Map and Living-World Proof

## Player promise

The first-person crawler is a dangerous place inside a larger world. The party travels across persistent top-down kingdom maps, enters explorable settlements and social spaces, and descends through visible sites into first-person procedural dungeons. Party state, loot, quests, information, relationships, and exact return position survive every transition.

The proof borrows the readable adventure-map structure of turn-based strategy games without copying protected maps, interface, art, terminology, factions, or lore. Travel never uses a real-world clock, mandatory end-turn wait, hunger, stamina, encumbrance, mount fuel, item loss, or expiring quest.

## World scales

1. **World Atlas:** kingdom identities, borders, major routes, and future destinations.
2. **Kingdom Map:** a seeded hex adventure map with terrain, roads, sites, patrol information, resources, quests, events, and fog of discovery.
3. **Settlement Map:** closer top-down movement among stores, guild halls, bars, safe rooms, information sources, and social areas.
4. **Dungeon or Lair:** the existing first-person shaded-pixel crawler and stopped-time combat.
5. **Hearthfold:** the persistent portable refuge connected to discovered anchors and the kingdom map.

## Strategic Pulse

Travel is deliberate but not rationed. Committing a route, resolving a site, resting, or completing a major transition advances a deterministic Strategic Pulse. The player can continue moving without an arbitrary movement-point cap. The simulation remains frozen while the game is closed, and unaccepted situations cannot expire or remove essential content.

## Gutterbloom Reach proof

M04C implements one compact kingdom region containing:

- one deterministic hex map with six terrain families, roads, a visible jurisdiction border, fog of discovery, and inspectable information;
- Latchmarket Edge as an explorable top-down settlement;
- the Bent Pipe social entrance, a general store, the Delvers Registry guild hall, a safe anchor, a contract board, a rumor kiosk, and a civic social plaza;
- four resource, event, lore, shrine, caravan, or route sites;
- the Courtesy Drain as a visible entrance into the existing first-person six-room crawler;
- six authored quests or contracts represented by one complete accepted and completable vertical route plus supporting definitions;
- deterministic World Marginalia, internally called Lore Sauce, assembled only from authored and tagged fragments;
- a persistent exact return hex after town, Hearthfold, and dungeon transitions.

## Information contract

Every site identifies its source and confidence as observed, confirmed, reported, inferred, folklore, disputed, or outdated. Critical mechanical rules, safety states, target sources, store prices, rewards, and quest requirements never depend on unlabeled rumor text.

## Acceptance route

M04C is complete when an exported macOS build can:

1. restore or create the persistent Gutterbloom Reach state;
2. travel across a hex route without a movement-point cap;
3. discover a resource site, claim its full reward once, and retain it in aggregate storage;
4. enter Latchmarket Edge and move a visible four-person party around its top-down map;
5. inspect the store, guild hall, Bent Pipe, safe anchor, contract board, and rumor kiosk;
6. accept the Courtesy Drain Survey with visible reward and consequence information;
7. discover deterministic Lore Sauce with a provenance label and permanent journal entry;
8. enter the Courtesy Drain from its kingdom hex;
9. complete or return from the first-person dungeon without losing party, Archive, relationships, quest, or world state;
10. return to the exact dungeon entrance hex and resolve the accepted contract;
11. save, restart, and retain map discovery, resources, lore, quest state, purchases, Strategic Pulse count, and active presentation mode;
12. pass automated checks, native macOS inspection, exports, fresh-checkout proof, and remote `main` publication.

## Explicit exclusions

- No player kingdom conquest, army management, city construction, diplomacy AI, or tactical army battle system in this proof.
- No seamless continent streaming or procedural terrain generation.
- No real-world schedules, quest expiration, resource decay, store refresh timers, or offline world advancement.
- No second top-down combat system. World encounters continue into the established first-person stopped-time party presentation.
- No resource weight, field capacity, destructive overflow, durability, travel stamina, or mandatory transport cost.

## Implemented proof notes

- World state is embedded in the existing atomic profile instead of using a parallel save.
- Old crawler profiles receive a normalized default kingdom state while retaining party, inventory, equipment, dungeon, and recurring-actor progress.
- All 140 map cells are deterministic for the authored kingdom seed. Named geography, sites, roads, and service identities remain authored.
- World actions use immutable IDs and deterministic outcomes. Lore selection avoids repeats while undiscovered fragments remain.
- The live UI uses a shaded low-resolution strategic palette, explicit fog, roads, jurisdiction tinting, site symbols, and a visible four-person marker.
- Latchmarket is a separate top-down presentation with keyboard movement, click-to-approach, nearby interaction, and an accessibility shortcut for each service.
