# NPC Dossier Standard and Gutterbloom Cast

## 1. Purpose

Named NPCs make a living zone feel inhabited rather than procedurally rearranged. A useful dossier connects character writing to schedules, services, knowledge, relationships, situation roles, world state, commentary, combat, persistence, and content preservation.

This document defines the production standard and the first original Gutterbloom cast. It borrows no names, characters, dialogue, relationships, locations, quests, or signature objects from the supplied dossier compendium.

## 2. Dossier requirements

Every major named NPC declares the following.

### 2.1 Identity and function

- immutable content ID;
- player-facing name and pronunciation note;
- species, culture, faction, and role tags;
- zone and likely presence locations;
- first-meeting purpose;
- repeat-visit service or information function;
- relationship to the zone's primary gameplay verb;
- expected production tier: major, supporting, specialist, ambient, or conditional nemesis.

### 2.2 Presentation

- silhouette and scale;
- face or focus of attention;
- materials and palette;
- locomotion and idle behavior;
- voice motive, rhythm, and vocabulary;
- subtitle and nonverbal communication requirements;
- accessibility cues that cannot rely on color or audio alone;
- minimum animation, model, portrait, VFX, and audio budget.

### 2.3 Character engine

- immediate want;
- long-term want;
- fear or pressure;
- false belief;
- boundary the character will not cross;
- contradiction that creates humor;
- protected sincere subject;
- possible growth without player ownership of the character.

### 2.4 Knowledge and secrets

Each fact declares:

- proposition ID;
- truth state;
- confidence;
- source;
- who else knows;
- share policy;
- relationship or situation prerequisites;
- accurate, partial, and distorted rumor variants where appropriate;
- what player-facing system changes when learned.

A dossier may contain secrets the player never learns. A secret must not exist only as unobservable author trivia if it consumes production scope.

### 2.5 Relationships

Only meaningful edges are authored. Each specifies used dimensions, initial bands, reason, possible deltas, terminal states, and whether it can produce a callback.

NPC relationships do not decay while the game is closed. Repeating the same gift or dialogue option stops adding progress at a content-defined cap but does not subtract progress.

### 2.6 Activity states

Schedules use in-game day phase, zone state, accepted situations, and authored fallbacks. They never use weekdays, real-world dates, or time since login.

Every essential service declares a replacement or remote access path if the character is temporarily elsewhere.

### 2.7 Situation and quest roles

- roles the NPC may bind;
- roles and situations it must never bind;
- authored introductory, relationship, conflict, recovery, and aftermath threads;
- valid outcome directions;
- state, relationship, rumor, reward, and presence effects;
- preserved content after refusal or failure.

### 2.8 Combat, mortality, and succession

Each NPC is one of:

- protected noncombat;
- temporarily disableable;
- duel-only;
- hostile repeatable;
- mortal through directly observed authored choice;
- replaceable through declared successor state.

No named NPC dies from an unloaded-zone tick. If death or departure is possible, essential services, build rewards, unresolved clues, and collections must have successors before the outcome ships.

### 2.9 Humor and sincerity

Define:

- joke targets;
- preferred structures;
- forbidden joke structures;
- escalation pattern;
- how the voice differs from Herald and Picket;
- at least one context in which the character stops joking;
- whether routine lines are voiced, text-only, or nonverbal;
- repetition and callback limits.

The character must remain understandable when incidental dialogue is muted.

## 3. Relationship presentation

The player sees descriptive bands, not optimization spreadsheets.

| Dimension | Low band | Middle band | High band |
| --- | --- | --- | --- |
| Trust | guarded | testing | confiding |
| Regard | dismissive | professional | admiring |
| Tension | easy | complicated | openly conflicted |
| Concern | detached | attentive | protective |
| Curiosity | uninterested | observant | fascinated |

Exact values remain available in debug tools. Dialogue, services, situation eligibility, and companion scenes use authored band transitions. One generic relationship score cannot replace distinct motives.

