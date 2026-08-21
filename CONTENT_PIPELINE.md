# Content and Item Pipeline

## 1. Purpose

The content pipeline must support a huge loot catalog without pretending that millions of random number combinations are millions of meaningful items. It separates authored identity, controlled procedural variety, player-owned state, and reward-source rules. Every generated object must be reproducible, explainable, searchable, and safe to migrate.

The pipeline serves five goals:

1. Build-defining laws remain authored and testable.
2. Procedural affixes create breadth within controlled compatibility rules.
3. Target farming and bad-luck protection remain visible.
4. Item humor remains grammatical and specific.
5. Spotlight can add rewards but can never worsen or rewrite the baseline roll.

## 2. Definitions, instances, and ledgers

### 2.1 Content definitions

Definitions are immutable, versioned resources loaded by `ContentRegistry`. Each has a stable namespaced ID, schema version, localization keys, controlled tags, compatibility declarations, and validation metadata.

Primary definition types:

- `ItemBaseDefinition`
- `MaterialDefinition`
- `AffixDefinition`
- `LawDefinition`
- `NamedSynergyDefinition`
- `AppearanceDefinition`
- `LootSourceDefinition`
- `LootTableDefinition`
- `CacheDefinition`
- `DescriptionTemplateDefinition`
- `RecipeDefinition`
- `ReconstructionDefinition`

Definitions never contain player ownership, random rolls, favorite state, or a current zone pointer.

### 2.2 Item instances

An item instance stores only resolved output and player state:

```json
{
  "instance_id": "item_01J...",
  "schema_version": 3,
  "generation_version": 2,
  "generation_seed": 918273645,
  "base_id": "weapon.polearm.sluice_hook",
  "rarity": "rare",
  "item_level_band": 4,
  "quality": 0.72,
  "material_id": "material.gutter_bronze",
  "affixes": [
    { "id": "affix.braced", "roll": 0.61 },
    { "id": "affix.eelwise", "roll": 0.88 }
  ],
  "law_id": null,
  "named_synergy_id": "synergy.responsible_hook",
  "appearance_id": "appearance.gutter_bronze.green",
  "origin": {
    "source_id": "enemy.sump_knight",
    "zone_id": "zone.gutterbloom",
    "world_seed": 1455,
    "event_sequence": 8821
  },
  "favorite": false,
  "locked": false,
  "tags": [],
  "loadout_ids": []
}
```

### 2.3 Reward ledger

Pity, first-kill guarantees, attunement, duplicate conversion, and direct-choice progress live in a separate `RewardLedger`. Regenerating or migrating an item cannot alter the ledger. The ledger records source, pool, eligible attempts, guarantee counters, last awarded unique IDs, and audit sequence.

## 3. Authoring schemas

### 3.1 Item base

An item base declares:

- slot, family, weapon shape, damage or defense vocabulary;
- item-level bands and implicit property curves;
- allowed material, affix, law, and appearance tags;
- required and forbidden equipment tags;
- socket policy and upgrade policy;
- short name, full name pattern, appraisal key, icon, and model;
- acquisition categories and reconstruction eligibility;
- animation, hand, collision, and attachment requirements;
- validation scenes and comparison archetype.

### 3.2 Affix

An affix declares:

- semantic effect component and numeric curve;
- prefix, suffix, or hidden-support presentation;
- tier bands and rarity budget cost;
- required, forbidden, and granted tags;
- one or more exclusivity groups;
- stacking rule, cap, and rounding policy;
- description token and grammar role;
- combat trace assertions and property-test domain.

Exclusivity groups handle broad incompatibilities such as `damage_conversion`, `primary_trigger`, `resource_replacement`, or `movement_mode`. Tag rules handle local compatibility. Authors should not maintain an unbounded matrix of every affix pair.

### 3.3 Curated law

A law is a build-changing rule, not a large stat roll. It declares:

- event subscriptions and action outputs;
- explicit timing, ordering, caps, and recursion guards;
- compatible slots, families, Disciplines, and status vocabularies;
- user-facing rule text and expanded inspector explanation;
- simulation test scenes;
- rarity, source, and reconstruction policy;
- presentation hooks that do not affect the deterministic result.

### 3.4 Named synergy

A named synergy promotes a compatible combination of base, material, and affixes into a recognizable item identity. It can supply a curated full name, appraisal, appearance variant, support effect, and collection entry.

Promotion rules are deterministic once the component set is resolved. A promotion may require an exact component set, a minimum roll band, a source tag, or a discovered recipe. It may not depend on wall-clock time, online state, or Spotlight.

