# Divine Covenants Specification

## 1. Purpose

Gods are strange powers with opinions, followers, conflicts, and build philosophies. They are not subscription meters disguised as characters. Divine relationships create new play styles, conversations, hunts, relic pursuits, and world choices without deleting items, decaying while the player is away, or making a zone miserable until a chore is completed.

The system uses two persistent values per discovered god:

- **Recognition, 0 to 100:** how fully the god knows and trusts this Claimant.
- **Tension, 0 to 100:** how interestingly the Claimant's recent choices conflict with the god's philosophy.

Recognition never decays. Tension is non-destructive and cannot reduce baseline combat statistics, loot, vendors, travel, story access, or another relationship. Tension creates dialogue, alternative offers, optional amends, rival attention, and unusual challenges.

## 2. Relationship model

```json
{
  "god_id": "god.ilex",
  "recognition": 52,
  "tension": 18,
  "milestones": ["contact", "correspondence", "covenant"],
  "completed_proofs": ["proof.closed_loop"],
  "active_minor_favor": false,
  "active_major_covenant": true,
  "known_offering_tags": ["precise", "recovered", "documented"],
  "pending_opportunities": [],
  "last_interaction_sequence": 8872
}
```

All advancement uses game events and event sequence, not wall-clock time. A profile can be ignored for a year and return with the same Recognition, Tension, opportunities, and covenant access.

## 3. Recognition thresholds

| Recognition | State | Unlock |
| ---: | --- | --- |
| 0 | Unknown | Shrines can be discovered, but the god does not address the player directly |
| 10 | Contact | Introductory exchange, offering preferences, first optional proof |
| 25 | Correspondence | Minor Favor candidates, envoy scenes, one targeted pursuit |
| 50 | Covenant | Major Covenant candidates and first relic route |
| 75 | Envoy | Cross-zone intervention, advanced covenant node, Guest Wing visits |
| 100 | Audience | Capstone scene, signature cosmetic set, alternate relic pursuit |

Threshold rewards are permanent unlocks. Spending currency, changing covenants, or disagreeing with a god does not revoke them.

Recognition comes from a god's authored action vocabulary. Examples include resolving an event in a compatible way, discovering a shrine, completing a proof, equipping and using a favored mechanical tag, helping a follower, offering an appropriate item, or mediating a divine conflict.

Repeated trivial actions have diminishing Recognition after a per-content completion cap. Ordinary grinding remains useful for loot and mastery, but cannot automate an entire relationship through one repeated input.

## 4. Offerings

Offerings are voluntary, previewed transactions. A god prefers semantic tags, histories, and completed deeds, not simply the most expensive rarity.

Examples of offering tags:

- `precise`, `repaired`, `documented`, `overgrown`, `sheltering`;
- `first_attempt`, `last_survivor`, `merciful`, `improvised`, `unclaimed`;
- zone ecology samples, completed contracts, crafted tokens, duplicate items, or story objects marked as offerable copies.

Every offering preview shows:

- exact Recognition or opportunity progress;
- Tension change, if any;
- whether the item is reconstructable;
- whether the item is a favorite, lock, loadout member, best copy, or only curated copy;
- any new dialogue, proof, or cosmetic unlocked.

Legendary and Mythic items are never required. Any progression value expressible through rarity must also be achievable through tagged deeds, crafted offerings, zone materials, or lower-rarity items. Offering a high-rarity duplicate may accelerate a route, but cannot unlock an exclusive covenant or ending.

## 5. Tension

Tension is narrative and mechanical friction without punishment.

### 5.1 What raises Tension

- publicly choosing a rival god's solution to a shared event;
- repeatedly using a play style opposite the active covenant's thesis;
- refusing an accepted optional proof after entering its encounter;
- making a demigod succession choice the god dislikes;
- using a divine relic in a deliberately contradictory way.

There is no Tension for inactivity, difficulty settings, accessibility features, fast travel, farming, build popularity, refusing an unaccepted offer, changing commentary settings, or playing offline.

### 5.2 Tension bands

| Tension | Presentation | Available response |
| ---: | --- | --- |
| 0 to 24 | Amused notice | New lines and optional explanations |
| 25 to 49 | Productive disagreement | Alternate proof, debate scene, or tagged offering |
| 50 to 74 | Open contradiction | Rival offer, mediation contract, or covenant remix |
| 75 to 100 | Fascinating impasse | Capstone conflict scene with several valid resolutions |