## 4. Gutterbloom ensemble map

| NPC | Primary place | Gameplay function | Comic pressure | Sincere pressure |
| --- | --- | --- | --- | --- |
| Dava Fen | The Dry Boot | bar, rumor verification, neutral mediation | hospitality enforced as civil engineering | keeping a refuge neutral |
| Quoin Rusk | Latchmarket anchor deck | anchors, route materials, Hearthfold bridge | measures impossible spaces in unsuitable units | fear of stranding travelers |
| Registrar Loam | Tollmold Culvert | ecology negotiation and material exchange | a fungus collective obsessed with singular paperwork | recognition as living citizens |
| Scrip Nine | Dry Boot and old office routes | Water Continuity knowledge and boss clues | retired armor still follows obsolete filing etiquette | responsibility for past enforcement |
| Skip Nall | roofline and Causeway | route rumors, delivery contracts, traversal demonstrations | treats unsafe shortcuts as customer service | supporting a scattered family network |
| Mara Venn | Root-Turn greenhouse | ecology, root routes, Conservatory research | plants issue maintenance requests through her | preventing habitat repair from becoming domination |
| Three-Cups | rotating market stall | Cache appraisal, item-origin puzzles, odd commerce | three cups disagree about every valuation | proving they are a person, not equipment |
| Due Notice | flooded routes and office patrols | conditional nemesis, negotiation, target source | believes warning paperwork is a combat style | learning that duty can survive invalid orders |

Picket and the Rain Treasurer remain governed by their existing companion and boss specifications. This ensemble gives them a civic and emotional context.

## 5. Dava Fen, Keeper of the Dry Boot

### Identity and presentation

**ID:** `npc.gutterbloom.dava_fen`

Dava is a middle-aged roof-ferry pilot who turned a stranded maintenance canteen into the Dry Boot. She is human, weather-beaten, broad-shouldered, and always dressed for rain except for one foot kept in a polished dry boot behind the bar. The displayed boot is the establishment's safety certificate, civic seal, and worst drinking vessel.

Her silhouette centers on a folded ferry pole carried like a walking staff. She uses it to point at exits, settle brawls without striking anyone, and retrieve mugs from improbable distances.

**Voice:** compact, practical sentences; no metaphors she cannot invoice; pauses before saying something kind.

### Character engine

- **Immediate want:** keep the bar useful during the flood dispute.
- **Long-term want:** make the Dry Boot neutral ground recognized by every local group.
- **Pressure:** every faction wants neutrality to mean quiet support for itself.
- **False belief:** if she never asks anyone for help, no one can claim ownership of the bar.
- **Boundary:** she will not surrender a guest already under the bar's protection.
- **Contradiction:** treats hospitality as load-bearing infrastructure while refusing to admit people matter to her.
- **Protected sincere subject:** the first evacuation in which she could not carry everyone.

### Knowledge and secrets

1. Dava knows a roofline route that remains above the highest ordinary water state. She shares it after the player verifies one bar rumor or helps Skip complete a delivery.
2. The polished boot contains a rolled fragment of the original emergency closure order. Dava does not know it invalidates part of the Treasurer's mandate.
3. She quietly gives free preparation food to people who cannot pay, then records it as "structural testing."

### Relationships

- **Quoin:** high Trust, middle Tension. They agree on safety and disagree about acceptable improvisation.
- **Registrar Loam:** professional Regard. Dava respects the Registry but will not let Tollmold expand through the cellar.
- **Scrip Nine:** high Concern, guarded Trust. She knows Scrip enforced harmful orders and also knows Scrip helped people escape them.
- **Claimant:** starts testing. Trust rises through verified information, respected neutrality, and practical help, not purchases.

### Activity states

| Predicate | Activity | Presence | Fallback |
| --- | --- | --- | --- |
| Dry Boot available | bar service | Dry Boot | cellar inventory |
| trade phase and roof route safe | supply run | roofline slots | delegate service to staff proxy |
| hard rain or evacuation accepted | shelter management | Dry Boot entry | none, critical role |
| post-boss celebration | civic host | Dry Boot | normal bar service |

