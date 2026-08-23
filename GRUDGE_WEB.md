# The Grudge Web

## Purpose

The Grudge Web turns selected enemies into recurring people without making every rat a novelist or every expedition a mandatory revenge appointment. A recurring actor can hate the party, fear it, admire it, exploit it, bargain with it, work for it, befriend it, or hold several of those positions at once. “Nemesis” is ordinary descriptive language in the fiction. The system itself is called the Grudge Web so its design is not trapped inside permanent hostility.

The goal is a world where the Pipe Goblin defeated under a broken cistern can later appear behind a stronger foreman, insist it has learned from the incident, then abandon that foreman when a flood threatens both sides. None of those turns are arbitrary. Each requires an authored motive, remembered fact, current situation, and legal role at the destination.

## Core principles

1. **Recurrence supplements the current story.** A returning actor can complicate a route, add a negotiation, replace one optional encounter, join a boss, offer help, or create a side objective. It cannot silently replace the critical quest or lock the player out of a zone.
2. **Defeat is not always death.** Eligible enemies may flee, yield, be recovered by allies, dissolve into a reconstructible state, or be presumed dead until evidence says otherwise. The outcome is shown to the player. The system never retroactively declares an explicitly killed actor alive without an authored explanation.
3. **Memory is factual and bounded.** Actors remember typed summaries such as place, attacker, finishing action, damage type, mercy, humiliation, bargain, rescue, stolen object, spared ally, and witnessed party member. They do not retain raw combat transcripts.
4. **Growth stays local.** A recurring rival gains a small zone-relative budget, one or two inspectable techniques, visual marks, and possibly a relationship. It does not scale infinitely with the player or become stronger merely because real-world time passed.
5. **Alignment can change.** Greed, survival, status, loyalty, curiosity, fear, misinformation, debt, shared danger, ideology, and affection can pull an actor toward or away from conflict.
6. **Dialogue is gameplay.** Speech can control initiative, targeting, reinforcements, surrender, neutral ground, bribes, information, temporary alliances, and combat exit. The player always sees the important inputs before committing.

## Recurring actor record

Each promoted actor receives a stable identity and a compact record:

```json
{
  "actor_id": "actor.rival.gutterbloom.example",
  "origin_definition_id": "enemy.gutterbloom.pipe_goblin",
  "display_name": "Clasp, Assistant Valve Mayor",
  "state": "active",
  "current_place_id": "place.gutterbloom.dry_boot_yard",
  "current_role": "reluctant_informant",
  "motive_id": "motive.survive_the_auditor",
  "growth_budget": 2,
  "technique_ids": ["technique.rival.backflow_feint"],
  "appearance_marks": ["mark.cracked_wrench", "mark.moss_burn"],
  "relationship_edge_ids": [],
  "remembered_event_ids": [],
  "appearance_count": 2,
  "last_appearance_game_turn": 47,
  "interruption_budget_spent": 1
}
```

The record references EventSummaries and relationship edges already defined by the local Memory Graph. It does not create a second social database.

## Relationship dimensions

A recurring actor may use only the dimensions its dossier requires:

- **grievance:** desire to answer a specific harm or humiliation;
- **fear:** expectation that contact is dangerous;
- **respect:** belief that the party is capable, principled, or useful;
- **debt:** remembered help, mercy, payment, rescue, or obligation;
- **curiosity:** desire to understand the party, an item, a power, or a contradiction;
- **loyalty:** commitment to a person, faction, settlement, god, or promise;
- **greed:** appetite for a visible reward or advantageous arrangement.

No single “friendship score” decides behavior. A rival may have high grievance and high respect, or high fear and high debt. Authored transitions interpret those combinations.

## Promotion eligibility

An ordinary enemy becomes eligible only after a mechanically meaningful incident, such as:

- surviving a critical hit or environmental defeat;
- being taunted repeatedly, spared, healed, bribed, rescued, or abandoned;
- defeating the party without taking owned gear;
- witnessing a boss, god, demigod, or faction event;
- losing an ally or being betrayed by its own side;
- interacting with a Legendary or Mythic item law;
- becoming the subject of a Spotlight callback or bar rumor.

The selection budget limits active recurring actors per zone and per profile. Common enemies can still be funny without all receiving permanent identities.

## Return roles

Returning actors occupy authored situation roles rather than teleporting into arbitrary scenes:

- **challenger:** declares a duel or ambush with an exit and recovery path;
- **lieutenant:** joins a stronger local actor and gains one compatible technique;
- **cohort leader:** recruits a bounded group from its original family or a negotiated faction;
- **tracker:** appears on an open route after the player receives warning evidence;
- **bar guest:** observes neutral-ground rules, trades insults, gambles, bargains, or starts an optional brawl;
- **shop problem:** owns, wants, guards, or accidentally became part of a transaction;
- **informant:** exchanges route, ecology, faction, or rival information for a motive-compatible price;
- **temporary ally:** joins one situation against a shared danger;
- **resident or hire:** moves into a settlement or Hearthfold guest role after a full relationship thread;
- **avoidant witness:** sees the party and leaves, spreading a bounded rumor rather than forcing contact.

