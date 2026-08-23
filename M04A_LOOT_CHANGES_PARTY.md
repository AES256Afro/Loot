# M04A Loot Changes the Party

## Player promise

Finding loot should make Chris reconsider what the party does next. A sword that adds two damage is allowed, but it is not the proof. The proof is a loadout that changes who receives Guard, whether Weakening spreads, what an exposed enemy enables, how a pressure line pays off, or which party member acts as the hinge of the plan.

The Archive is a collection, workshop, and build laboratory. It is not a punishment screen. It has no capacity limit. Equipping never consumes an item. Favoriting never changes drop odds. Defeat never deletes gear. Loadouts remain available between expeditions.

## Demo loadouts

### Loadout A: Municipal Phalanx

- Dena intercepts declared attacks and turns blocked damage into counterattacks.
- Moss receives Guard from Dena and converts it into a second-target Weakening spread.
- Ilex turns overhealing into party Guard.
- Shared relics reward a varied four-command plan.

The intended rhythm is Guard, spread, absorb, counter.

### Loadout B: Burst Pipe Choir

- Vell converts the primed pressure line into exposed enemies instead of only area damage.
- Dena gains extra damage against exposed targets.
- Moss detonates Weakening for a second hit.
- Ilex grants follow-up power to the most injured ally.

The intended rhythm is prime, expose, focus, finish.

## Equipment law contract

Equipment compiles into an immutable law dictionary before a round resolves. The combat resolver receives the dictionary as an input, duplicates authoritative state, and emits a deterministic trace. A law activation must name the item that caused it. No equipment script can mutate the Archive, save file, rewards, or dungeon topology during resolution.

The initial reusable laws are:

1. Opening Guard: grant every living member Guard at the start of round one.
2. Targeted Cover: Dena's Guard also covers the ally named by the most dangerous intention.
3. Guard Counter: Dena counterattacks an enemy after blocking its hit.
4. Guard Primes Hex: Guard placed on Moss primes the next Hexer power to spread.
5. Weakening Spread: Moss's power applies reduced damage and Weakening to a second enemy.
6. Weakness Detonation: striking a Weakened target consumes one stack for bonus damage.
7. Pressure Exposure: Vell's primed pressure-line power also Exposes every survivor.
8. Salvage Echo: Vell's utility action splashes damage to a second enemy.
9. Preventive Guard: Ilex's power grants Guard to the healed target.
10. Triage Relay: Ilex's power grants a one-round strike bonus to the most injured ally.
11. Exposed Breaker: Dena gains bonus damage against an Exposed target.
12. Varied Filing: a plan containing Strike, Power, Guard, and Utility grants party Guard before retaliation.

Numeric bonuses remain as supporting texture. The build-defining laws above are the milestone gate.

## Visual contract

The approved promo at `art/concepts/first_person_promo_reference.png` is the composition target, not a claim that every hand-painted pixel can be reproduced by one code pass. The runnable demo must materially close the gap by using:

- the first-person room as the largest uninterrupted region;
- illustrated, billboarded enemy silhouettes in the center of the room;
- four large illustrated portrait cards across the lower HUD;
- icon-led commands and visible equipment;
- carved dark panels with brass outlines, teal information, magenta magic, and warm amber highlights;
- short commentary overlays that preserve the dungeon view;
- integer-scaled, nearest-filtered generated art where practical.

## Reactive combat proof

Attacks produce typed presentation records containing source, target, damage type, final damage, blocked damage, critical state, target maximum Vitality, and normalized magnitude. Presentation consumes those records but cannot change combat state. Impact, slash, decay, acid, healing, and electricity each have distinct motion and color behavior. Electricity uses repeated high-frequency jitter and alternating charge flashes. A hit that removes less than roughly eight percent of maximum Vitality receives a restrained response; a fully blocked hit produces a Guard flash without a false body recoil.

The authored combat dialogue library covers victim-specific tiny hits, heavy hits, electrical reactions, critical-hit surprise, role-specific taunts, monster replies, monster openings, tactical observations, and short party exchanges. Dialogue selection uses the encounter seed, trigger, victim, enemy family, damage type, and magnitude. Immediate category repeats are rejected. Taunt is a command, not cosmetic chatter: the enemy must target the taunter for its next declared attack and suffer one Weakening while doing so.

## Completion evidence

M04A is complete only with automated checks, a visually inspected native macOS export, a captured screenshot, a complete six-room playthrough with at least one named equipment activation, updated evidence documents, and a verified commit on remote `main`.