The bar menu and essential rumor board remain available through staff if Dava is on a supply run.

### Situation roles and arcs

- bar proprietor, neutral mediator, evacuation coordinator, rumor verifier;
- introductory thread: verify whether a Dry Boot rumor describes an actual open route;
- relationship thread: choose how neutrality survives faction pressure without picking an owner;
- aftermath thread: decide whether the establishment becomes a council chamber, courier hall, or protected common room;
- recovery role: converts a failed civic event into a practical repair contract.

### Humor and sincerity

Dava targets bad policy, performative heroism, decorative safety equipment, and anyone describing a roof as a nautical vessel. She never mocks player failure or need for shelter. Routine bar lines cap quickly. Her serious evacuation conversation receives a full sincerity hold.

### Persistence and mortality

Dava is protected noncombat in the vertical slice. Later incidents may temporarily move her, but the Dry Boot cannot lose safe service, storage access, or rumor verification.

## 6. Quoin Rusk, Anchorwright

### Identity and presentation

**ID:** `npc.gutterbloom.quoin_rusk`

Quoin is an amphibious stoneworker in a brass measuring harness. Their skin resembles layered slate, and small luminous river plants grow in the seams. They build anchors by persuading two incompatible spaces to agree on where the doorway is.

The harness unfolds into rulers, plumb lines, tuning forks, and one spoon Quoin insists is a licensed geometric instrument.

**Voice:** patient technical explanation followed by one wildly unsuitable unit of measure.

### Character engine

- **Immediate want:** stabilize the Inspection Kiosk anchor.
- **Long-term want:** connect every safe settlement without making the route network controllable by one faction.
- **Pressure:** the Office treats anchors as taxable gates; smugglers want unregistered exits.
- **False belief:** every dangerous uncertainty can be solved by measuring it more precisely.
- **Boundary:** never opens an anchor whose return state cannot be guaranteed.
- **Contradiction:** a precision engineer whose preferred unit is "about one soup-bowl of sideways."
- **Protected sincere subject:** a prior anchor collapse that stranded a work crew.

### Knowledge and secrets

1. Quoin can identify Hearthfold-compatible threshold materials.
2. The Kiosk anchor is not broken. It is refusing an obsolete authority signature.
3. Quoin once built an unregistered evacuation anchor and still fears an Office audit that no longer has legal force.

### Relationships

- **Dava:** trusted collaborator with argument-friendly Tension.
- **Picket:** high Curiosity and professional Regard. Each believes the other is using an obsolete manual.
- **Three-Cups:** refuses to measure their interior volume after the last attempt changed the weather in one cup.
- **Claimant:** Regard rises through safe route discovery, honest repair choices, and Hearthfold experimentation.

### Activity states

Quoin rotates among the Latchmarket anchor deck, Kiosk repair, discovered anchor inspections, and an offscreen workshop according to accepted work and route state. A static repair ledger provides crafting and travel functions while they are away.

### Services and arcs

- anchor stabilization and exact destination previews;
- route-material identification;
- Hearthfold Threshold Engine foreshadowing;
- `Anchor Under Warranty` situation;
- a later choice among open civic routing, faction-managed routing, or distributed local anchors, all preserving ordinary travel.

### Humor, sincerity, and mortality

Quoin's jokes emerge from literal engineering responses to magical nonsense. They do not make extended speeches during navigation warnings. Quoin is protected noncombat. Anchor incidents cannot strand the profile or remove an unlocked destination.

## 7. Registrar Loam, Tollmold Delegate

### Identity and presentation

**ID:** `npc.gutterbloom.registrar_loam`

Registrar Loam is a distributed Tollmold colony inhabiting a fired-clay clerical frame. Dozens of softly glowing caps fill its chest and sleeves. The colony can send a few caps through culvert cracks while the frame remains at a meeting.