At high Tension, the god may be sarcastic, send an envoy, stage an optional challenge, or offer a deliberately awkward variation of a power. It may not corrupt equipment, delete items, disable a zone, reduce drops, block saving, damage the Hearthfold, or impose real-time demands.

### 5.3 Resolving Tension

The player may:

- complete an optional amends proof;
- offer tagged deeds or ordinary items;
- debate through an envoy scene;
- mediate with a rival;
- deliberately keep the Tension and pursue its contradiction route.

Contradiction is a valid relationship state with its own conversations and sidegrades. Clearing Tension is never the only path to the god's build-defining content.

## 6. Covenant loadout

A profile may know every discovered covenant while equipping:

- one **Major Covenant**, which supplies a signature mechanic and two to four nodes;
- one **Minor Favor**, which supplies a focused utility or build hook from another god.

The Hearthfold divine alcove and compatible shrines allow swapping. A swap requires leaving combat and confirming any loadout incompatibilities. There is no permanent lock, lost Recognition, favor debt, monetary fee, or real-world cooldown.

Major Covenants contain an explicit play-style exchange. The player gains an unusual verb or conversion and accepts a loadout constraint while it is equipped. Removing the covenant removes both sides of that exchange. It never permanently damages the character.

Examples of healthy exchanges:

- convert one resource into another but change how it is restored;
- gain an alternate trigger that occupies a power slot;
- intensify a status while preventing a second status from being applied by the same hit;
- gain a movement action that replaces the covenant's defensive action;
- route excess healing into a construct while reducing the construct's duration.

## 7. Initial divine roster

### 7.1 Ilex, God of Useful Mistakes

**Thesis:** improvisation, recovery, ricochets, corrected plans, and errors that become ingredients.

- **Recognized actions:** recovering through a different tactic after a failed attempt, discovering a useful ricochet, turning a resisted effect into another interaction, repairing a failed craft, and resolving an event through an improvised route.
- **Offering tags:** improvised, repaired, misprinted, recovered, unintended.
- **Minor Favor, Margin Note:** once per encounter, the first fully resisted support effect leaves a visible Correction mark. A different effect may consume it for a small utility refund.
- **Major Covenant, Second Draft:** blocked, resisted, expired, or environmentally deflected actions can create one of three capped Draft errors. A different action family consumes a Draft to add a chosen support effect. Ordinary successful play also creates periodic Drafts, so intentional failure is never required.
- **Exchange:** the covenant occupies one passive-law slot and rewards adapting across action families. Repeating one failed input cannot create more Drafts or Recognition.
- **Tension route:** excessively exact or repeated solutions attract optional correction audits that remix one encounter rule and award research tokens.
- **Intervention:** reveals how one failed world-state proposal could be repaired into a different valid option.
- **Relic direction:** a weapon law that captures one harmless deflection tag and converts it into a later positioning or resource effect, never duplicated damage.

Ilex speaks like an accident investigator who desperately wants the accident to be promoted into official procedure.

### 7.2 Morrow-in-Arrears, Keeper of Useful Debts

**Thesis:** delayed power, promises, repayment, and the tactical value of owing something on purpose.

- **Recognized actions:** completing deferred objectives, rescuing indebted NPCs, taking a reward later for a better choice, repaying marked combat resources through skill.
- **Offering tags:** promised, recovered, deferred, witnessed, returned.
- **Minor Favor, Grace Period:** once per encounter, spending the last charge of a utility power grants a brief window in which its recovery begins faster after a successful evade.
- **Major Covenant, On Account:** selected powers may borrow a portion of their resource cost. Borrowed cost becomes visible Arrears, repaid by landing varied attacks or completing an encounter. Arrears cannot reduce health, lock powers, or persist after returning to safety.
- **Exchange:** borrowing is capped and changes the optimal action sequence; it does not create a permanent debt ledger.
- **Tension route:** refusing repayment opportunities unlocks optional collectors who offer stranger repayment challenges and equivalent rewards.
- **Intervention:** converts an expiring zone opportunity into a persistent contract the player may complete later.
- **Relic direction:** armor that stores a capped portion of overpaid resource and releases it on a different power family.