Named synergy effects fit inside the source's reward budget. Promotion is a pleasant discovery, not a hidden reason the same inputs sometimes lose power.

### 3.5 Loot source

A loot source declares:

- source category, zone, World Temper band, and encounter budget;
- allowed tables and family weights;
- published baseline quantities and rarity bands;
- unique pool and direct-choice currency;
- first-clear, pity, and duplicate rules;
- attunement interaction;
- separate optional bonus hooks;
- telemetry label and deterministic test seeds.

The inspector can answer, "Why did this drop?" and "Where can I pursue another?" from source data and the reward ledger.

## 4. Deterministic generation stages

Each reward uses named random streams derived from a root reward seed. Adding a visual roll later cannot change rarity or affixes in old saves.

1. **Resolve source budget.** Load the encounter, source, Temper, first-clear, contract, and target-farm rules.
2. **Resolve baseline quantity.** Determine the published ordinary drops before any Spotlight bonus.
3. **Resolve rarity.** Apply the source band, progression cap, and baseline pity ledger.
4. **Choose base family and base.** Apply source identity, attunement, discovered-pool rules, and duplicate protection.
5. **Choose material and quality.** Use base-compatible material tags and rarity budget.
6. **Allocate affix budget.** Determine affix slots and tiers from rarity and source budget.
7. **Select affixes.** Apply tags, exclusivity groups, caps, and deterministic weighted choices.
8. **Promote named synergy.** Evaluate compatible authored promotion rules.
9. **Attach curated law.** For eligible rarities and sources, choose a validated law within budget.
10. **Resolve numeric values.** Roll each curve using an affix-specific stream.
11. **Resolve sockets and upgrades.** Apply base and source policies.
12. **Resolve appearance.** Choose a compatible presentation with a presentation-only stream.
13. **Compose name and description.** Use grammar-constrained authored tokens.
14. **Record origin and audit.** Store source, seeds, content versions, and reward-ledger changes.
15. **Validate instance.** Reject impossible or out-of-bound output before ownership changes.
16. **Run separate bonus pipelines.** Spotlight, contracts, events, or covenant bonuses may create additional labeled rolls. They cannot mutate stages 1 through 15.

If generation fails validation, the system produces a deterministic safe fallback from the same source and logs the rejected definition. It never silently grants nothing.

## 5. Baseline and bonus separation

Every reward presentation groups output by cause:

- **Source reward:** published ordinary drops.
- **First-clear or pity guarantee:** ledger-backed protection.
- **Contract reward:** previewed objective output.
- **Spotlight bonus:** extra roll or choice from the completed rank.
- **Covenant opportunity:** an optional additional interaction.
- **World-state result:** ecology, faction, or successor output.

Spotlight never changes baseline rarity weights, removes a baseline item, changes vendor prices, accelerates ordinary pity, or modifies a generated instance. A player at zero Spotlight receives the complete source reward.

## 6. Rarity budgets

Rarity determines complexity and authored identity, not merely larger numbers.

| Rarity | Standard affixes | Special behavior | Authoring expectation |
| --- | ---: | --- | --- |
| Worn | 0 | Strong base identity or amusing drawback-free quirk | Readable immediately |
| Common | 0 to 1 | Stable implicit | Dependable comparison baseline |
| Fine | 1 to 2 | Better tuning range | First intentional combinations |
| Rare | 2 to 4 | One special affix possible | Targetable build support |
| Exotic | 2 to 4 | Curated behavior or named synergy | Authored interaction test |
| Legendary | Supporting affixes | One defining law | Dedicated acquisition and description |
| Mythic Relic | Curated support set | One exceptional law with meaningful loadout cost | Quest or boss pursuit plus protection |

World Temper may widen roll bands and introduce new compatible affix tiers. It cannot make an item's rule text lie or obsolete a curated law through raw scaling.

## 7. Target farming and protection

Each build-defining item has at least two acquisition paths by the time its associated zone is complete:

- a narrow named source or event pool;
- Boss Seals, Echo Shards, a covenant pursuit, crafting reconstruction, or an Archive-attuned route.

Protection rules:

- the UI publishes eligible pools after discovery;
- every eligible miss advances a visible counter;
- a guarantee awards a direct choice, not merely another unrestricted roll;
- duplicate curated uniques convert to Echo Shards unless the player chooses to keep the copy;
- the best owned roll remains protected in Reclamation by default;
- a curated unique can be reconstructed after discovery at a published baseline;
- balance patches migrate laws while preserving ownership and cosmetic history.