Loam uses singular grammatical paperwork for a plural biological self and resents both options.

**Voice:** patient collective cadence, precise civic vocabulary, abrupt corrections from "I" to "we" and back.

### Character engine

- **Immediate want:** establish a recognized fungal crossing through the Culvert.
- **Long-term want:** have Tollmold treated as residents rather than resource nodes or infestations.
- **Pressure:** expansion can genuinely damage human structures if unmanaged.
- **False belief:** legal recognition will automatically create mutual understanding.
- **Boundary:** will not surrender living colony members as crafting materials.
- **Contradiction:** represents a decentralized organism through obsessive centralized paperwork.
- **Protected sincere subject:** earlier colony clearances remembered through shared spores.

### Knowledge and secrets

1. Tollmold has absorbed fragments of old drainage notices and knows the emergency water order contains contradictory clauses.
2. The colony can create temporary footing without being consumed if fed ordinary compost material.
3. Some Tollmold cells want independence from the Registry and communicate through altered form stamps.

### Relationships

- **Dava:** mutual Regard, active boundary negotiation.
- **Mara:** high Trust with disagreement over whether cultivation is care or management.
- **Scrip Nine:** high Tension. Loam remembers enforcement raids; Scrip remembers being ordered to conduct them.
- **Claimant:** Curiosity begins high. Trust depends on reading Tollmold as actors rather than containers.

### Activity states

Loam can be present at the Culvert registry shell, Dry Boot mediation table, Root-Turn study plot, or post-boss civic assembly. Colony ambience persists in the Culvert while the named frame is elsewhere.

### Services and arcs

- negotiate safe Tollmold traversal;
- exchange renewable ecology materials without killing colony members;
- reveal document rumors;
- `Tollmold Right of Way` and `After the Treasurer` roles;
- later Guest Wing ecology visitor.

### Humor, sincerity, and mortality

Loam targets property law, definitions of singular identity, and people who say "just a mushroom." They do not joke during discussion of clearances. The named colony is protected from random destruction. Hostile ecology cells are separate actors and do not share Loam's identity.

## 8. Scrip Nine, Retired Continuity Clerk

### Identity and presentation

**ID:** `npc.gutterbloom.scrip_nine`

Scrip Nine is an empty Sump Knight shell animated by the residue of thousands of approved and rejected water orders. They removed their pressure weapon, painted over the Office crest, and now occupy a reinforced corner of the Dry Boot that Dava calls a chair and Scrip calls administrative exile.

Their faceplate displays paper strips with the current emotional state as an incorrect filing category.

**Voice:** formal passive constructions when afraid; direct first-person statements when honest.

### Character engine

- **Immediate want:** determine whether the Rain Treasurer's standing order is valid.
- **Long-term want:** become responsible for choices rather than merely compliant with instructions.
- **Pressure:** local residents remember Scrip as an enforcer.
- **False belief:** admitting uncertainty will prove they were never a person.
- **Boundary:** refuses to issue an order that cannot be appealed.
- **Contradiction:** a retired bureaucratic weapon trying to invent conscientious objection through proper procedure.
- **Protected sincere subject:** raids Scrip conducted before leaving the Office.

### Knowledge and secrets

1. Scrip knows the Rain Treasurer's break-condition logic and one safe pressure sequence.
2. Scrip removed the final authorization seal from an old order, but cannot remember whether it was sabotage or an accident.
3. Scrip can hear other Sump Knight order broadcasts and knows some are starting to question them.

### Relationships

- **Dava:** high Concern in both directions, guarded Trust.
- **Registrar Loam:** high Tension and potential restorative arc. Loam is never required to forgive Scrip.
- **Due Notice:** Regard mixed with fear. Scrip sees a possible future and a past self.
- **Picket:** professional rivalry over whether a rule can become invalid through abandonment.
- **Claimant:** begins guarded. Trust rises through evidence, accountable choices, and refusal to treat confession as absolution.

### Activity states