Morrow treats every conversation as a cordial negotiation that began several centuries before the player arrived.

### 7.3 Saint Nobody, Patron of the Uncredited

**Thesis:** anonymity, assistance, decoys, and victories that do not need a statue.

- **Recognized actions:** helping neutral groups, redirecting danger, completing unseen optional objectives, allowing an ally or ecology actor to finish a plan.
- **Offering tags:** unclaimed, anonymous, sheltering, shared, overlooked.
- **Minor Favor, No Need to Mention It:** the first support effect applied to a non-summoned ally in an encounter also grants a small utility charge.
- **Major Covenant, Missing Credit:** placing a decoy or support construct transfers selected threat and one compatible trigger to it. The player's direct critical bonuses are converted into construct utility while active.
- **Exchange:** the covenant trades personal burst emphasis for positioning and indirect control.
- **Tension route:** seeking public credit causes the Herald and Saint Nobody to argue over attribution, unlocking spectacle objectives that still preserve covenant access.
- **Intervention:** creates an unnoticed evacuation or alternate entrance during a zone crisis.
- **Relic direction:** boots that let a dodge leave a false action trace which enemies investigate.

Saint Nobody's shrines insist they are ordinary pieces of wall and become offended if admired too accurately.

### 7.4 The Orchard Crown, Sovereign of Grafts

**Thesis:** growth through combination, ecological succession, and useful things becoming alarmingly alive.

- **Recognized actions:** combining status families, repairing habitat chains, cultivating mutations, choosing successor states that preserve diversity.
- **Offering tags:** overgrown, grafted, cultivated, symbiotic, seasonal in fiction only.
- **Minor Favor, Volunteer Root:** applying two distinct non-damaging statuses to one enemy grows a short-lived pickup that restores a small amount of Drive.
- **Major Covenant, Grafted Habit:** select two compatible status tags in the Hearthfold. Alternating them grows a three-stage combat organism with a chosen utility at maturity.
- **Exchange:** repeating one selected status resets growth, so the covenant rewards intentional alternation rather than raw frequency.
- **Tension route:** scorched or heavily engineered solutions produce optional hybrid growths, new dialogue, and alternate cosmetics instead of reducing favor.
- **Intervention:** introduces a reversible ecology candidate into a zone-state decision.
- **Relic direction:** a living focus whose law changes presentation and support behavior according to the last three status tags used.

The Orchard Crown is regal, fecund, and perpetually disappointed that everyone keeps distinguishing architecture from salad.

### 7.5 Lady Lastlight, Curator of Endings

**Thesis:** finishers, final chances, mercy, and making the last action count.

- **Recognized actions:** resolving boss succession, saving an endangered actor at low resources, ending a chain cleanly, choosing mercy when it creates a harder future.
- **Offering tags:** final, merciful, extinguished, remembered, last_survivor.
- **Minor Favor, Afterglow:** completing an encounter with a different power family than the one that opened it grants a brief out-of-combat movement flourish and recovery pulse.
- **Major Covenant, One Good Ending:** mark one finisher family. It gains a conditional effect against prepared targets, but only after two other action families have contributed to that target.
- **Exchange:** raw finisher repetition is weaker than building a deliberate ending through varied setup.
- **Tension route:** abandoning conclusions creates optional Unfinished Scenes, compact encounters that ask the player to choose among several endings.
- **Intervention:** preserves one defeated boss lineage as a future successor instead of erasing its content.
- **Relic direction:** a blade or focus that stores the tags of an encounter's opening actions and alters its final compatible strike.

Lady Lastlight speaks with solemn ceremony about ridiculous small endings, including the final cracker in a box.

### 7.6 The Small Door

**Thesis:** thresholds, shortcuts, spaces larger inside, and the suspicion that every wall is being unreasonable.