Cache openings use the same pipeline and ledger. Caches open without paid keys and expose pools, guarantees, duplicate behavior, and current protection before confirmation.

## 8. Naming and description grammar

Items carry both `short_name` and `full_name`. Compact UI uses the short name; inspection and announcements may use the full name. Names are never cut at an arbitrary character count to solve layout.

Composition order:

1. curated unique or named-synergy override;
2. quality or personality prefix;
3. base noun;
4. material or source suffix;
5. optional epithet reserved for notable origin events.

Description layers:

- **Rule:** exact mechanics in controlled vocabulary.
- **Explanation:** ordering, caps, and interactions.
- **Appraisal:** one authored joke or world detail tied to the item.
- **Origin:** source, zone, first owner event, and any promoted-enemy history.
- **Collection:** discovery and reconstruction state.

Procedural appraisals use curated grammar slots with compatible subject, verb, object, tense, plurality, tone, and speaker tags. They cannot assemble free text by blindly concatenating fragments. Every realized sentence must pass snapshot review.

Humor must never hide a limitation, convert a percentage into vague prose, or mock an accessibility setting. The joke follows the useful fact.

## 9. Content authoring workflow

1. Create or revise a definition with a stable content ID.
2. Run schema and reference validation.
3. Generate a deterministic seed gallery across legal rarity and Temper bands.
4. Run effect-component unit and property tests.
5. Open outputs in the Loot Laboratory for readability, model, icon, animation, and comparison review.
6. Run Monte Carlo source simulation and compare against published tables.
7. Review names and descriptions in compact, controller, subtitle, and localization stress layouts.
8. Add migration behavior if a shipped definition changed.
9. Approve the item for a source only after acquisition, duplicate, Reclamation, and reconstruction rules exist.

The authoring report rejects definitions with missing localization keys, orphaned sources, circular references, impossible tag requirements, unbounded effects, missing fallback assets, or absent test scenes for laws.

## 10. Quality gates

### 10.1 Schema and reference tests

- all IDs are unique, stable, namespaced, and referenced successfully;
- all content tags come from controlled registries;
- every loot table resolves to at least one legal result in each declared band;
- every curated unique has source, duplicate, reconstruction, and Reclamation policies;
- each definition can round-trip through canonical serialization.

### 10.2 Property tests

- generation with the same version, seed, source, and ledger state is identical;
- presentation stream changes cannot affect gameplay output;
- no affix exceeds its cap or violates an exclusivity group;
- law event chains terminate under declared recursion budgets;
- a fallback always exists for every source;
- Spotlight on or off leaves the baseline results byte-for-byte identical;
- a pity counter reaches its published direct-choice threshold;
- a migration preserves ownership, identity, player tags, and valid rolls.

### 10.3 Statistical tests

For each release candidate, fixed-seed simulations report:

- rarity and family distribution by source and Temper;
- time-to-target percentiles with and without attunement;
- pity activation rates;
- duplicate rates and Echo Shard income;
- Reclamation and crafting faucet-to-sink projections;
- invalid-generation and fallback frequency;
- contribution of baseline, Spotlight, contract, and covenant reward lanes.

Tests use confidence intervals and declared tolerances. A million simulated drops are evidence about the algorithm, not a marketing claim about authored content count.

### 10.4 Human review

- a tester can explain an item's law after one inspection;
- comparisons identify behavior differences, not only score arrows;
- a desired item has a discoverable pursuit route;
- low-rarity drops remain readable and occasionally charming;
- unusual combinations create builds without producing an obvious universal best item;
- opening a Cache is exciting without hiding odds or creating purchase pressure.

## 11. Vertical slice content target

The first slice implements the full pipeline with a deliberately narrow library:

- six weapon bases and four armor bases;
- four materials;
- 24 standard affixes and four special affixes;
- six curated laws;
- four named synergies;
- two earned Caches;
- the Rain Treasurer and Courtesy Drain source tables;
- one Archive attunement;
- one pity counter and one direct-choice purchase;
- 24 low-rarity appraisals and six curated item descriptions.

This target is large enough to test interactions and small enough for every output to receive human review.

## 12. Deferred decisions

- exact rarity probabilities and affix counts;
- whether an item level number is shown or represented only as a band;
- the final rule for retaining multiple duplicate curated uniques;
- the number of support affixes on Mythic Relics;
- how community build exports represent unshipped or migrated content;
- whether approved mod content can use the same registry after the post-1.0 feasibility gate.