Scrip appears at the Dry Boot, old Continuity office access points, a mediation scene, or the boss antechamber after enough evidence is found. Mechanical boss clues remain available from environmental scans if Scrip is elsewhere.

### Services and arcs

- Office law and Sump Knight behavior information;
- nonexclusive Rain Treasurer clue;
- `The Invalid Rain Order` situation;
- restorative mediation with Loam;
- potential Guest Wing records specialist;
- successor contact for nonhostile Sump Knight groups after the boss.

### Humor, sincerity, and mortality

Scrip targets passive voice, approval chains, and regulations that have outlived their nouns. They never joke to excuse prior harm. Scrip is protected noncombat in ordinary play and cannot be absolved or condemned by one generic dialogue check.

## 9. Skip Nall, Roof Courier

### Identity and presentation

**ID:** `npc.gutterbloom.skip_nall`

Skip is an adult roof courier with a folding reed glider, a waterproof parcel cage, and an encyclopedic knowledge of places where a responsible person would install a railing. They are fast because the market is scattered, not because a timer grades the player.

**Voice:** breathless route narration, aggressive optimism, and precise delivery etiquette in extremely unsafe locations.

### Character engine

- **Immediate want:** prove a new low-water route is stable enough for medicine deliveries.
- **Long-term want:** connect separated roof communities through redundant paths.
- **Pressure:** dangerous shortcuts are sometimes the only affordable routes.
- **False belief:** being indispensable is the same as being safe.
- **Boundary:** will not abandon a parcel containing medicine, letters, or live cargo.
- **Contradiction:** lectures the player about package security while jumping a flooded street on a tea tray.
- **Protected sincere subject:** family members separated by the rising water.

### Knowledge and secrets

1. Skip knows two shortcut entrances and one false shortcut spread by smugglers.
2. The parcel cage contains letters for residents believed missing, creating later cross-zone hooks.
3. Skip's best route is based on a bridge Mara considers ecologically unstable.

### Relationships

- **Dava:** familial Regard and recurring argument over risk.
- **Mara:** high Tension, high Trust when they actually communicate.
- **Three-Cups:** frequent customer; neither can explain what is being delivered.
- **Claimant:** Regard comes from route competence and protecting the purpose of a delivery, never completion speed.

### Activity states, services, and arcs

Skip appears on the roofline, Causeway, Dry Boot delivery rail, or new post-boss route. They demonstrate traversal, sell discovered-route maps, and provide delivery contracts with no real-time timer. Failure moves the parcel to a recovery location or alternate courier route.

### Humor, sincerity, and mortality

Skip's jokes target route design and courier professionalism. They do not mock slower play. Skip cannot die offscreen or during ordinary delivery failure. Accessible route variants provide equivalent completion and relationship outcomes.

## 10. Mara Venn, Root Surgeon

### Identity and presentation

**ID:** `npc.gutterbloom.mara_venn`

Mara is a root surgeon and habitat engineer whose coat pockets contain labeled soil, unlabeled tools, and one root that has been trying to resign. Flexible wooden braces wrap her arms and translate root pressure into visible mechanical gauges.

**Voice:** clinical ecology language interrupted by quiet apologies to plants she has already cut.

### Character engine

- **Immediate want:** stabilize Root-Turn without choking the wetland.
- **Long-term want:** develop repair practices that local ecology can refuse.
- **Pressure:** Latchmarket needs reliable bridges, while the habitat needs routes that move and decay.
- **False belief:** enough observation can make intervention neutral.
- **Boundary:** will not force a sentient or distributed organism into permanent infrastructure.
- **Contradiction:** an expert in consent who keeps receiving demands from plants with no standardized signature.
- **Protected sincere subject:** a prior bridge that survived by destroying the habitat beneath it.

### Knowledge and secrets

1. Root-Turn responds to damage and movement tags, not only water level.
2. Mara has received an Orchard Crown signal but has not accepted a covenant.
3. One root network has begun generating marks that resemble Office maintenance forms.