- **Recognized actions:** finding secret routes, opening paths for settlements, escaping without teleporting through active danger, stabilizing anchors.
- **Offering tags:** hidden, carried, hinged, impossible_geometry, returned.
- **Minor Favor, Unreasonable Wall:** discovered traversal secrets appear on the local map after the player passes near their alternate side.
- **Major Covenant, Pocket Exit:** equip a short-range threshold action that passes through one compatible obstacle or relocates to a placed doorway marker.
- **Exchange:** Pocket Exit occupies the normal covenant defense action and cannot cross encounter boundaries, sealed objectives, or undiscovered world gates.
- **Tension route:** repeatedly choosing the obvious entrance produces optional architectural objections and absurd alternate rooms.
- **Intervention:** reveals a temporary route candidate that becomes permanent only through the associated zone objective.
- **Relic direction:** a shield or tool that stores one traversed obstacle tag and converts it into a later positioning option.

The Small Door communicates through labels, hinges, knocks, and notices explaining that it is not small, merely surrounded by excessive wall.

## 8. Divine conflicts

When two gods care about a zone decision, the player receives at least three valid approaches:

1. support one proposal;
2. support the rival proposal;
3. mediate, delay, combine, or observe when authored state allows it.

The preview distinguishes known consequences from uncertain ones. Choosing one god may raise Tension with another, but cannot erase Recognition, equipment, shrines, or completed story. Rival conflict generates future content through envoys, altered events, successor candidates, covenant remixes, and commentary.

There is no global divine alignment that makes all other gods hostile. A player can maintain contradictory relationships because the conflict is part of the intended comedy and build space.

## 9. Divine interventions

Interventions are authored opportunities, not random punishments. They must be one of:

- **Offer:** an optional temporary rule and previewed extra reward;
- **Rescue:** an alternate recovery path that never makes the baseline state worse;
- **Complication:** a voluntary Spotlight or covenant challenge accepted before it changes the encounter;
- **Proposal:** a possible living-zone transition;
- **Audience:** a relationship scene or proof;
- **Rivalry:** several mutually clear divine options.

Ignoring an intervention closes or defers that opportunity without lowering Recognition or ordinary rewards. Time-sensitive presentation may use in-game encounter windows, but no offer expires because the application was closed.

## 10. Commentary rules

Each god has a voice charter defining motive, sentence shape, targets, emotional range, prohibited joke structures, sincerity behavior, and relationship knowledge. Gods may answer the Herald, Picket, a lair, or one another through authored exchanges.

Divine lines obey commentary frequency, profanity, teasing, subtitle, voice, streamer-safe, and sincerity-hold settings. A god cannot bypass muted dialogue because the fiction says it is powerful.

Relationship lines query typed facts only. Gods do not inspect microphones, player chat, local files, contacts, or external activity.

## 11. Validation and tests

Automated tests must prove:

- offline time never changes Recognition, Tension, opportunities, or offering efficiency;
- no Tension band modifies baseline rewards, combat stats, vendors, travel, saves, or zone access;
- every Recognition threshold is reachable without offering Exotic, Legendary, or Mythic items;
- a covenant swap preserves all relationships and owned relics;
- offering protections match Reclamation protections and roll back atomically on save failure;
- each Major Covenant event chain terminates within its recursion budget;
- accessibility and commentary settings never enter relationship scoring;
- every divine conflict keeps at least one nonexclusive continuation route;
- ignoring an unaccepted intervention cannot create negative state;
- all relics have a non-random protection or direct-choice route.

Playtest acceptance:

- players can describe each god's play philosophy without seeing the name;
- the active covenant changes decisions, not merely damage totals;
- Tension feels like more character and content, not a concealed reputation penalty;
- changing patrons feels inviting enough to encourage build experiments;
- gods remain optional for ordinary zone completion and baseline target farming;
- jokes do not obscure offering loss or covenant exchange rules.

## 12. Vertical slice and alpha scope

The Gutterbloom vertical slice includes one distant divine signal or shrine teaser with no full covenant. Public alpha implements the six gods in this document, one Major Covenant and one Minor Favor each, two divine conflicts, six relic pursuits, offering protections, Tension routes, and Guest Wing visits.

Additional gods from the content catalog remain planned content. Their production depends on the six initial voices and mechanics passing comprehension, balance, and repetition tests.

## 13. Deferred decisions

- whether all six initial gods appear before the second zone;
- final Recognition award values and repeat caps;
- whether Tension should have a player-facing number or descriptive band only;
- how many covenant nodes can be equipped at Envoy and Audience;
- whether major covenant swaps are allowed at settlement shrines as well as the Hearthfold;
- how divine relationship state is represented in a future co-op mode.