## Cohorts and stronger patrons

Two or more recurring actors can cooperate only when a relationship or common goal supports it. Their team has a reason visible through dialogue, rumor, insignia, or behavior. Possibilities include shared grievance, mutual protection, a paid contract, devotion to a stronger actor, a rescue debt, or a plan to steal the same object.

A recurring actor may gravitate toward a stronger being in the current or later zone. The patron grants at most one compatible technique or mutation and demands a role in return. Defeating the patron does not automatically kill or permanently bind the follower. The follower can defect, negotiate, flee, inherit a reduced role, or decide the party is the safer alliance.

## From enemy to friend

Friendship is an authored transition supported by evidence. Example catalysts include:

- the party rescues the actor from a flood, collapse, divine punishment, or betrayal;
- the actor helps the party survive a situation neither side caused;
- new information proves the original grievance was manipulated;
- a greedy actor discovers cooperation is consistently more profitable;
- a frightened actor receives protection without humiliation;
- repeated bargains establish reliable debt and respect;
- a rival admires a specific party ethic while still disliking one member;
- a shared enemy threatens the actor's family, settlement, ecology, or self-preservation.

Friendship does not erase prior facts. A former rival can joke about the old defeat, retain boundaries, refuse some quests, or temporarily disagree without flipping back to homicidal hostility.

## Dialogue-driven encounter flow

An encounter begins in one of these inspectable postures:

1. unaware;
2. observing;
3. warning;
4. negotiating;
5. threatening;
6. committed to combat;
7. seeking escape;
8. offering surrender;
9. requesting aid;
10. enforcing neutral-ground rules.

Player actions include Listen, Ask, Taunt, Threaten, Appeal, Bribe, Trade, Invoke Reputation, Reveal Knowledge, Offer Mercy, Demand Surrender, Leave, and Attack. Not every actor supports every action. Options show the influencing attributes and facts, including Presence, Insight, relevant Discipline or item tags, relationship bands, faction reputation, known motives, promises, witnesses, local laws, and current danger.

Stats change leverage and information quality rather than replacing authored logic. A high Presence can make a threat credible, but it cannot make a loyal parent sell a child. Insight may reveal that greed is a mask for fear, opening a safer offer. An item can prove a fact or trigger recognition. Taunt can seize targeting and initiative while making later negotiation harder.

## Serendipity without nonsense

Unexpected decisions come from the Situation Engine combining compatible facts, not from unrestricted random personality rolls. A serendipitous alliance might require:

- both sides trapped by a newly changed water route;
- the rival has high self-preservation and low loyalty to its patron;
- the party previously spared one of its allies;
- an immediate shared threat exceeds both combat budgets;
- a legal temporary-ally scene and follow-up outcome exist.

The result can feel surprising because the circumstances were not planned by either character. It remains explainable after the fact.

## Presentation and dialogue

Recurring actors receive additional opening, recognition, defeat-memory, patron, cohort, neutral-ground, surrender, bargain, assistance, betrayal, reconciliation, and aftermath lines. Speech can appear above the actor in the world while a readable transcript enters the event feed. Important lines pause presentation but never create a response timer.

Dialogue may reference:

- exact prior place and zone;
- finishing party member and action family;
- damage type or environmental object;
- whether the actor was taunted, spared, healed, robbed, or helped;
- a witnessed Legendary or Mythic law activation;
- current allies, patron, visible scars, and changed title;
- rumors the actor credibly learned after the event.

It may not invent private player choices, unseen events, or knowledge the actor never obtained.

## Safety, pacing, and anti-frustration limits

- No rival steals equipped or archived items through an unpreventable scene.
- A recurring appearance cannot disable the current critical quest or remove essential services.
- The same actor cannot interrupt consecutive ordinary encounters without an authored short arc and an explicit player opt-in.
- Rivals have appearance cooldowns measured in game turns and content beats, never real-world time.
- Growth has a zone-relative cap and a visible source. Returning actors are usually a little stronger than local ordinary enemies, not automatic bosses.
- Surrender, retreat, or losing a rivalry encounter preserves the Archive and uses the standard no-loss recovery contract.
- Players can inspect remembered facts, relationship reasons, and why an actor is currently eligible to appear.
- Accessibility settings can move above-head dialogue into a larger fixed transcript, extend reading pauses, and reduce animation intensity.

## First vertical proof

The first proof promotes one Form Auditor after a qualifying encounter and stores:

- Gutterbloom room role and seed;
- finishing party member;
- finishing action and damage type;
- whether pressure, Taunt, a critical hit, or a named equipment law participated;
- final relationship posture;
- one growth-budget choice;
- one legal reappearance role at the Dry Boot yard or Promoted Office.

Its return must accurately reference at least two stored facts, offer one combat and one non-combat branch, and leave the current contract completable whichever branch the player chooses.