### Relationships

- **Registrar Loam:** high Trust, productive Tension.
- **Skip:** mutual Concern expressed as arguments.
- **Quoin:** professional Regard and disagreement over permanent geometry.
- **Claimant:** Curiosity rises through unusual non-destructive ecology interactions.

### Activity states, services, and arcs

Mara rotates among Root-Turn, a Latchmarket greenhouse, Conservatory visits, and field interventions. She provides ecology research, route-state previews, cultivation recipes, and `The Root That Filed Back`. Root services persist through her research board when she is elsewhere.

### Humor, sincerity, and mortality

Mara's comedy comes from translating plant behavior into workplace negotiation. Her serious habitat history is protected. She is noncombat in the slice and cannot be randomly kidnapped, killed, or converted into a rescue deadline.

## 11. Three-Cups, Itinerant Appraiser

### Identity and presentation

**ID:** `npc.gutterbloom.three_cups`

Three-Cups is a single animated merchant composed of three ceramic vessels stacked on a brass walking frame. The top cup claims to be judgment, the middle cup claims to be memory, and the bottom cup claims it is carrying the others and should receive most of the money. All three are one person. Usually.

The cups rotate to indicate speaker and use distinct subtitle icons. When incidental voice is muted, tilt, steam, and card movement preserve meaning.

**Voice:** three short registers that interrupt one another without overlapping accessibility cues.

### Character engine

- **Immediate want:** appraise a Cache with an impossible ownership history.
- **Long-term want:** gain civic recognition as a person rather than market equipment.
- **Pressure:** merchants want to classify Three-Cups as a tool to avoid granting a stall license.
- **False belief:** proving perfect internal agreement is necessary for personhood.
- **Boundary:** never falsifies a mechanical property or acquisition source.
- **Contradiction:** a flawlessly honest appraiser that cannot agree with itself about taste, value, or tea.
- **Protected sincere subject:** fear that breaking one cup will change who survives.

### Knowledge and secrets

1. Three-Cups can detect impossible origin chains and migrated item definitions.
2. The walking frame once belonged to the Office, but the cups animated it independently.
3. Each cup remembers a different fragment of the same pre-awakening event.

### Relationships

- **Quoin:** high Curiosity and mutual technical exhaustion.
- **Dava:** trusted stall sponsor.
- **Skip:** frequent delivery relationship with confused obligation records.
- **Claimant:** Trust begins professional and grows when the player values exact truth over flattering appraisal.

### Activity states and services

Three-Cups rotates between Latchmarket, the Dry Boot appraisal table, the Hearthfold Guest Wing, and rare Cache-convoy events. Archive item inspection retains exact appraisal functions while they travel.

Services include Cache preview, origin-ledger explanation, named-synergy hints, fake or corrupted-definition detection, and collection dialogue. Three-Cups never modifies hidden odds.

### Arcs, humor, and mortality

`Three Cups, Four Owners` investigates a contradictory item origin without removing the item. Their personhood thread affects civic dialogue and stall presentation, not service access or prices. Three-Cups is protected noncombat. Humor targets valuation rituals and internal committee meetings, never dissociation or disability.

## 12. Due Notice, Conditional Sump Knight

### Identity and presentation

**ID:** `npc.gutterbloom.due_notice`

Due Notice begins as a procedurally selected Sump Knight patrol shell eligible to become a named recurring opponent. The name appears only after the first meaningful recurrence, which can result from an interrupted patrol, a successful escape, a negotiated Tollmold crossing, or Due Notice defeating the player. Death is not required.

The armor carries a roll of warning ribbon that is deployed before attacks, around loot, across doorways, and occasionally around Due Notice's own leg.

**Voice:** stamped phrases and increasingly improvised footnotes.

### Character engine

- **Immediate want:** deliver a valid warning to an authorized recipient.
- **Long-term want:** discover whether duty can exist after the issuing office loses legitimacy.
- **Pressure:** every available order points back to an absent authority.
- **False belief:** an action becomes ethical if sufficiently announced.
- **Boundary:** always telegraphs an attack and eventually honors a properly acknowledged parley.
- **Contradiction:** a dangerous enforcement construct obsessed with notice quality rather than enforcement outcome.
- **Protected sincere subject:** first realization that prior warnings gave victims no meaningful choice.

### Recurrence states

| State | Unlock cause | Encounter change | Noncombat possibility |
| --- | --- | --- | --- |
| Serving | first appearance | standard Sump Knight role | warning can be acknowledged |
| Annotated | one meaningful recurrence | adds visible footnote zones | inspect contradictory order |
| Disputed | evidence of invalid mandate | uses mixed patrol and hesitation | short parley |
| Self-Issued | post-boss or relationship turn | chooses one independent tactic | contract, duel, or patrol help |
| Due Notice | resolved identity | named source and authored law variant | recruit as specialist or preserve rivalry |

The state depends on varied encounters and discovered facts, not an exact fight count.

### Knowledge and secrets

1. Due Notice carries a copy of every warning it failed to deliver.
2. One copy is addressed to the Rain Treasurer.
3. The ribbon itself records route safety and can become a War Room or Anchorwright tool.

### Relationships

- **Scrip Nine:** high Regard, fear, and Tension.
- **Picket:** procedural rivalry that can become mutual professional concern.
- **Registrar Loam:** starts hostile because Tollmold is classified as an obstruction; may change through acknowledgment.
- **Claimant:** Curiosity and Regard change through tactics, evidence, and whether warnings are treated as choices.

### Combat, reward, and succession

Due Notice is hostile repeatable until a noncombat state is chosen. Defeat returns the shell through Office reconstruction or an Echo Hunt while the identity record persists. If the player chooses a terminal destruction in a later authored route, a **Notice of Vacancy** successor preserves the named target source, ribbon tool, and unresolved clues.

The encounter never adapts permanent resistance to the player's favorite damage. It can choose authored tactical responses visible before engagement, and every response keeps a counter route.

### Humor and sincerity

Due Notice targets warnings delivered too late, notices attached to themselves, and the belief that labels change physics. Recurring combat lines have strict stage caps. The sincere identity scene suppresses the Herald unless an authored exchange explicitly protects the moment.

## 13. Picket and Rain Treasurer integration

### Picket

Picket's existing function remains companion, inspector, hazard marker, item retriever, and countervoice. New cast relationships add:

- professional disagreement with Quoin;
- procedural history with Scrip Nine;
- escalating rivalry and concern with Due Notice;
- ecology interviews with Loam and Mara;
- Dry Boot scenes in which Dava treats Picket as staff before Picket agrees.

Picket cannot become the only source of a route, warning, boss clue, or civic fact.

### Rain Treasurer

The boss remains an embodied obsolete reserve policy. The cast creates several interpretations:

- Dava sees a civic danger;
- Quoin sees a route and anchor failure;
- Loam sees both habitat protection and coercive control;
- Scrip sees an invalid but familiar authority;
- Skip sees separated communities;
- Mara sees forced ecological stasis;
- Three-Cups sees a reward-source and ownership contradiction;
- Due Notice sees a superior who may no longer be authorized.

The boss aftermath can therefore generate social, ecological, route, item, and relationship consequences without one canonical moral answer.

## 14. Initial relationship edges

Only these NPC-to-NPC edges are required for the slice:

| From | To | Initial state | Used dimensions | First authored pressure |
| --- | --- | --- | --- | --- |
| Dava | Quoin | trusted collaborators | Trust, Tension | anchor safety versus improvisation |
| Dava | Scrip | guarded refuge | Trust, Concern | responsibility for past enforcement |
| Dava | Skip | practical family | Regard, Concern | delivery risk |
| Loam | Scrip | unresolved harm | Tension, Curiosity | invalid order evidence |
| Loam | Mara | trusted disagreement | Trust, Tension | cultivation boundaries |
| Quoin | Picket | professional dispute | Regard, Curiosity | authority signatures |
| Scrip | Picket | procedural mirrors | Regard, Tension | abandoned regulations |
| Scrip | Due Notice | possible futures | Fear, Concern | order legitimacy |
| Mara | Skip | mutual concern | Trust, Tension | bridge stability |
| Three-Cups | Dava | sponsored personhood | Trust, Regard | stall recognition |

All other relationships are absent until content uses them.

## 15. Full Gutterbloom production dialogue and scene budget

Provisional minimum:

| NPC | Intro scene | Repeat utility lines | Situation lines | Relationship scene | Post-boss change |
| --- | ---: | ---: | ---: | ---: | ---: |
| Dava | 1 | 12 | 16 | 1 | 6 |
| Quoin | 1 | 10 | 12 | 1 | 4 |
| Loam | 1 | 10 | 14 | 1 | 4 |
| Scrip Nine | 1 | 8 | 16 | 2 | 6 |
| Skip | 1 | 10 | 10 | 1 | 4 |
| Mara | 1 | 8 | 10 | 1 | 4 |
| Three-Cups | 1 | 16 text-first | 10 | 1 | 4 |
| Due Notice | combat intro | 12 stage-capped | 12 | 1 | 4 |

These are M27 authored-line targets, not a voiceover commitment. The vertical slice fully presents Dava and Scrip, uses Quoin as a shared static specialist, gives Loam one limited scene, and builds Due Notice from the existing Sump Knight and promotion kit. Skip, Mara, and Three-Cups remain data-only simulation fixtures until Gutterbloom production expansion. This keeps the richer cast plan from silently expanding the vertical-slice art and scene budget.

## 16. Dossier validation

Each production dossier fails review if:

- the character has no recurring gameplay or information function;
- the voice cannot be distinguished from Herald, Picket, and local peers;
- the schedule can remove an essential service without fallback;
- a secret has no discovery route or player-facing consequence;
- a relationship change lacks a typed cause;
- generic random simulation can trigger intimacy, irreversible betrayal, or death;
- the NPC can die offscreen;
- a terminal outcome removes unique rewards, clues, or services without successors;
- the character requires real-world return timing;
- humor obscures mechanics or targets accessibility, identity, trauma, or player skill;
- a sincere scene has no interruption policy;
- the model, voice, animation, writing, and testing budget is absent.

## 17. Automated and playtest gates

### Automated

- every presence location and role resolves;
- schedule rules select deterministic legal activities and fallbacks;
- unique NPCs cannot spawn in two loaded places;
- every relationship delta is bounded and logged;
- every rumor variant uses facts the NPC may know;
- all terminal states retain service and reward successors;
- muted incidental dialogue preserves navigation, service, and safety cues;
- save/load preserves activity, relationship bands, knowledge, and situations;
- no operating-system date or elapsed-offline value enters character state.

### Playtest

- players can identify at least five cast members by motive, not silhouette alone;
- hidden speaker-label tests distinguish Dava, Quoin, Loam, Scrip, Picket, and Herald;
- visits reveal changed activities without making services hard to find;
- players understand which claims are rumors and which are confirmed;
- Due Notice feels like a relationship-bearing rival without requiring repeated deaths;
- Scrip's accountability is not reduced to one forgiveness button;
- Loam reads as a person and ecology actor, not a resource dispenser;
- Three-Cups remains readable with voice muted;
- at least one post-boss return produces a cast interaction the player connects to their choice.

## 18. Deferred cast decisions

- which four NPCs receive full vertical-slice scene production;
- final species and human-presence balance in Latchmarket;
- whether Three-Cups uses one performer, three performers, or text-first presentation;
- whether Due Notice can become a Hearthfold resident or only a field specialist;
- which cast members can have optional romance arcs after character and audience review;
- final mortality policies for post-1.0 challenge or darker narrative routes;
- which NPCs travel to Brass Orchard and later zones.
